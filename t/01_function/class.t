use strict;
use warnings;
use utf8;

use Test::Spec;
use Class::JavaLike;

describe 'about `class` function' => sub {
    before all => sub {
        class Point => sub {
            public var => qw(x y);

            public new => Int => Int => Point => constructor {
                my ($self, $x, $y) = @_;
                $self->x = $x;
                $self->y = $y;
                return $self;
            };

            public add => Point => Point => method {
                my ($self, $that) = @_;
                return classof('Point')->new($self->x + $that->x, $self->y + $that->y);
            }
        };
    };

    it 'ok' => sub {
        ok 1;

        my $p1 = classof('Point')->new(1,3);
        my $p2 = classof('Point')->new(2,5);
        my $p3 = $p1->add($p2);
        #is $p3->x, 3;
        #is $p3->y, 8;
    };
};

runtests unless caller;
