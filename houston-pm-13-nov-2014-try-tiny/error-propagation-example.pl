package Local::Error;

use strict;
use warnings;

sub new {
    my $pkg    = shift;
    my $params = shift;
    my $self   = bless $params, $pkg;
    return $self;
}

sub PROPAGATE {
    my ( $self, $file, $line ) = @_;

    $self->{chain} = [] unless ref $self->{chain};
    push @{ $self->{chain} }, [ $file, $line, $self->{err} ];
    ++$self->{count};

    $self;
}

package main;

use Data::Dumper;
use Try::Tiny;

eval {
    eval {
        eval {
            eval { die Local::Error->new( { err => 'barred' } ) };
            die;
        };
        die;
    };
    die;
};

print Data::Dumper::Dumper($@);

try {
    die Local::Error->new( { err => 'derped' } );
}
catch {
    try {
        $_->PROPAGATE( __FILE__, __LINE__ );
        die $_;
    }
    catch {
        try {
            $_->PROPAGATE( __FILE__, __LINE__ );
            die $_;
        }
        catch {
            $_->PROPAGATE( __FILE__, __LINE__ );
            try {
                die $_;
            }
            catch {
                print Data::Dumper::Dumper($_);
            }
        }
    }
};

1;

__END__
