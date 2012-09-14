package Hypatia::DBI::Test::SQLite;
use Moose;
use DBI;
use JSON;
use Path::Class;

has 'dir'=>(isa=>'Str', is=>'ro',default=>sub{ return $ENV{TMP} ? $ENV{TMP} : "."; });

has 'sqlite_db_file'=>(isa=>'Str',is=>'ro',default=>"hypatia_test.db");

has 'json_file'=>(isa=>'Str',is=>'ro',lazy=>1,default=>"sqlite.json");

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
    
    open(my $read,"<",$self->json_file) or die $!;
    
    my $json_str="";
    while(<$read>)
    {
        chomp;
        $json_str .= " " . $_;
    }
    close($read);
    
    my $table_data=$json->decode($json_str);
    
    foreach my $table(keys %$table_data)
    {
        $dbh->do($table->{create}) or die $dbh->errstr;
        
        foreach my $insert (@{$table->{insert}})
        {
            $dbh->do($insert) or die $dbh->errstr;
        }
    }
}


__PACKAGE__->meta->make_immutable;
1;