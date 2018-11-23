requires 'perl', '5.008001';
requires 'UNIVERSAL::require' => '0.18';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Spec';
};

