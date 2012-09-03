package FLEXlm::ActiveEDALicenseFeature{

use 5.016;
use strict;
use warnings;

=head1 NAME

FLEXlm::ActiveEDALicenseFeature - The great new FLEXlm::ActiveEDALicenseFeature!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use FLEXlm::ActiveEDALicenseFeature;

    my $foo = FLEXlm::ActiveEDALicenseFeature->new();
    ...

=head2 ActiveLicenseFeature's atrribute

=head3 name()

rw Str

=head3 content()

rw Str

=head3 issuedNum()

rw Int

=head3 usedNum()

rw Int

=head1 SUBROUTINES/METHODS

=head2 new()
  
  you must use this method first!

=head2 initWithStr(a)
   
  a is one license feature section

=cut

sub initWithStr($$)
   {
	   my $self=shift;
	   my $cont = $_[0];
	   $self->content = $cont;
	   my @licLine =grep {/license/ }(split /\n/,$cont); 
	   my $numOfLicLine =()=@licLine;
	   die "Error: multi-lines or 0 line have license key word" if $numOfLicLine !=1;
	   my @elems = split /\n/,$licLine[0];
	   $self->name($elems[2]);
	   $self->issuedNum($elems[5]);
	   $self->usedNum($elems[10]);
	   die "Error: issuedNum is not digital " if $self->issuedNum() =~ /\d+/;
	   die "Error: usedNum is not digital " if $self->usedNum() =~ /\d+/;
   }

=head1 AUTHOR

Wei Zhong, C<< <fanasyiszhongwei at gmail.com	> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-flexlm-edalicense at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FLEXlm-EDALicense>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FLEXlm::ActiveEDALicenseFeature


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=FLEXlm-EDALicense>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/FLEXlm-EDALicense>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/FLEXlm-EDALicense>

=item * Search CPAN

L<http://search.cpan.org/dist/FLEXlm-EDALicense/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Wei Zhong.

This program is released under the following license: GPL


=cut
 no Moose;
 __PACKAGE__->meta->make_immutable;
} # End of FLEXlm::ActiveEDALicenseFeature
