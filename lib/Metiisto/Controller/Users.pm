package Metiisto::Controller::Users;
################################################################################
use strict;

use Dancer2 appname => 'metiisto';

use Metiisto::User;

use base 'Metiisto::Controller::Base';
################################################################################
sub login
{
    my $this = shift;

    my $out;

    my $is_create = 0;
    if (Metiisto::User->count() == 0)
    {
        if (params->{name} && params->{user_name}
            && params->{password} && params->{email})
        {
            Metiisto::User->add(
                name      => params->{name},
                user_name => params->{user_name},
                password  => params->{password},
                email     => params->{email}
            );
        }
        else
        {
            $is_create = 1;
        }
    }
    
    # if user and pass, then try to login
    if (params->{user_name} and params->{password})
    {
        my $user = Metiisto::User->authenticate(
            user_name => params->{user_name},
            password  => params->{password}
        );

        if ($user)
        {
            session user => $user;
            $out = redirect '/home';
        }
        else
        {
            my $login_error = "Login Failed!";
            $out = template 'users/login', {
                is_create => $is_create,
                login_error => $login_error,
            };
        }
    }
    # else, render login template
    else
    {
        $out = template 'users/login', {
            is_create => $is_create,
        };
    }

    return ($out);
}
################################################################################
sub edit
{
    my $this = shift;

    my $out;
    my $user = Metiisto::User->retrieve(id => params->{id});
    my $prefs = $user->preferences();
    if (request->method() eq "POST")
    {
        foreach my $p (keys %{params()})
        {
            next unless $p =~ /^user\.(.*)$/;
            my $attr = $1;

            if ($attr =~ /^preferences\.(.*)$/)
            {
                my $pref_name = $1;
                my $pref = $prefs->{$pref_name};
                $pref->value(params->{$p});
            }
            else
            {
                $user->$attr(params->{$p});
            }
        }
        map { $_->update() or die "Error saving Preference(".$_->name().")" }
            values %$prefs;
        $user->update() or die "Error saving User(".params->{id}.")";

        $out = redirect request->referer;
    }
    else
    {
        $out = template 'users/edit', {
            user       => $user,
            themes     => Metiisto::Preference->THEMES,
            about      => {
                version      => $metiisto::VERSION,
                perl_version => $^V
            }
        };
    }

    return ($out);
}
################################################################################
sub logout
{
    my $this = shift;

    app->destroy_session();
    my $out = template 'users/login';

    return ($out);
}
################################################################################
sub declare_routes
{
    my $class = shift;
    
    any ['get', 'post'] => '/users/login' => sub {

        my $c = Metiisto::Controller::Users->new();
        my $out = $c->login();

        return ($out);
    };
    
    get '/users/logout' => sub {

        my $c = Metiisto::Controller::Users->new();
        my $out = $c->logout();

        return ($out);
    };
    
    any ['get','post'] =>  '/users/:id/:action' => sub {
        my $action = params->{action};
        
        my $c = Metiisto::Controller::Users->new();
        my $out = $c->$action();

        return ($out);
    };

}
################################################################################
1;
