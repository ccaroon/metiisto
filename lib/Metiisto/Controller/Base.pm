package Metiisto::Controller::Base;
################################################################################
use Dancer ':syntax';
################################################################################
sub new
{
    my $class = shift;
    my $this  = {};
    
    bless $this, $class;
    
    return ($this);
}
################################################################################
# Declare the standard routes for all controllers.
################################################################################
sub declare_routes
{
    my $class = shift;

    my $base_url = lc $class;
    $base_url =~ s/.*:://g;
    
    # List
    get "/$base_url" => sub {
        my $c = $class->new();
        my $out = $c->list();
        return ($out);
    };

    # Create
    post "/$base_url" => sub {
        my $c = $class->new();
        my $out = $c->create();
        return ($out);
    };

    # Record Based Actions (show, delete, etc...)
    get "/$base_url/:id/:action" => sub {
        my $c = $class->new();
        my $action = params->{action};

        my $out;
        if ($c->can($action))
        {
            $out = $c->$action(id => params->{id});
        }
        else
        {
            $out = "Unknown Action [$action] for /$base_url";
        }

       return ($out);
    };

    # New
    get "/$base_url/new" => sub {
        my $c = $class->new();
        my $out = $c->new_record();
        return ($out);
    };

    # Show
    get "/$base_url/:id" => sub {
        my $c = $class->new();
        my $out = $c->show(id => params->{id});
        return ($out);
    };
    
    # Update
    post "/$base_url/:id" => sub {
        my $c = $class->new();
        my $out = $c->update(id => params->{id});
        return ($out);
    };
}
################################################################################
1;
