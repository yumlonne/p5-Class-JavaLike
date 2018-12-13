use strict;
use warnings;
use utf8;

use Test::Spec;
use Test::Exception;

use Types::Standard -types;
use Class::JavaLike;
use Class::JavaLike::Classes;

describe 'about function `val`' => sub {
    before all => sub {
        class X => sub {
            public val 'x';
            public new => [Int] => [classes->X] => constructor {
                my ($self, $x) = @_;
                $self->x = $x;
                return $self;
            };

            public set_x => [Int] => [] => method {
                my ($self, $x) = @_;
                $self->x = $x;
                1;
            };
        };
    };

    it 'can generate accessor(public)' => sub {
        my $instance = classes->X->new(10);
        ok $instance->can('x');

        is $instance->x, 10;
    };

    context 'class has multi instances' => sub {
        it "don't interfere" => sub {
            my $instance1 = classes->X->new(30);
            my $instance2 = classes->X->new(500);

            is $instance1->x, 30;
            is $instance2->x, 500;

            $instance1->set_x(300);

            is $instance1->x, 300;
            is $instance2->x, 500;
        };
    };
};

runtests unless caller;
