package Hypatia::DBI::Test::SQLite;
use Moose;
use DBI;
use Path::Class;

has 'dir'=>(isa=>'Str', is=>'ro',default=>sub{ return $ENV{TMP} ? $ENV{TMP} : "."; });

has 'sqlite_db_file'=>(isa=>'Str',is=>'ro',default=>"hypatia_test.db");

has 'sql_file'=>(isa=>'Str',is=>'ro',lazy=>1,default=>"sqlite.sql");

has [qw(username password)]=>(isa=>'Str',is=>'ro',default=>"");

has 'dbh'=>(isa=>'DBI::db',is=>'ro',lazy=>1,init_arg=>undef
    ,default=>sub{
        my $self=shift;
        my $dbh=DBI->connect("dbi:SQLite:dbname=" . file($self->dir,$self->sqlite_db_file),$self->username,$self->password) or confess DBI->errstr;
        
        return $dbh;
    });


sub BUILD
{
    my $self=shift;
    
    $self->load unless(-e file($self->dir,$self->sqlite_db_file));
}

sub load
{
    my $self=shift;
    my $dbh=$self->dbh;
    my $json=JSON->new;
    
    open(my $read,"<",$self->sql_file) or die $!;
    
    my @sql_lines = <$read>;
    close($read);
    
    my $sql_str = join(" ",@sql_lines);
    
    $dbh->do($sql_str) or die $dbh->errstr;
    
}


__PACKAGE__->meta->make_immutable;
1;