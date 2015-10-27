package Metiisto::Controller::Base;
################################################################################
use strict;

use Dancer2 appname => 'metiisto';

use Clone qw(clone);
use Data::Page;
use Lingua::EN::Inflect qw(PL);
use SQL::Abstract;

my %LIST;
use constant LIST_DEFAULTS => {
    entries_per_page   => 18,
    filter_fields      => undef,
    order_by           => 'id',
    default_conditions => undef,
};
################################################################################
sub new
{
    my $class = shift;
    my $this  = {};
    
    bless $this, $class;
    
    return ($this);
}
################################################################################
sub init
{
    my $class = shift;
    $class->declare_routes();
}
################################################################################
sub setup_list_handler
{
    my $class = shift;
    my %args = @_;

    foreach my $key (keys %{LIST_DEFAULTS()})
    {
        $LIST{$class}->{$key} = $args{$key} || LIST_DEFAULTS->{$key};
    }
}
################################################################################
sub list
{
    my $this       = shift;
    my $controller = ref($this);
    my $model      = $this->_model();

    my $total = 0;
    my @conditions;

    # Add search filters
    if (defined $LIST{$controller}->{filter_fields} and params->{filter_text})
    {
        foreach my $ff (@{$LIST{$controller}->{filter_fields}})
        {
            my $ff_cond = clone($LIST{$controller}->{default_conditions}) || {};
            $ff_cond->{$ff} = { 'regexp', params->{filter_text} };

            push @conditions, $ff_cond;
        }
    }
    else
    {
        my $cond = $LIST{$controller}->{default_conditions} || {1=>1};
        push @conditions, $cond;
    }

    # Determine total records based on conditions
    my $sql_a = SQL::Abstract->new();
    my @where = $sql_a->where(\@conditions);
    $total = $model->count_where((shift @where), \@where);

    my $page = Data::Page->new();
    $page->total_entries($total);
    $page->entries_per_page($LIST{$controller}->{entries_per_page});
    $page->current_page(params->{page} || 1);

    my @items = $model->search_where(
        \@conditions,
        {
            limit_dialect => 'LimitOffset',
            limit    => $LIST{$controller}->{entries_per_page},
            offset  => $page->first() ? $page->first() - 1 : 0,
            order_by => $LIST{$controller}->{order_by},
        }
    );

    my $out = template vars->{controller}.'/list', {
        items => \@items,
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
    my %args = @_;

    my $obj = $args{item} || {};
    my $tmpl_vars = $args{template_vars} || {};

    my $out = template vars->{controller}.'/new_edit', {
        item => $obj,
        %$tmpl_vars,
    };

    return ($out);
}
################################################################################
sub create
{
    my $this = shift;

    my $model = $this->_model();

    my $data = {};
    my $prefix = PL(vars->{controller});
    
    my $params = $this->_munge_params(params => {params()});
    foreach my $p (keys %{$params})
    {
        next unless $p =~ /^$prefix\.(.*)$/;
        my $attr = $1;

        my $value = $params->{$p};
        if (!(defined $value) or $value eq 'NULL' or $value eq '') {
            $value = undef;
        }

        $data->{$attr} = $value;        
    }

    my $obj = $model->insert($data);
    die "Error creating $model" unless $obj;

    $obj->update_tags(tags => params()->{$prefix.'[tags][]'})
        if $obj->isa('Metiisto::Taggable');

    my $out = $this->_post_create_action($obj);

    return ($out);
}
################################################################################
sub show
{
    my $this = shift;
    my %args = @_;
    
    my $model = $this->_model();
    
    my $obj = $model->retrieve($args{id});
    my $out = template vars->{controller}.'/show', { item => $obj };

    return ($out);
}
################################################################################
sub edit
{
    my $this = shift;
    my %args = @_;

    my $model = $this->_model();
    my $obj   = $model->retrieve($args{id});

    my $tmpl_vars = $args{template_vars} || {};
    my $out = template vars->{controller}.'/new_edit', {
        item => $obj,
        %$tmpl_vars,
    };

    return ($out);
}
################################################################################
sub update
{
    my $this = shift;
    my %args = @_;

    my $model = $this->_model();   
    my $obj   = $model->retrieve(id => $args{id});

    my $prefix = PL(vars->{controller});

    $obj->update_tags(tags => params()->{$prefix.'[tags][]'})
        if $obj->isa('Metiisto::Taggable');

    my $params = $this->_munge_params(params => {params()});
    foreach my $p (keys %{$params})
    {
        next unless $p =~ /^$prefix\.(.*)$/;
        my $attr = $1;

        my $value = $params->{$p};
        if (!(defined $value) or $value eq 'NULL' or $value eq '') {
            $value = undef;
        }

        $obj->$attr($value);
    }

    if (defined $args{pre_obj_update})
    {
        $args{pre_obj_update}->($obj);
    }

    my $cnt = $obj->update();
    die "Error saving $model($args{id})" unless $cnt;

    my $out = redirect "/".vars->{controller}."/$args{id}";

    return ($out);
}
################################################################################
sub delete
{
    my $this = shift;
    my %args = @_;

    my $model = $this->_model();
    my $obj = $model->retrieve(id => $args{id});
    $obj->delete();

    #my $url = '/'.vars->{controller};
    #$url .= "?filter_text=".params->{filter_text} if params->{filter_text};
    #my $out = redirect $url;
    #return ($out);

    return (redirect request->referer);
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
            $out = template 'error', {
                message => "Unknown Action [$action] for /$base_url",
            };
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
##############################################################################
sub _post_create_action
{
    my $this = shift;
    my $obj  = shift;

    return (redirect "/".vars->{controller}."/".$obj->id());
}
################################################################################
sub _munge_params
{
    my $this = shift;
    my %args = @_;

    return ($args{params});
}
################################################################################
sub _model
{
    my $this = shift;
    
    my $model = ucfirst(PL(vars->{controller}));
    return ("Metiisto::$model");
}
################################################################################
1;
