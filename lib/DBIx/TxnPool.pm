package DBIx::TxnPool;

use strict;
use warnings;

our $VERSION = 0.01;

1;

__END__

=pod

=head1 NAME

DBIx::TxnPool - The easy pool for making SQL insert/delete/updates statements more quickly by transaction method

=head1 SYNOPSIS

    my $pool = txn_item {
	# $_ consists the one item
	# code has dbh & sth handle statements
	# It's executed for every item inside one transaction maximum of size 'size'
	# this code may be recalled if deadlocks will occur
    }
    txn_post_item {
	# $_ consists the one item
	# code executed for every item after sucessfully commited transaction
    } dbh => $dbh, size => 100;

    foreach my $i ( 0 .. 1000 ) {
	$pool->add( { i => $i, value => 'test' . $i } );
    }

    $pool->finish;

=head1 DESCRIPTION

Sometimes i need in module which helps to me to wrap some SQL manipulation
statements to one transaction. If you make alone insert/delete/update statement
in the InnoDB engine, MySQL server for example does fsync (data flushing to disk) after
each statements. It can be very slowly if you update 100,000 and more rows for
example. The better way to wrap some insert/delete/update statements in one
transaction for example. But there can be other problem - deadlocks. If a
deadlock occur the DBI's module can throws exceptions and ideal way to repeat SQL
statements. This module helps to make it. It has a pool inside for data (FIFO
buffer) and calls your callbacks for each pushed item. When you feed a module by
your data, it wrap data in one transaction up to maximum defined size of up to
finish method. If deadlock occurs it repeat your callbacks for every item again.
You can define a second callback which will be executed for every item after
wrapped transaction. For example there can be non-SQL statements, for example a
deleting files, cleanus and etc.

=head1 CONSTRUCTOR

The object DBIx::TxnPool created by txn_item subroutines:

    my $pool = txn_item {
	# $_ consists the one item
	# code has dbh & sth handle statements
	# It's executed for every item inside one transaction maximum of size 'size'
	# this code may be recalled if deadlocks will occur
    }
    txn_post_item {
	# $_ consists the one item
	# code executed for every item after sucessfully commited transaction
    } dbh => $dbh, size => 100;

Or other way:

    my $pool = txn_item {
	# $_ consists the one item
	# code has dbh & sth handle statements
	# It's executed for every item inside one transaction maximum of size 'size'
	# this code may be recalled if deadlocks will occur
    } dbh => $dbh, size => 100;

There are all parameters.

=over parameters

=item B<Required>: transaction item callback

=item B<Optional>: post transaction item callback

=item B<Required>: dbh

The dbh to be needed for begin_work & commit for wrapping to transaction.

=item B<Optional>: size

The size of pool when a commit method will be called when feeding reaches the same size.

=back

=head1 AUTHOR

This module has been written by Perlover <perlover@perlover.com>

=head1 LICENSE

This module is free software and is published under the same terms as Perl
itself.

=head1 TODO

=over

=item This module :)

=item A supporting DBIx::Connector object instead DBI

=back

=cut
