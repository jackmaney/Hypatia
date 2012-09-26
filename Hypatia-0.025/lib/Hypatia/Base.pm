package Hypatia::Base;
{
  $Hypatia::Base::VERSION = '0.025';
}
use Moose;
use Hypatia::DBI;
use Hypatia::Columns;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

#ABSTRACT: An Abstract Base Class




coerce "Hypatia::DBI", from "HashRef", via {Hypatia::DBI->new($_)};


has 'dbi'=>(isa=>"Hypatia::DBI",is=>'rw',coerce=>1,predicate=>'use_dbi',handles=>['dbh']);


subtype 'HypatiaColumns' => as maybe_type("Hypatia::Columns");
coerce "HypatiaColumns",from "HashRef", via {Hypatia::Columns->new({columns=>$_})};

#Note: the attribute here is named 'cols' so that we can use the 'columns' handle from the corresponding Hypatia::Columns object.
#We use BUILDARGS to do the ol' switcheroo.
has 'cols'=>(isa=>'HypatiaColumns',is=>'rw',coerce=>1,handles=>[qw(columns using_columns)],default=>sub{Hypatia::Columns->new});

around BUILDARGS=>sub
{
	my $orig  = shift;
	my $class = shift;
	my $args=shift;
	
	confess "Argument is not a hash reference" unless ref $args eq ref {};
	
	if(exists $args->{columns})
	{
		$args->{cols}=$args->{columns};
		delete $args->{columns};
	}
	
	return $class->$orig($args);
};





sub _guess_columns
{
	confess "The attribute 'columns' is required";
}

# This is a setup method for methods overriding _guess_columns.
# Yes, I know about the Moose keyword 'after', but I'm not
# sure offhand how to run the code in _setup_guess_columns
# except if _guess_columns is being overridden.
sub _setup_guess_columns
{
	my $self=shift;
	
	my $query=$self->dbi->_build_query;
	
	my $dbh=$self->dbh;
	my $sth=$dbh->prepare($query) or die $dbh->errstr;
	$sth->execute or die $dbh->errstr;
	
	my @return = @{$sth->{NAME}};
	
	$sth->finish;
	
	return \@return;
}


1;

__END__

=pod

=head1 NAME

Hypatia::Base - An Abstract Base Class

=head1 VERSION

version 0.025

=head1 ATTRIBUTES

=head2 dbi

If the data source is from DBI, then this attribute contains the information necessary to connect to the database (C<dsn>,C<username>, and C<password>) along with the source of the data within the database (C<query> or C<table>).  This hash reference is passed directly into a L<Hypatia::DBI> object.  Note that if a connection is successful, the resulting database handle is passed into a C<dbh> attribute.  See L<Hypatia::DBI> for more information.

=head2 columns

This is a hash reference whose keys represent the column types (often C<x> and C<y>) and the values of which represent column names from the data that correspond to the given column type.

=head2 input_data

If your data source isn't from a database, then you can store your own data in this attribute.  The requirements will vary depending on subclass.

=head2 columns

This is a hash reference that assigns a sub-class dependent column type (e.g. C<x> or C<y>) to one or more columns.  For example, 

	columns=>{
		x=>"time_of_day",
		y=>"num_widget_sales"
	}

could be used in a line graph to indicate that the "time_of_day" column goes on the x-axis and the "num_widget_sales" column goes on the y-axis.  On the other hand, for a bubble chart, you might have

	columns=>{
		x=>"total_units_sold",
		y=>["pct_growth_over_last_year","pct_growth_over_last_month"],
		size=>["pct_yearly_revenue","pct_monthly_revenue"]
	}

to indicate a bubble chart with two sets of y values each having two different columns to indicate size, and all with a single set of x values.

B<Note:> The exact requirements of this attribute will vary depending on which sub-class you're calling.  Consult the relevant documentation.

=head1 INTERNAL METHODS

=head2 _guess_columns

This can be thought of as a (quasi) abstract method. By default, this method simply invokes a L<confession|Carp>, but it's meant to be overridden by submodules.

=head1 AUTHOR

Jack Maney <jack@jackmaney.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Jack Maney.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
