Hypatia
=======

**Note:** The files for the distribution itself (ie what you'd get from [CPAN](https://metacpan.org/release/Hypatia)) are available in the folder `Hypatia-$version` (where `$version` represents the version number).

Hypatia is a new data visualization API written in Perl.  It takes advantage of several Modern Perl features, including [Moose](https://metacpan.org/module/Moose) and [Dist::Zilla](https://metacpan.org/module/Dist::Zilla) (in fact, as of the time of this writing, the only code committed is for a Dist::Zilla build).

For reporting and analysis of data, it's often useful to have charts and graphs of various kinds:  line graphs, bar charts, histograms, etc.  Of course, CPAN has modules for data visualization--in fact, there are [quite](https://metacpan.org/module/Chart::Clicker) [a](https://metacpan.org/module/GD::Graph) [few](https://metacpan.org/module/GraphViz2) [of](https://metacpan.org/module/Statistics::R) [them](https://metacpan.org/module/Chart::Gnuplot), each with different features and wildly different syntaxes.  The aim of Hypatia is to provide a layer between DBI and these data visualization modules, so that one can get a basic, "no-frills" chart with as little knowledge of the syntax of the particular data visualization package as possible.

So, for example, to get a line graph in [Chart::Clicker](https://metacpan.org/module/Chart::Clicker), one could do this:

<pre>
use strict;
use warnings;
use Hypatia;

my $hypatia=Hypatia->new({
    back_end=>"Chart::Clicker",
    graph_type=>"Line",
    dbi=>{
	dsn=>"dbi:MySQL:dbname=database;host=localhost",
	username=>"jdoe",
	password=>"sooperseekrit",
	query=>"select DATE(time_of_sale) as date,sum(revenue) as daily_revenue
	from widget_sales
	group by DATE(time_of_sale)"
    },
    columns=>{"x"=>"date","y"=>"daily_revenue"}
});

#grabs data from the query and puts it into a Chart::Clicker line graph
my $cc=$hypatia->chart;

#Since $cc is a Chart::Clicker object, we can now do whatever we want to it.

$cc->title->text("Total Daily Revenue for Widget Sales");
$cc->write_output("daily_revenue.png");

</pre>

At the moment there is only limited support for part of Chart::Clicker, but this will expand to include support for:

* [GraphViz2](https://metacpan.org/module/GraphViz2)
* R (via [Statistics::R](https://metacpan.org/release/Statistics-R)).
* [GD::Graph](https://metacpan.org/module/GD::Graph) (including 3D support with [GD::Graph3D](https://metacpan.org/module/GD::Graph3d)).
* And many more!

