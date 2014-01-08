package Test::Mock::Mango;

use v5.10;
use strict;
use warnings;

our $VERSION = "0.02";

require 'Mango.pm'; # Bit useless if you don't actually have mango
use Test::Mock::Mango::FakeData;
use Test::Mock::Mango::DB;
use Test::Mock::Mango::Collection;

$Test::Mock::Mango::data  = Test::Mock::Mango::FakeData->new;
$Test::Mock::Mango::error = undef;

# If we're running with Test::Spec and in appropriate context
# then use Test::Spec::Mocks to do our monkey patching.
if (exists $INC{'Test/Spec.pm'} && Test::Spec->current_context) {
	use warnings 'redefine';
	Mango->expects('db')->returns( state $db = Test::Mock::Mango::DB->new);
}
else {
 	no warnings 'redefine';
 	eval( q|*Mango::db = sub{state $db = Test::Mock::Mango::DB->new}| );
}

1;

=encoding utf8

=head1 NAME

Test::Mock::Mango - Simple stubbing for Mango to allow unit tests for code that uses it

=for html
<a href="https://travis-ci.org/necrophonic/test-mock-mango"><img src="https://travis-ci.org/necrophonic/test-mock-mango.png?branch=master"></a>

=head1 SYNOPSIS

  # Using Test::More
  #
  use Test::More;
  use Test::Mock::Mango; # Stubs in effect!
  # ...
  done_testing();


  # Using Test::Spec (uses Test::Spec::Mocks)
  #
  use Test::Spec;

  describe "Whilst stubbing Mango" => {
    require Test::Mock::Mango; # Stubs in effect in scope!
    # ...
  };
  runtests unless caller;


=head1 DESCRIPTION

Simple stubbing of mango methods. Methods ignore actual queries being entered and
simply return the data set in the FakeData object. To run a test you need to set
up the data you expect back first - this module doesn't test your queries, it allows
you to test around mango calls with known conditions.


=head1 STUBBED METHODS

The following methods are available on each faked part of the mango. We
describe here briefly how far each actually simulates the real method.

Each method supports blocking and non-blocking syntax if the original
method does. Non-blocking ops are not actually non blocking but simply
execute your callback straight away as there's nothing to actually go off
and do on an event loop.

All methhods by default execute without error state.


=head2 Collection

L<Test::Mock::Mango::Collection>

=head3 aggregate

Ignores query. Returns current collection documents to simulate an
aggregated result.

=head3 create

Doesn't really do anything.

=head3 drop

Doesn't really do anything.

=head3 find_one

Ignores query. Returns the first document from the current fake collection
given in L<Test::Mock::Mango::FakeData>. Returns undef if the collection
is empty.

=head3 find

Ignores query. Returns a new L<Test::Mock::Mango::Cursor> instance.

=head3 full_name

Returns full name of the fake collection.

=head3 insert

Naively inserts the given doc(s) onto the end of the current fake collection.

Returns an C<oid> for each inserted document. If an C<_id> is specifiec
in the inserted doc then it is returned, otherwise a new
L<Mango::BSON::ObjectID> is returned instead.

=head3 update

Doesn't perform a real update. You should set the data state in
C<$Test::Mock::Mango::data> before making the call to be what
you expect after the update.

=head3 remove

Doesn't remove anything.



=head2 Cursor

L<Test::Mock::Mango::Cursor>

=head3 all

Return array ref containing all the documents in the current fake collection.

=head3 next

Simulates a cursor by (beginning at zero) iterating through each document
on successive calls. Won't reset itself. If you want to reset the
cursor then set C<Test::Mock::Mango->index> to zero.

=head3 count

Returns the number of documents in the current fake collection.

=head3 backlog

Arbitarily returns 'C<2>'


=head1 TESTING ERROR STATES

L<Test::Mock::Mango> gives you the ability to simulate errors from your
mango calls.

Simply set the C<error> var before the call:

  $Test::Mock::Mango::error = 'oh noes!';

The next call will then run in an error state as if a real error has occurred.
The C<error> var is automatically cleared with the call so you don't need
to C<undef> it afterwards.


=head1 AUTHOR

J Gregory <JGREGORY@CPAN.ORG>

=head1 SEE ALSO

L<Mango>

=cut
