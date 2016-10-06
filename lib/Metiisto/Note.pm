package Metiisto::Note;
################################################################################
use strict;

use Crypt::CBC;
use Metiisto::TaggedObject;

use base qw(Metiisto::Base Metiisto::Taggable);
################################################################################
__PACKAGE__->table('notes');

__PACKAGE__->columns(Primary   => qw/id/);
__PACKAGE__->columns(Essential => qw/title is_favorite is_encrypted/);
__PACKAGE__->columns(Body      => qw/body/);
__PACKAGE__->columns(Dates     => qw/created_date updated_date deleted_date/);

__PACKAGE__->has_a_datetime('created_date');
__PACKAGE__->has_a_datetime('updated_date');
__PACKAGE__->has_a_datetime('deleted_date');

__PACKAGE__->add_trigger(before_create => \&_trigger_before_create);
__PACKAGE__->add_trigger(before_update => \&_trigger_before_update);

__PACKAGE__->init_tagging();
################################################################################
sub recent
{
    my $class = shift;
    
    my @recent_notes = Metiisto::Note->search_where(
        {
            is_favorite => {'=', 0},
            deleted_date  => {'is', undef},
        },
        {
            order_by => 'created_date desc',
            limit_dialect => 'LimitOffset',
            limit => 5,
        }
    );
    
    return(wantarray ? @recent_notes : \@recent_notes);
}
################################################################################
sub favorites
{
    my $class = shift;
    my @fav_notes = Metiisto::Note->search_where(
        {
            is_favorite => {'=', 1},
            deleted_date  => {'is', undef},
        },
        { 
            order_by => 'created_date asc',
            # limit_dialect => 'LimitOffset',
            # limit => 5
        }
    );
    
    return(wantarray ? @fav_notes : \@fav_notes);
}
################################################################################
sub notebooks
{
    my $class = shift;
    
    my @results = Metiisto::TaggedObject->search_tags_by_type("Metiisto::Note");
    my @notebooks = sort map {$_->tag()->name()} @results;
    
    return (wantarray ? @notebooks : \@notebooks);
}
################################################################################
sub encrypt
{
    my $this = shift;
    my %args = @_;

    my $cipher = Crypt::CBC->new(
        -key    => $args{key},
        -cipher => 'Blowfish'
    );

    my $new_body = $cipher->encrypt_hex($this->body());

    $this->is_encrypted(1);
    $this->body($new_body);
}
################################################################################
sub decrypt
{
    my $this = shift;
    my %args = @_;

    my $cipher = Crypt::CBC->new(
        -key    => $args{key},
        -cipher => 'Blowfish'
    );

    my $new_body = $cipher->decrypt_hex($this->body());

    $this->is_encrypted(0);
    $this->body($new_body);
}
################################################################################
sub _trigger_before_create
{
    my $this = shift;
    my $now  = Metiisto::Util::DateTime->now();

    $this->created_date($now);
    $this->updated_date($now);
}
################################################################################
sub _trigger_before_update
{
    my $this = shift;
    my $now  = Metiisto::Util::DateTime->now();

    $this->updated_date($now);
}
################################################################################
1;
