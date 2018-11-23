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

    it 'extended class syntax(multi)' => sub {
        class Test3 => extends Test1 => extends Test2 => sub {};
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

};

runtests unless caller;
