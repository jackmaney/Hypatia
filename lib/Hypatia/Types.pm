package Hypatia::Types;
use MooseX::Types -declare=>[
    qw(
	PositiveNum
	PositiveInt
	HypatiaDBI
    )
];
use MooseX::Types::Moose qw(Num Int HashRef);

#ABSTRACT: A Type Library for Hypatia

subtype PositiveNum, as Num, where {$_ > 0};

subtype PositiveInt, as Int, where { $_ > 0};

subtype HypatiaDBI, as class_type("Hypatia::DBI");
coerce HypatiaDBI, from HashRef, via { Hypatia::DBI->new($_) };

1;