package Hypatia::DBI::Test::SQLite;
{
  $Hypatia::DBI::Test::SQLite::VERSION = '0.025';
}
use Moose;
use DBI;
use JSON;
use Path::Class;
use namespace::autoclean;

has 'sqlite_dir'=>(isa=>'Str', is=>'ro',default=>sub{ return $ENV{TMP} ? $ENV{TMP} : "."; });

has 'sqlite_db_file'=>(isa=>'Str',is=>'ro',default=>"hypatia_test.db");

has 'table'=>(isa=>'Str',is=>'ro',required=>1);

has [qw(username password)]=>(isa=>'Str',is=>'ro',default=>"");

has 'dbh'=>(isa=>'DBI::db',is=>'ro',lazy=>1,init_arg=>undef
    ,default=>sub{
        my $self=shift;
        my $dbh=DBI->connect("dbi:SQLite:dbname=" . $self->file_with_path,$self->username,$self->password) or confess DBI->errstr;
        
        return $dbh;
    });

has 'file_with_path'=>(isa=>'Str',is=>'ro',init_arg=>undef,lazy=>1,builder=>'_build_file_with_path');

sub _build_file_with_path
{
    my $self=shift;
    return Path::Class::File->new($self->sqlite_dir,$self->sqlite_db_file)->stringify;
}

sub BUILD
{
    my $self=shift;
    
    unless(-e $self->file_with_path)
    {
        open(my $fh,">",$self->file_with_path) or die $!;
        close($fh);
    }
    
    $self->load_table unless($self->table_exists);
}

sub table_exists
{
    my $self=shift;
    
    my $dbh=$self->dbh;
    
    confess "No active connection to " . $self->file_with_path unless $dbh->{Active};
    
    my $sth=$dbh->prepare("select count(1) from sqlite_master where type='table' and name='" . $self->table . "'") or die $dbh->errstr;
    $sth->execute or die $dbh->errstr;
    
    my $count=$sth->fetchrow_arrayref->[0];
    $sth->finish;
    
    return $count;
}

sub load_table
{
    my $self=shift;
    my $dbh=$self->dbh;
    my $table=$self->table;
    
    my $json_str="";
    
    $json_str.= " " .$_ while(<DATA>);
    
    my $table_data=JSON->new->relaxed->utf8->decode($json_str);
    
    my $found=0;
    
    foreach(@$table_data)
    {
        if($_->{table} eq $self->table)
        {
            $dbh->do($_->{create}) or die $dbh->errstr;
            
            foreach my $insert(@{$_->{insert}})
            {
                $dbh->do($insert) or die $dbh->errstr;
            }
            $found=1;
            last;
        }
    }
    
    unless($found)
    {
        confess "Table " . $self->table . " not included in " . __PACKAGE__;
    }
    
    
}


__PACKAGE__->meta->make_immutable;
1;

=pod

=head1 NAME

Hypatia::DBI::Test::SQLite

=head1 VERSION

version 0.025

=head1 AUTHOR

Jack Maney <jack@jackmaney.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Jack Maney.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__DATA__
[
    {"table":"hypatia_test_xy",
    "create":"create table hypatia_test_xy (x1 int, x2 float, y1 float,y2 float)",
    "insert":["insert into hypatia_test_xy values(1,1.1,7.22,2.1)",
        "insert into hypatia_test_xy values(2,-2.1,3.88,-0.5)",
        "insert into hypatia_test_xy values(4,3.3,6.2182,3)",
        "insert into hypatia_test_xy values(6,0,2.71828,3.1415926)",
        "insert into hypatia_test_xy values(5,7,4.1,1.41)"]
    },
    {
        "table":"hypatia_test_bubble",
        "create":"create table hypatia_test_bubble (a float, b float, c float)",
        "insert":[
            "insert into hypatia_test_bubble values (0,3,1.1)",
            "insert into hypatia_test_bubble values (0.9,4,0.5)",
            "insert into hypatia_test_bubble values (2,6.1,2.2)",
            "insert into hypatia_test_bubble values (6,4.4,1.9)"
        ]
    },
    {"table":"hypatia_test_bubble_multi1",
    "create":"create table hypatia_test_bubble_multi1 (x1 float, y1 float, size1 float, x2 float, y2 float, size2 float)",
    "insert":[
        "insert into hypatia_test_bubble_multi1 values (3, 2, 0.4, 5, 1, 0.8)",
        "insert into hypatia_test_bubble_multi1 values (1, 6, 1, 4, 7, 1.3)",
        "insert into hypatia_test_bubble_multi1 values (6, 7, 2.01, 5, -1,1.38)",
        "insert into hypatia_test_bubble_multi1 values (8, 2, 0.2, 9, 5, 3)"
    ]
    },
    {
        "table":"hypatia_test_bubble_multi2",
        "create":"create table hypatia_test_bubble_multi2 (x float, y1 float, size1 float, y2 float, size2 float)",
        "insert":[
            "insert into hypatia_test_bubble_multi2 values (-1,2,4,-3,1)",
            "insert into hypatia_test_bubble_multi2 values (1,1,0.4,5,1.21)",
            "insert into hypatia_test_bubble_multi2 values (5,0,2,8,3)",
            "insert into hypatia_test_bubble_multi2 values (6,-3,2,8,0.5)"
        ]
    }
    ,{
        "table":"hypatia_test_bubble_fail",
        "create":"create table hypatia_test_bubble_fail (x float, y float, z float, w float)",
        "insert":[
            "insert into hypatia_test_bubble_fail values (1,2,3,4)",
            "insert into hypatia_test_bubble_fail values (1,2,3,4)"
        ]
    },
    {
        "table":"hypatia_test_pie",
        "create":"create table hypatia_test_pie (type text, number float)",
        "insert":[
            "insert into hypatia_test_pie values ('some type',1)",
            "insert into hypatia_test_pie values ('some other thing',2)",
            "insert into hypatia_test_pie values ('some type',0.48)",
            "insert into hypatia_test_pie values ('yet another thing',1.78)"
        ]
    }
]