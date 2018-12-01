# NAME

Class::JavaLike - It's new $module

# SYNOPSIS

    use Class::JavaLike;
    use Types::Standard;

    # define class
    class Point2D => sub {
        # define variables
        public var => qw(x y);

        # define constructor
        public new => args[Int, Int] => returns[classof 'Point2D'] => constructor {
            my ($self, $x, $y) = @_;
            $self->x = $x;
            $self->y = $y;
            return $self
        };

        # define method
        public add => args[classof 'Point2D'] => returns[classof 'Point2D'] => method {
            my ($self, $that) = @_;
            return classof('Point2D')->new($self->x + $that->x, $self->y + $that->y);
        };

        public negate => args[] => returns[classof 'Point2D'] => method {
            my $self = shift;
            return classof('Point2D')->new(-$self->x, -$self->y);
        };
    };

    # usage
    my $p1  = classof('Point2D')->new(10, 20);
    my $p2  = classof('Point2D')->new(22, 18);
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
