package Metiisto::Controller::Countdowns;
################################################################################
use strict;

use Data::Page;
use Dancer ':syntax';

use Metiisto::Util::DateTime;

use constant COUNTDOWNS_PER_PAGE => 15;

use base 'Metiisto::Controller::Base';

use Metiisto::Countdown;
################################################################################
sub list
{
    my $this = shift;

    my $total = Metiisto::Countdown->count();

    my $page = Data::Page->new();
    $page->total_entries($total);
    $page->entries_per_page(COUNTDOWNS_PER_PAGE);
    $page->current_page(params->{page} || 1);

    my @countdowns = Metiisto::Countdown->search_where(
        {1=>1},
        {
            limit_dialect => 'LimitOffset',
            limit    => COUNTDOWNS_PER_PAGE,
            offset  => $page->first() - 1,
            order_by => 'target_date',
        }
    );

    my $out = template 'countdowns/list', {
        countdowns => \@countdowns,
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

    my @units = keys %{Metiisto::Countdown->UNITS()};
    my $countdown = { on_homepage => 0 };

    my $out = template 'countdowns/new_edit', {
        countdown => $countdown,
        units     => \@units,
    };

    return ($out);
}
################################################################################
sub create
{
    my $this = shift;

    my $data = {};
    my $params = params();
    $params->{'countdown.target_date'}
        .= ' '
        # NOTE: Not sure why I have to convert to 24h time.
        . Metiisto::Util::DateTime->parse(delete $params->{'countdown.target_time'})
        ->format('%R');

    foreach my $p (keys %$params)
    {
        next unless $p =~ /^countdown\.(.*)$/;
        my $attr = $1;
        $data->{$attr} = $params->{$p};
    }
    my $countdown = Metiisto::Countdown->insert($data);
    die "Error creating Countdown" unless $countdown;

    my $out = redirect "/countdowns/".$countdown->id();

    return ($out);
}
################################################################################
sub show
{
    my $this = shift;
    my %args = @_;

    my $countdown = Metiisto::Countdown->retrieve($args{id});
    my $out = template 'countdowns/show', { countdown => $countdown };

    return ($out);
}
################################################################################
sub edit
{
    my $this = shift;
    my %args = @_;
    
    my @units = keys %{Metiisto::Countdown->UNITS()};
    my $countdown = Metiisto::Countdown->retrieve($args{id});
    my $out = template 'countdowns/new_edit', {
        countdown => $countdown,
        units     => \@units,
    };

    return ($out);
}
################################################################################
sub update
{
    my $this = shift;
    my %args = @_;

    my $countdown = Metiisto::Countdown->retrieve(id => $args{id});

    my $params = params();
    $params->{'countdown.target_date'}
        .= ' ' . delete $params->{'countdown.target_time'};
    foreach my $p (keys %$params)
    {
        next unless $p =~ /^countdown\.(.*)$/;
        my $attr = $1;
        $countdown->$attr($params->{$p});
    }
    $countdown->on_homepage(0) unless params->{'countdown.on_homepage'};
    my $cnt = $countdown->update();
    die "Error saving Countdown($args{id})" unless $cnt;

    my $out = redirect "/countdowns/$args{id}";

    return ($out);
}
################################################################################
sub delete
{
    my $this = shift;
    my %args = @_;

    my $countdown = Metiisto::Countdown->retrieve(id => $args{id});
    $countdown->delete();

    my $out = redirect '/countdowns';

    return ($out);
}
################################################################################
1;
