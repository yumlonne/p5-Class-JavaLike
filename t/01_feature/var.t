use strict;
use warnings;
use utf8;

use Test::Spec;

use Class::JavaLike;
use Class::JavaLike::Classes;

describe 'about function `var`' => sub {
    before all => sub {
        class X => sub {
            public var => 'x';
            public new => [] => [classes->X] => constructor { return shift; }
        };
    };

    it 'can generate accessor(public)' => sub {
        my $instance = classes->X->new;
        ok $instance->can('x');
        is $instance->x, undef;

        $instance->x = 300;
        is $instance->x, 300;
    };

    context 'class has multi instances' => sub {
        it "don't interfere" => sub {
            my $instance1 = classes->X->new;
            my $instance2 = classes->X->new;

            $instance1->x = 100;

            is $instance1->x, 100;
            is $instance2->x, undef;
        };
    };
};

runtests unless caller;
