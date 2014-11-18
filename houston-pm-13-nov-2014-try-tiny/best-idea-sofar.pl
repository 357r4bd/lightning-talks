use strict;
use Try::Tiny;
use Data::Dumper ();

sub do_this {
    my $X = bless { err => 'do_this' }, 'X::Special';
    die $X;
}

sub do_that {
    my $X = bless { err => 'do_that' }, 'X::Special';
    die $X;
}

sub last_try {
    my $X = bless { err => 'last_try' }, 'X::Special';
    die $X;
}

# try/catch with retry fallbacks, no nesting, can be generalized

# initial try
my $result = try { do_this() } catch { $_ };

# retry 1
$result = try { do_that() } catch { $_ } if ref $result eq 'X::Special';

# retry 2
$result = try { last_try() } catch { $_ } if ref $result eq 'X::Special';

die $result if ref $result eq 'X::Special';

__END__
