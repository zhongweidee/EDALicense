package FLEXlm::ActiveEDALicense{

use 5.016;
use strict;
use warnings;
use Moose;
use Date::Simple ('date');
has 'lmstatContent', is=>'rw',isa=>'Str';
has 'alive', is=>'rw',isa=>'Int';
has 'licenseFile', is=>'rw',isa=>'EDALicense';
has 'ActiveLicenseFeatures', is=>'ro',isa=>'ArrayRef[ActiveLicenseFeature]';


=head1 NAME

FLEXlm::ActiveEDALicense - The great new FLEXlm::ActiveEDALicense!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use FLEXlm::ActiveEDALicense;

    my $foo = FLEXlm::ActiveEDALicense->new();
    ...

=head2 ActiveLicense's atrribute

=head3 lmstatContent()
     
    rw,Str

=head3 alive()
     
    rw,Int

=head3 licenseFile()
    
    rw,EDALicense object

=head3 ActiveLicenseFeatures()

    rw, ArrayRef[ActiveLicenseFeature] (not support)


=head2 METHODS

=head3 initWithLmstatResult(a)

     a is the command result of lmstat -a -c 

=cut

sub initWithLmstatResult($$)
   {
     my $self =shift;
     my $lmstatCont = $_[0];
     $self->alive($self->isAlive($lmstatCont));
     $self->lmstatContent($lmstatCont); 
     $self->generateActiveLicenseFeatures($lmstatCont);     
   }


=head3  generateActiveLicenseFeatures()

     return array ref

=cut

sub generateActiveLicenseFeatures($)
   {
          my $self = shift;
	  my $cont = $self->lmstatContent();
	  my @feaList = map {"Users of".$_}(split /Users\s+of/,$cont);
	  my @objList;
	  foreach (@feaList){
		  my $ALicObj = ActiveLicenseFeature->new();
		  $ALicObj->initWithStr($_);
		  push @objList,$ALicObj;
		            }
	  return \@objList;
   }

=head3 isAlive()

     return 0 or 1
=cut
 sub isAlive($)
   {
     my $self =shift;
     my $cont =$self->lmstatContent();	     
     if( $cont =~ /Error\s+getting\s+status:/){
	     return 0;
	      }
     return 1;
   } 


=head1 AUTHOR

Wei Zhong, C<< <fanasyiszhongwei@gmail.com	> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-flexlm-edalicense at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FLEXlm-EDALicense>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FLEXlm::ActiveEDALicense


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

} # End of FLEXlm::ActiveEDALicense
