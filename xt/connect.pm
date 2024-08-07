use strict;
use warnings;

use DBI;
use Exporter;

our @EXPORT = qw( dbi_connect );

sub dbi_connect {
    return DBI->connect( "dbi:@{[eval{require DBD::mysql; 1}?'mysql:test;mysql_read_default_file':'MariaDB:test;mariadb_read_default_file']}=$ENV{HOME}/.my.cnf", undef, undef,
        {
            RaiseError  => 1,
            AutoCommit  => 1,
            PrintError  => 0,
        }
    );
}

1;
