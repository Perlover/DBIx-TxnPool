package DBIx::TxnPool;

use strict;
use warnings;

our $VERSION = 0.01;

sub new {
    my ( $class, %args ) = @_;

    bless { size => $args{size} || 100, dbh => $args{dbh} }, ref $class || $class;
}

sub txn_item (&@) {
    my ( $callback, @args ) = @_;

    my ( $post_callback );

    if ( ref $args[0] eq 'HASH' ) {
	$post_callback = $args[0]->{post_callback};
	@args = @{ $args[0]->{args} };
	shift @args;
    }

    __PACKAGE__->new( @args );
}

sub txn_post_item (&@) {
    my ( $callback, @args ) = @_;

    return { post_callback => $callback, args => [ @args ] }
}

sub add {
    my ( $self, $data ) = @_;

    # TODO
}

sub finish {
    my $self = shift;

    # TODO
}

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
statements again. This module helps to make it. It has a pool inside for data (FIFO
buffer) and calls your callbacks for each pushed item. When you feed a module by
your data, it wraps data in one transaction up to the maximum defined size or up to
the finish method. If deadlock occurs it repeats your callbacks for every item again.
You can define a second callback which will be executed for every item after
wrapped transaction. For example there can be non-SQL statements, for example a
deleting files, cleanups and etc.

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

=item B<Required>: txn_item

The transaction's item callback. Here should be SQL statements and code should
be safe for repeating (when a deadlock occurs). The C<$_> consists a current item.
You can modify it if one is hashref for example.

=item B<Optional>: txn_post_item

The post transaction item callback. This code will be executed once for each
item (defined in C<$_>). It is located outside of the transaction. And it will
be called if whole transaction was succaessful.

=item B<Required>: dbh

The dbh to be needed for begin_work & commit method (wrap in a transaction).

=item B<Optional>: size

The size of pool when a commit method will be called when feeding reaches the same size.

=back

=head1 METHODS

=over

=item add

You can add item of data to the pool. This method makes a wrap to transaction.
It can finish transaction if pool reaches up to size or can repeat a whole
transaction again if deadlock exception was thrown. The size of transaction may
be less than your defined size!

=item finish

It makes a final transaction if pool is not empty.

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
