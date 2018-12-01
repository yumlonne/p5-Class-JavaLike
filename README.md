# NAME

Class::JavaLike - It's new $module

# SYNOPSIS

    use Class::JavaLike;
    use Class::JavaLike::Classes;
    use Types::Standard;

    # define class
    class Point2D => sub {
        # define variables
        public var => qw(x y);

        # define constructor
        public new => args[Int, Int] => returns[classes->Point2D] => constructor {
            my ($self, $x, $y) = @_;
            $self->x = $x;
            $self->y = $y;
            return $self
        };

        # define method
        public add => args[classes->Point2D] => returns[classes->Point2D] => method {
            my ($self, $that) = @_;
            return classes->Point2D->new($self->x + $that->x, $self->y + $that->y);
        };

        public negate => args[] => returns[classes->Point2D] => method {
            my $self = shift;
            return classes->Point2D->new(-$self->x, -$self->y);
        };
    };

    # usage
    my $p1  = classes->Point2D->new(10, 20);
    my $p2  = classes->Point2D->new(22, 18);
    my $res = $p1->add($p2);

    say $res->x;    # -> 32
    say $res->y;    # -> 38

# DESCRIPTION

Class::JavaLike is ...

# LICENSE

Copyright (C) yumlonne.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

yumlonne <yumlonne@gmail.com>
