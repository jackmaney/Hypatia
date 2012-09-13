package Hypatia::Base;
use Moose;
use Hypatia::DBI;
use Hypatia::Columns;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

#ABSTRACT: An Abstract Base Class



=attr dbi

If the data source is from DBI, then this attribute contains the information necessary to connect to the database (C<dsn>,C<username>, and C<password>) along with the source of the data within the database (C<query> or C<table>).  This hash reference is passed directly into a L<Hypatia::DBI> object.  Note that if a connection is successful, the resulting database handle is passed into a C<dbh> attribute.  See L<Hypatia::DBI> for more information.

=cut

coerce "Hypatia::DBI", from "HashRef", via {Hypatia::DBI->new($_)};


has 'dbi'=>(isa=>"Hypatia::DBI",is=>'rw',coerce=>1,predicate=>'use_dbi',handles=>['dbh']);

=attr columns

This is a hash reference whose keys represent the column types (often C<x> and C<y>) and the values of which represent column names from the data that correspond to the given column type.

=cut

subtype 'HypatiaColumns' => as class_type("Hypatia::Columns");
coerce "HypatiaColumns",from "HashRef", via {Hypatia::Columns->new({columns=>$_})};

#Note: the attribute here is named 'cols' so that we can use the 'columns' handle from the corresponding Hypatia::Columns object.
#We use BUILDARGS to do the ol' switcheroo.
has 'cols'=>(isa=>'HypatiaColumns',is=>'rw',coerce=>1,handles=>['columns'],predicate=>'using_columns');

around BUILDARGS=>sub
{
	my $orig  = shift;
    my $class = shift;
    my $args=shift;
	
	confess "Argument is not a hash reference" unless ref $args eq ref {};
	
	$args->{cols}=$args->{columns};
	delete $args->{columns};
	
	return $class->$orig($args);
};

=attr input_data

If your data source isn't from a database, then you can store your own data in this attribute.  The requirements will vary depending on subclass.

=cut


=attr columns

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

=cut



1;
