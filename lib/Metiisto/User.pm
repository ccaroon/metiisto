package Metiisto::User;
################################################################################
use strict;

use Digest::SHA1 qw(sha1_hex);

use Metiisto::Preference;

use base 'Metiisto::Base';
################################################################################
__PACKAGE__->table('users');
__PACKAGE__->columns(All => qw/
    id name user_name password email
/);
__PACKAGE__->has_many(_prefs => 'Metiisto::Preference');
################################################################################
sub authenticate
{
    my $class = shift;
    my %args = @_;
    
    my $user = $class->retrieve(user_name => $args{user_name});
    if ($user)
    {
        my $expected_passwd = sha1_hex($args{password});
        unless ($user->password() eq $expected_passwd)
        {
            $user = undef;
        }
    }
    
    return ($user);
}
################################################################################
sub preferences
{
    my $this = shift;
    my %args;

    scalar(@_) == 1 ? $args{name} = shift : (%args = @_);

    my @prefs = $this->_prefs();

    my %pref_map;
    map { $pref_map{$_->name()} = $_; } @prefs;

    my $value;
    if ($args{name})
    {
        $value = $pref_map{$args{name}}->value();
    }
    else
    {
        $value = \%pref_map;
    }

    return ($value);
}
################################################################################
sub add
{
    my $class = shift;
    my %args = @_;

    if ($args{name} && $args{user_name}
        && $args{password} && $args{email})
    {
        my $user = $class->insert({
            name      => $args{name},
            user_name => $args{user_name},
            password  => sha1_hex($args{password}),
            email     => $args{email}
        });

        Metiisto::Preference->init_defaults_for_user(user => $user);
    }
}
################################################################################
1;
