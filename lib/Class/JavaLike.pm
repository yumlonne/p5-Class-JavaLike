package Class::JavaLike;
use 5.008001;
use strict;
use warnings;

use Exporter 'import';
our @EXPORT = qw(
    abstract
    abstract_class
    constructor
    class
    classof
    extends
    method
    override
    public
    protected
    private
);
our $VERSION = "0.01";

=pod
keywords

- Class::JavaLike
  - abstract_class
  - class
- abstract
- constructor
- extends
- method
- override
- public

=cut

sub class {
    my ($class_name, @after) = @_;
    my $body = pop @after;
    my $extends = \@after;

    _build_class({
        class_name => $class_name,
        extends    => $extends,
        body       => $body,
    });
}

# TODO
sub abstract {}
sub abstract_class {}
sub constructor(&) {
    my $sub = shift;
    return +{ type => 'constructor', sub => $sub };
}
sub extends { return shift; }
sub method(&) {
    my $sub = shift;
    return +{ type => 'method', sub => $sub };
}
sub override {}

=pod
USAGE:
    public hoge => Any => Any => Int => $method_type {};
    hoge: method name
    Any => Any => Int: arg types,,, => result types
    $method_type: method | constructor

    public $var_type @vars;

=cut
sub public {
    my @args = @_;
    my $last = $args[-1];

    if (ref $last eq 'HASH' && exists $last->{type} && $last->{type} =~ /method|constructor/) {
        return _method('public', @_);
    }
    return _var('public', @_);
}

sub protected {
    my @args = @_;
    my $last = $args[-1];

    if (ref $last eq 'HASH' && exists $last->{type} && $last->{type} =~ /method|constructor/) {
        return _method('protected', @_);
    }
    return _var('protected', @_);
}

sub private {
    my @args = @_;
    my $last = $args[-1];

    if (ref $last eq 'HASH' && exists $last->{type} && $last->{type} =~ /method|constructor/) {
        return _method('private', @_);
    }
    return _var('private', @_);
}

sub _method {
    my @args = @_;
    my $access_level = shift @args;
    my $method_name = shift @args;
    my $last_hash = pop @args;
    my $class = $_;
    no strict;

    my $access_modifier = _access_modifier($access_level);

    if ($last_hash->{type} eq 'method') {
        # FIXME: type constraint
        # FIXME: redefine error
        *{ "${class}::${method_name}" } = sub {
            $access_modifier->();
            $last_hash->{sub}->(@_);
        };
        return;
    }
    # constructor
    # XXX: インスタンスを渡すためにsubでWrapしてるが
    # callerが書き換わってしまいAccessModifierが働かない
    *{ "${class}::${method_name}" } = sub {
        $access_modifier->();
        my ($class, @args) = @_;
        my $instance = bless +{} => $class;
        $last_hash->{sub}->($instance, @args);
    };
}

sub _var {
    my ($access_level, $var_type, @vars) = @_;
    my $class = $_;

    my $access_modifier = _access_modifier($access_level);

    no strict;
    if ($var_type eq 'var') {
        for my $var (@vars) {
            *{ "${class}::${var}" } = sub : lvalue {
                $access_modifier->();
                shift->{$var}
            };
        }
    }
    elsif ($var_type eq 'val') {
        for my $var (@vars) {
            *{ "${class}::${var}" } = sub {
                $access_modifier->();
                shift->{$var}
            };
        }
    }
    else {
        die "unknown variable type $var_type";
    }

}

sub _build_class {
    my $params = shift;
    my ($class_name, $extends, $body) = @$params{qw(class_name extends body)};

    for my $parent (@$extends) {
        _set_extends($class_name, $parent);
    }
    local $_ = classof($class_name);
    $body->();
}

sub _set_extends {
    my ($class_name, $parent) = @_;
    $class_name = classof($class_name);
    $parent     = classof($parent);

    _transplant_methods($class_name, $parent);
    $class_name->require($parent);
    eval sprintf(q{push @%s::ISA, '%s'}, $class_name, $parent);
}

sub _transplant_methods {
    my ($class_name, $parent) = @_;

    no strict 'refs';
    my %symbol = eval "%${parent}::";
    my @methods = grep { defined &{"${parent}::$_"} } keys %symbol;

    for my $method (@methods) {
        *{"${class_name}::$method"} = $symbol{$method};
    }
}

# Access Modifiers
sub _access_modifier {
    my $level = shift;
    return \&_public if $level eq 'public';
    return \&_protected if $level eq 'protected';
    return \&_private if $level eq 'private';

    die 'ERROR';
}
sub _public {}  # nothing to do

sub _protected {
    my ($c0_pkg, $c0_filename, $c0_line, $c0_sub) = caller(0);
    my ($c1_pkg, $c1_filename, $c1_line)          = caller(2);
    die "$c0_sub is Protected at $c1_filename line $c1_line.\n"
        if not $c1_pkg->isa($c0_pkg);
}

sub _private {
    my ($c0_pkg, $c0_filename, $c0_line, $c0_sub) = caller(0);
    my ($c1_pkg, $c1_filename, $c1_line)          = caller(2);
    die "$c0_sub is Private at $c1_filename line $c1_line.\n"
        if $c1_pkg ne $c0_pkg;
}

sub classof {
    my $class = shift;
    return "Class::JavaLike::Class::$class";
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

