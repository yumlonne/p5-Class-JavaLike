use strict;
use warnings;
use utf8;

use Test::Spec;

use Class::JavaLike;

describe 'Class::JavaLike syntax' => sub {
    it 'class syntax' => sub {
        class Test1 => sub {};
        ok 1;
    };

    it 'extended class syntax(single)' => sub {
        class Test2 => extends Test1 => sub {};
        ok 1;
    };

    it 'extended class syntax(chain)' => sub {
        class Animal => sub {};
        class Bear => extends Animal => sub {};
        class PolarBear => extends Bear => sub {};
        ok 1;
    };

    it 'public variable syntax' => sub {
        class Test4 => sub {
            public var => qw(x y z);
        };
        ok 1;
    };

    it 'constructor syntax' => sub {
        class Test5 => sub {
            public new => Test4 => constructor {
                my $self = shift;
                return $self;
            };
        };
        ok 1;
    };

    it 'method syntax' => sub {
        class Test6 => sub {
            public hoge => method {
                return 'hoge';
            };
        };
        is classof('Test6')->hoge, 'hoge';
    };

    it 'mix syntax' => sub {
        class Point2D => sub {
            public var => qw(x y);
            public new => Int => Int => Point2D => constructor {
                my ($self, $x, $y) = @_;
                $self->x = $x;
                $self->y = $y;
                return $self;
            };

            public add => Point2D => Point2D => method {
                my ($self, $that) = @_;
                return classof('Point2D')->new($self->x + $that->x, $self->y + $that->y);
            };
        };

        class Point3D => extends Point2D => sub {
            public var => 'z';
            public new => Int => Int => Int => Point3D => constructor {
                my ($self, $x, $y, $z) = @_;
                $self->x = $x;
                $self->y = $y;
                $self->z = $z;
                return $self;
            };

            public add => Point3D => Point3D => method {
                my ($self, $that) = @_;
                return classof('Point3D')->new($self->x + $that->x, $self->y + $that->y, $self->z + $that->z);
            };
        };

        # Point2D
        my $p_1_5  = classof('Point2D')->new(1, 5);
        my $p_3_11 = classof('Point2D')->new(3, 11);
        my $p_4_16 = $p_1_5->add($p_3_11);
        is $p_4_16->x, 4;
        is $p_4_16->y, 16;

        # Point3D
        my $p_2_6_11 = classof('Point3D')->new(2, 6, 11);
        my $p_5_2_7  = classof('Point3D')->new(5, 2,  7);
        my $p_7_8_18 = $p_2_6_11->add($p_5_2_7);
        is $p_7_8_18->x, 7;
        is $p_7_8_18->y, 8;
        is $p_7_8_18->z, 18;

        # mixed
        my $p_11_24 = $p_4_16->add($p_7_8_18);
        is $p_11_24->x, 11;
        is $p_11_24->y, 24;
    };

};

runtests unless caller;
