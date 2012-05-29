package Metiisto::Note;
################################################################################
use strict;

use Crypt::CBC;

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

__PACKAGE__->init_tagging();
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
1;
