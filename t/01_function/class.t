use strict;
use warnings;
use utf8;

use Test::Spec;
use Class::JavaLike;
use Types::Standard -types;

describe 'about `class` function' => sub {
    before all => sub {
        class Point => sub {
            private var => qw(x y);

            public new => args[Int, Int] => returns[Any] => constructor {
                my ($self, $x, $y) = @_;
                $self->x = $x;
                $self->y = $y;
                return $self;
            };

            public add => args[classof('Point')] => returns[classof('Point')] => method {
                my ($self, $that) = @_;
                my $hoge = classof('Point')->new($self->x + $that->x, $self->y + $that->y);
                return $hoge;
            };

            public get_x => Int => method { shift->x; };
            public get_y => Int => method { shift->y; };
        };
    };

    it 'ok' => sub {
        my $p1 = classof('Point')->new(1,3);
        my $p2 = classof('Point')->new(2,5);
        my $p3 = $p1->add($p2);
        is $p3->get_x, 3;
        is $p3->get_y, 8;
    };
};

runtests unless caller;
