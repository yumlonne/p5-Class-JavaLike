package Class::JavaLike::Classes;
use 5.008001;
use strict;
use warnings;
use Class::JavaLike ();

use Exporter 'import';
our @EXPORT = qw(classes);

sub classes() {
    return __PACKAGE__;
}

our $AUTOLOAD;
sub AUTOLOAD {
    Class::JavaLike::classof((split /::/, $AUTOLOAD)[-1]);
}

1;
