package Class::JavaLike;
use 5.008001;
use strict;
use warnings;
use Data::Dumper;

use UNIVERSAL::require;
use Types::Standard -types;

use Exporter 'import';
our @EXPORT = qw(
    abstract
    abstract_class
    args
    returns
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

sub args($) { return shift; }
sub returns($) { return shift; }

sub constructor(&) {
    my $sub = shift;
    return +{ type => 'constructor', sub => $sub };
}
sub extends($) { return shift; }
sub method(&) {
    my $sub = shift;
    return +{ type => 'method', sub => $sub };
}
sub override {}

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
    my ($args_constraint, $returns_constraint) = @args;
    my $class = $_;
    no strict;

    my $access_modifier = _access_modifier($access_level);

    if ($last_hash->{type} eq 'method') {
        # FIXME: type constraint
        # FIXME: redefine error
        unshift @$args_constraint, $class;
        my %class_constraint;
        for my $idx (0..scalar($#$args_constraint)) {
            my $constraint = $args_constraint->[$idx];
            next if ref $constraint eq 'Type::Tiny';
            $args_constraint->[$idx] = Any;
            $class_constraint{$idx} = $constraint;
        }

        *{ "${class}::${method_name}" } = sub {
            $access_modifier->();
            Tuple($args_constraint)->(\@_);
            while (my ($idx, $class) = each %class_constraint) {
                die "$_[$idx] ain't a $class" if not $_[$idx]->isa($class);
            }
            my $returns = $last_hash->{sub}->(@_);
            # TODO return type constraint
            #Tuple($returns_constraint)->([$returns]);
            return $returns;
        };
        return;
    }
    # constructor
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

    #    _transplant_methods($class_name, $parent);
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

=encoding utf-8

=head1 NAME

Class::JavaLike - It's new $module

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Class::JavaLike is ...

=head1 LICENSE

Copyright (C) yumlonne.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

yumlonne E<lt>yumlonne@gmail.comE<gt>

=cut

