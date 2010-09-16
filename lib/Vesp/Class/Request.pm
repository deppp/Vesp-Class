package Vesp::Class::Request;
use common::sense;
use Carp;

use Vesp::Class;

sub new {
    my ($class, %args) = @_;
    my $self = bless \%args, $class;

    $self;
}

sub controller {
    my $name = shift;
    $Vesp::Class::CLASS{$name} || $Vesp::Class::ROUTE{$name};
}

1;
