package Class::JavaLike;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

=pod
keywords

- abstract
- abstract_class
- class
- constructor
- extends
- method
- override
- public

=cut

sub class {
    my ($class_name, @after) = @_;
    my $body = pop @after;
    my @extends = \@after;

    Class::JavaLike::Builder->build_class({
        class_name => $class_name,
        extends    => $extends,
        body       => $body,
    });
}

1;
__END__

abstract_class LinkedList => sub {
    abstract head => type->Any;
    abstract tail => type->LinkedList;
    abstract each => type->Sub => type->Any;

    public from_arrayref => Any => LinkedList => method {
        my ($self, $arrayref) = @_;
        my $size = @$arrayref;
        if ($size == 0) {
            return new('Nil');
        }
        else ($size == 1) {
            return new(Cons => shift $arrayref, new('Nil'));
        }
        else {
            my $linked_list = new('Nil');
            while (my $elem = pop $arrayref) {
                $linked_list = new('Cons' => $elem, $linked_list);
            }
            return $linked_list;
        }
    };
};

class Cons => extends LinkedList => sub {
    readonly (
        head => Any,
        tail => LinkedList,
    );

    constructor Any => LinkedList => Cons => method {
        my ($self, $head, $tail) = @_;
        $self->head = $head;
        $self->tail = $tail;
        $self;
    };

    override each => CODE => Any => method {
        my ($self, $sub) = @_;
        $sub->($self->head);
        $self->tail->each($sub);
    };

};

class Nil => extends LinkedList => sub {
    public head => Any        => method { die 'called Nil->head' }
    public tail => LinkedList => method { die 'called Nil->tail' }

    public new => Nil => constructor {
        my $self = shift;
        return $self;
    };

    override each => CODE => Any => method {
        # nothing
    };
};


1;
__END__

=encoding utf-8

=head1 NAME

Class::JavaLike - It's new $module

=head1 SYNOPSIS

    use Class::JavaLike;

    class LinkedList => sub {

    };


    class Hoge => extends 'Fuga'

=head1 DESCRIPTION

Class::JavaLike is ...

=head1 LICENSE

Copyright (C) yumlonne.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

yumlonne E<lt>yumlonne@gmail.comE<gt>

=cut

