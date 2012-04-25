package Metiisto::Controller::Notes;
################################################################################
use strict;

use Data::Page;
use Dancer ':syntax';
use SQL::Abstract;

use Metiisto::Util::DateTime;

use constant ENCRYPTION_KEY => 'Hello World!';
use constant NOTES_PER_PAGE => 15;

use base 'Metiisto::Controller::Base';

use Metiisto::Note;
################################################################################
sub list
{
    my $this = shift;

    my $total      = 0;
    my $conditions;
    if (params->{filter_text})
    {
        $conditions = [
            { title => { 'regexp', params->{filter_text} } },
            # OR
            { body  => { 'regexp', params->{filter_text} } },
        ];
    }
    else
    {
        $conditions = {1=>1};
    }

    my $sql_abs = SQL::Abstract->new();
    my ($where, @binds) = $sql_abs->where($conditions);
    $total = Metiisto::Note->count_where($where, \@binds);

    my $page = Data::Page->new();
    $page->total_entries($total);
    $page->entries_per_page(NOTES_PER_PAGE);
    $page->current_page(params->{page} || 1);

    my @notes = Metiisto::Note->search_where(
        $conditions,
        {
            limit_dialect => 'LimitOffset',
            limit    => NOTES_PER_PAGE,
            offset  => $page->first() ? $page->first() - 1 : 0,
            order_by => 'created_date',
        }
    );

    my $out = template 'notes/list', {
        notes => \@notes,
        pagination => {
            current_page  => $page->current_page(),
            first_page    => $page->first_page(),
            last_page     => $page->last_page(),
            previous_page => $page->previous_page(),
            next_page     => $page->next_page(),
        }
    };

    return ($out);
}
################################################################################
sub new_record
{
    my $this = shift;

    my $note = { is_favorite => 0, is_encrypted => 0 };
    my $out = template 'notes/new_edit', {
        note => $note,
    };

    return ($out);
}
################################################################################
sub create
{
    my $this = shift;

    my $data = {};
    foreach my $p (keys %{params()})
    {
        next unless $p =~ /^note\.(.*)$/;
        my $attr = $1;
        $data->{$attr} = params->{$p};
    }
    $data->{created_date} = Metiisto::Util::DateTime->now()->format_db();
    $data->{updated_date} = $data->{created_date};

    my $note = Metiisto::Note->insert($data);
    die "Error creating Note" unless $note;

    my $out = redirect "/notes/".$note->id();

    return ($out);
}
################################################################################
sub show
{
    my $this = shift;
    my %args = @_;

    my $note = Metiisto::Note->retrieve($args{id});
    my $print = params->{print};
    
    my $out;
    if ($print)
    {
        $out = template 'notes/print', { note => $note }, {layout => undef};
    }
    else
    {
        $out = template 'notes/show', { note => $note };
    }


    return ($out);
}
################################################################################
sub edit
{
    my $this = shift;
    my %args = @_;

    my $note = Metiisto::Note->retrieve($args{id});
    my $out = template 'notes/new_edit', {
        note => $note,
    };

    return ($out);
}
################################################################################
sub update
{
    my $this = shift;
    my %args = @_;

    my $note = Metiisto::Note->retrieve(id => $args{id});

    foreach my $p (keys %{params()})
    {
        next unless $p =~ /^note\.(.*)$/;
        my $attr = $1;
        $note->$attr(params->{$p});
    }
    $note->is_favorite(0) unless params->{'note.is_favorite'};
    $note->updated_date(Metiisto::Util::DateTime->now());
    my $cnt = $note->update();
    die "Error saving Note($args{id})" unless $cnt;

    my $out = redirect "/notes/$args{id}";

    return ($out);
}
################################################################################
sub delete
{
    my $this = shift;
    my %args = @_;

    my $note = Metiisto::Note->retrieve(id => $args{id});
    $note->deleted_date(Metiisto::Util::DateTime->now());
    $note->update();

    my $url = '/notes';
    $url .= "?filter_text=".params->{filter_text} if params->{filter_text};

    my $out = redirect $url;

    return ($out);
}
################################################################################
sub encrypt
{
    my $this = shift;
    my %args = @_;

    my $note = Metiisto::Note->retrieve(id => $args{id});
    $note->encrypt(key => ENCRYPTION_KEY);
    $note->update();

    return (redirect request->referer);
}
################################################################################
sub decrypt
{
    my $this = shift;
    my %args = @_;

    my $note = Metiisto::Note->retrieve(id => $args{id});
    $note->decrypt(key => ENCRYPTION_KEY);
    $note->update();

    return (redirect request->referer);
}
################################################################################
1;
