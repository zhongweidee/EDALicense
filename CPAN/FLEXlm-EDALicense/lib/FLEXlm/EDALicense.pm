package FLEXlm::EDALicense
{
use 5.016;
use strict;
use warnings;
use Moose;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);
#use Data::Dumper;
has 'name',is => 'rw',isa=> 'Str';
has 'hostId',is => 'rw',isa=> 'Str';
has 'vender',is => 'rw',isa=> 'Str';
has 'content',is => 'rw',isa=> 'Str';
has 'daemon',is => 'rw',isa=> 'Str';
has 'version',is => 'rw',isa=> 'Str';
has 'expiredDate',is => 'rw',isa=> 'Str';
has 'num',is => 'rw',isa=> 'Int';


=head1 NAME

FLEXlm::EDALicense - A License object system for FLEXlm::EDALicense!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use FLEXlm::EDALicense;

    my $licObj = FLEXlm::EDALicense->new();
       $licObj->initWithFileCont($LicCont);
    my $vender=$licObj->vender();
    ...

=head1 DESCRIPTION

EDALicense is an class sets for License of EDA Tools   

use "MOOSE" perl Object system  Module.

Please read some document about "Moose" If you need to understand the Object system of EDALicense

The main goal of EDALicense is to build perl API to License.

EDA tools: like cadence/synopsys/mentor/springsoft/arm ( based on lmgrd/lmdown/lmreread/lm*comand )

Class sets:

1. EDALicense: is based on License file which provided by EDA Vender

2. EDALicenseFeature: is single Feature class which extracted from EDALicense
   
   you always don't need to create EDALicenseFeature alone.
  
   you always use the array ref from EDALicense's generateLicenseFeatures 

3. ActiveLicense: is based on lmstat command result

4. ActiveLicenseFeature: is single Feature class which extracted form Active License

=head2 EDALicense's attribute

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

=head3 alllowDupFeature
 
   rw,Int (only allow 0 or 1 , 0 is not allow ,1 is allow)
 
   used for the license file contain same featurename but different feature expired Time.
 
   if you set 0,will delete the older expiredTime objects;

   effect the return vaule of the method generateLicenseFeatures


=head2 METHODS

=head3 new()

you must do new(), and with one init method

for example:

   my $licObj=EDALicense->new();

      $licObj->initWithFileCont($preLicCont);

my $licObj=EDALicense->new();


=head2 initWithFileCont(a)

   a is the string of LicenseFile content

=cut

 sub initWithFileCont($$)
   {
    DEBUG "start to initWithFileCont";
    my $self=shift;
    my $cont =$_[0];
    my @lines = grep {(!/^#/)&&(/\w+/)} (split /\n/,$cont);
    my $cont_delCom = join ("\n",@lines);
    $self->content($cont_delCom);
    foreach my $line (@lines){
    if ($line =~/^SERVER\s+\S+\s+(\S+)\s+/i){
                      $self->hostId($1);
                                    }
    if ($line =~/^DAEMON\s+/i){
                      $self->daemon($line);
                      }
                              }
    $self->vender($self->getVenderName($_[0]));
    DEBUG "end to initWithFileCont";
   }

=head2 initWithFilePath(a)

 a is the string of LicenseFile path

=cut

sub initWithFilePath($$)
   {
    my $self=shift;
    my $path =$_[0];
    $self->name(basename($path));
    my $cont= read_file($path);
    $self->initWithFileCont($cont);
   }

=head2 getVenderName

this method is to find the vendername in licenseFile.

only support: arm/synopsys/mentor/cadence


=cut
sub getVenderName($$)
   {
    my @venderList= qw(arm synopsys springsoft cadence mentor);
    my $self =shift;
    my $cont = $_[0];
    DEBUG "!!!!!!!!!".$cont;
    foreach(@venderList){
     DEBUG "{".$_."}"; 
     return $_  if $cont =~ m/$_/i; 
                        }    
     warn "Error: Can't find any vender Name in LicenseFile";
   }

=head2 generateLicenseFeatures

 this method is to generate a array ref of EDALicenseFeature object

=cut
sub generateLicenseFeatures
   {
    DEBUG "generateLicenseFeatures";
    my $self =shift;
    my $cont = $self->content();
    my @LicenseFeatures;
    my $LicenseFeatures;
    my @feaList =grep {/\w+/} split ( /feature|increment/i,$cont);
    shift @feaList; # delete unused head line
    foreach (@feaList){
	   my $LF= EDALicenseFeature->new(); 
	   $LF->initWithStr("FEATURE ".$_); 
	   push @LicenseFeatures,$LF; 
	              }
   if($self->allowDupFeature ==0){
   $LicenseFeatures =$self->DeleteDupLicFeature(\@LicenseFeatures); 
   return $LicenseFeatures; 
                                 }
   else{
   return \@LicenseFeatures;
        }
   }

=head2 DeleteDupLicFeature

     delete the old license feature and leave latest one, and only effect the generateLicenseFeatures result
    
=cut
sub DeleteDupLicFeature($)
   {
	 my %FeaHash; 
	 my $self = shift;
	 my @LicFeatures = @{$_[0]};
         foreach my $ob (@LicFeatures){
            if(defined ($FeaHash{$ob->name()})){
               my $preDate =$self->translateLicDateFormat($FeaHash{$ob->name()}->expiredDate());   
	       my $postDate = $self->translateLiceDateFormat($ob->expiredDate());
	       $FeaHash{$ob->name} =$ob if (($self->compareDate($preDate,$postDate)) < 0);
			                      }
	    else{
               $FeaHash{$ob->name()}=$ob;
	       }
		                      }
           my @Feas= values %FeaHash; 
          return \@Feas;
   }


=head2 compareDate(a,b)

     a is dayA, b is dayB , both need to meet the request of Date::Simple module,

     you can get the infomation of Data::Simple on CPAN 

=cut
sub compareDate($$){
	   my $self =shift;
	   my $dayA=$_[0];
	   my $dayB=$_[1];
           self->checkDateFormat($dayA);
           self->checkDateFormat($dayB);
	   my $diff =date($dayA) - date($dayB);
	   return $diff;
   }

=head2 checkDateFormat(a)

     check day meet the format of "\d+-\d+-\d+" for Date::Simple module

=cut

sub checkDateFormat($)
   {
	   my $self =shift;
	   my $day =$_[0];
	   die "Error: date Format is not correct $day" if $day !~ /^\d+-\d+-\d+$/;
   }

=head2 translateLicDateFormat(a)

      a is translate license format "02-sep-2012" into "02-09-2012" for Date::Simple
=cut
 sub translateLicDateFormat($$)
   {
	   my %month =(
		   january => "01",
		   february => "02",
		   march => "03",
		   april => "04",
		   may => "05",
		   june => "06",
		   july => "07",
		   auguest=> "08",
		   september => "09",
		   october => "10",
		   november => "11",
		   december => "12",
	   );
	   my $self=shift;
	   my $licDate =$_[0];
	   my ($day,$mon,$year)=split '-',$licDate;
	   foreach (keys %month) {
		   if ($_ =~ /$mon/i){
			   return $year.'-'.$month{$_}.'-'.$day;
			              }
		                 }
   }

=head1 AUTHOR

Wei Zhong, C<< <fanasyiszhongwei at gmail.com	> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-flexlm-edalicense at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FLEXlm-EDALicense>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FLEXlm::EDALicense


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
} # End of FLEXlm::EDALicense
