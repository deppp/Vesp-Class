package Vesp::Class;
use common::sense;
use Carp;

require Exporter;
our @ISA       = 'Exporter';
our @EXPORT    = 'vesp_app';
our @EXPORT_OK = 'vesp_auto_app';

use Vesp::Simple;

our (%CLASS, %ROUTE) = ();

sub vesp_app {
    my $config = pop;
    my (%args) = @_;

    vesp_http_server
        $args{host} || undef,
        $args{port} || croak "port is required",
        dispatcher => 'Vesp::Dispatcher::Advanced';
        
    for (my $i = 0; $i <= $#{ $config }; $i = $i + 2) {
        my $route = $config->[$i];
        my $class = $config->[$i + 1];

        eval "require $class" || croak "$@";
        my $instance = $class->new;
        
        foreach my $method (qw/get post put delete/) {
            if ($instance->can($method)) {
                vesp_route
                    $route,
                    method => uc($method),
                    sub {
                        $instance->$method(@_)
                    };
            }
        }

        $ROUTE{$route} = $instance;
        $CLASS{$class} = $instance;
    }
}

sub vesp_auto_app {
    my $config = pop;
    my (%args) = @_;

    my $namespace = delete $args{namespace};
    my @data = ();
    foreach my $route (@{ $config }) {
        push @data, $route;
        $route =~ s{/(.)}{::\u$1}g;
        $route =~ s{^::}{};
        $route =~ s{::$}{};
        push @data, $namespace . '::' . $route;
    }

    vesp_app %args, \@data;
}

1;
