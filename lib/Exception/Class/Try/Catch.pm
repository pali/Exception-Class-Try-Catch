# Copyright (c) 2017 by Pali <pali@cpan.org>

package Exception::Class::Try::Catch;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.1';

use Carp;
use Exception::Class::Base;
use Exporter 5.57 'import';
use Scalar::Util;
use Try::Catch qw(try);

$Carp::Internal{+__PACKAGE__} = 1;

our @EXPORT_OK = qw(try catch);
our @EXPORT = @EXPORT_OK;

sub catch (&;@) {
	my $block = $_[0];
	$_[0] = sub {
		my $error = $_[0];
		if (Scalar::Util::blessed($error) and not $error->isa('Exception::Class::Base')) {
			$error = $error->as_string() if $error->can('as_string');
			$error = "$error";
		}
		if (not Scalar::Util::blessed($error)) {
			$_[0] = $_ = Exception::Class::Base->new($error);
		}
		goto &$block;
	};
	goto &Try::Catch::catch;
}

1;
__END__

=head1 NAME

Exception::Class::Try::Catch - L<Try::Catch> for L<Exception::Class>

=head1 SYNOPSIS

  try {
      My::Exception::Class->throw('my error');
  } catch {
      if ($_->isa('Specific::Exception')) {
          handle_specific_exception($_);
      } elsif ($_->isa('Local::Exception')) {
          handle_local_exception($_);
      } else {
          # $_ is always object of 'Exception::Class::Base'
          handle_base_exception($_);
      }
  };

  try {
      die 'my error';
  } catch {
      # $_ is always object of 'Exception::Class::Base'
      handle_base_exception($_);
      process_text_of_exception($_->error);
  };

  try {
      die 'my error';
  } catch {
      $_->rethrow();
  };

=head1 DESCRIPTION

C<Exception::Class::Try::Catch> provides C<try>/C<catch> syntactic suggar from L<Try::Catch> for L<Exception::Class> object exceptions.

=cut
