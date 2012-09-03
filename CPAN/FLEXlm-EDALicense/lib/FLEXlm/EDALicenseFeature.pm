package FLEXlm::EDALicenseFeature{

   use 5.016;
   use strict;
   use warnings;
   use Moose;
   use Log::Log4perl qw(:easy);
   Log::Log4perl->easy_init($DEBUG);
   use Data::Dumper;
   has 'name',is => 'rw',isa=> 'Str';
   has 'hostId',is => 'rw',isa=> 'Str';
   has 'vender',is => 'rw',isa=> 'Str';
   has 'content',is => 'rw',isa=> 'Str';
   has 'daemon',is => 'rw',isa=> 'Str';
   has 'version',is => 'rw',isa=> 'Str';
   has 'expiredDate',is => 'rw',isa=> 'Str';
   has 'num',is => 'rw',isa=> 'Int';


=head1 NAME

FLEXlm::EDALicenseFeature - FLEXlm::EDALicenseFeature is object for one Feature content in License file!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use FLEXlm::EDALicenseFeature;

    my $foo = FLEXlm::EDALicenseFeature->new();
    ...

=head2 EDALicenseFeature's atribute


=head3 name()

   rw,Str

=head3 content()

   rw,Str

=head3 hostId()

   rw,Str
  
=head3 vender()
 
   rw,Str

=head3 demon()

   rw,Str (not support)

=head3 version()

   rw,Str (not support)

=head3 expiredDate()

   rw,Str

=head3 num()

   rw,Int

=head1 METHODS

=head2 new()

   you always don't need to create EDALicenseFeature alone.
  
   you always use the array ref from EDALicense's generateLicenseFeatures 

=cut

=head2 initWithStr(a)
 

=cut

 sub  initWithStr($$) 
   {
     my $self = shift;
     my $Str  =$_[0];
     $self->content($Str);
     my @lines = grep {!/^#/} (grep {/\w+/} (split /\n/,$Str));
     foreach my $line (@lines){
       if (($line =~ /^FEATURE/i) or ($line =~ /^INCREMENT/i)){
                  my @terms = grep {/\S+/} (split /\s+/,$line);
		  $self->name($terms[1]);
                  DEBUG "terms3 is ".$terms[3];
                  $self->version($terms[3]);
                  $self->expiredDate($terms[4]);
                  $self->num($terms[5]);
                              }
                             }
   }

=head2 isSameAsFeaObj(a)

     a is a object of LicenseFeature which need to be compared

    if same, return 1;

    if not same, return 0;

=cut

 sub isSameAsFeaObj($$)
   {
	   my $self =shift;
	   my $compareObj = $_[0];
	   my ($sName,$sExpiredDate,$sNum)=($self->name(),$self->expiredDate(),$self->num()); 
           DEBUG "self $sName,$sExpiredDate,$sNum";
	   my ($cName,$cExpiredDate,$cNum)=($compareObj->name(),$compareObj->expiredDate(),$compareObj->num()); 
           DEBUG "compareObj $cName,$cExpiredDate,$cNum";
           return 0 if $sName ne $cName;
           return 0 if $sExpiredDate ne $cExpiredDate;
           return 0 if $sNum != $cNum;
	   return 1;
   }
    

=head1 AUTHOR

Wei Zhong, C<< <fanasyiszhongwei at gmail.com	> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-flexlm-edalicense at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FLEXlm-EDALicense>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FLEXlm::EDALicenseFeature


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
} # End of FLEXlm::EDALicenseFeature
