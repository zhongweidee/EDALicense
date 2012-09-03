use 5.016;
package EDALicenseFeature
{
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
    
no Moose;
__PACKAGE__->meta->make_immutable;
}


package EDALicense
{
   use Moose;
   use Date::Simple ('date');
   use File::Read;
   use File::Basename;
   use Log::Log4perl qw(:easy);
   Log::Log4perl->easy_init($DEBUG);
   use Data::Dumper;

   has 'name',is => 'rw',isa=> 'Str';
   has 'content',is => 'rw',isa=> 'Str';
   has 'hostId',is => 'rw',isa=> 'Str';
   has 'vender',is => 'rw',isa=> 'Str';
   has 'daemon',is => 'rw',isa=> 'Str';
   has 'allowDupFeature', is => 'rw',isa=>'Int';
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

   sub initWithFilePath($$)
   {
    my $self=shift;
    my $path =$_[0];
    $self->name(basename($path));
    my $cont= read_file($path);
    $self->initWithFileCont($cont);
   }

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
   sub DeleteDupLicFeature($)
   {
	 # delete old feature
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
   sub compareDate($$){
	   my $self =shift;
	   my $dayA=$_[0];
	   my $dayB=$_[1];
           self->checkDateFormat($dayA);
           self->checkDateFormat($dayB);
	   my $diff =date($dayA) - date($dayB);
	   return $diff;
   }
   sub checkDateFormat($)
   {
	   my $self =shift;
	   my $day =$_[0];
	   die "Error: date Format is not correct $day" if $day !~ /^\d+-\d+-\d+$/;
   }

   sub translateLicDateFormat($)
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
no Moose;
__PACKAGE__->meta->make_immutable;
  
}

package ActiveLicense
{
   use Moose;
   use Date::Simple ('date');
   has 'lmstatContent', is=>'rw',isa=>'Str';
   has 'alive', is=>'rw',isa=>'Int';
   has 'licenseFile', is=>'rw',isa=>'EDALicense';
   has 'ActiveLicenseFeatures', is=>'ro',isa=>'ArrayRef[ActiveLicenseFeature]';


   sub initWithLmstatResult($$)
   {
     my $self =shift;
     my $lmstatCont = $_[0];
     $self->alive($self->isAlive($lmstatCont));
     $self->lmstatContent($lmstatCont); 
     $self->generateActiveLicenseFeatures($lmstatCont);     
   }
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
   sub isAlive($)
   {
     my $self =shift;
     my $cont =$self->lmstatContent();	     
     if( $cont =~ /Error\s+getting\s+status:/){
	     return 0;
	      }
     return 1;
   } 
no Moose;
__PACKAGE__->meta->make_immutable;
   
}

package ActiveLicenseFeature
{
   use Moose;
   use Date::Simple ('date');
   #extends 'EDALicense'; 
   has 'name', is=>'rw',isa=>'Str';
   has 'content', is=>'rw',isa=>'Str';
   has 'issuedNum', is=>'rw',isa=>'Int';
   has 'usedNum', is=>'rw',isa=>'Int';
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

   no Moose;
   __PACKAGE__->meta->make_immutable;
}

=pod

=head1 NAME

EDALicense - A License object system for EDA Tools

=head1 VERSION

version 0.01

=head1 SYNOPSIS

  use EDALicense;

  my $licObj=EDALicense->new();
     $licObj->initWithFileCont($LicCont);
  my $vender=$licObj->vender();

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

=head2 EDALicense's method

=head3 new()

you must do new(), and with one init method

for example:

   my $licObj=EDALicense->new();

      $licObj->initWithFileCont($preLicCont);

my $licObj=EDALicense->new();

=head3 initWithFileCont(a) 

a is the string of LicenseFile content

=head3 initWithFilePath(a) 

a is the string of LicenseFile path

=head3 getVenderName() 

this method is to find the vendername in licenseFile.

only support: arm/synopsys/mentor/cadence

=head3 generateLicenseFeatures() 
 
this method is to generate a array ref of EDALicenseFeature object

=head2 EDALicenseFeature'attribute


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

=head2 EDALicenseFeature's method

=head3 new()

   you always don't need to create EDALicenseFeature alone.
  
   you always use the array ref from EDALicense's generateLicenseFeatures 

=head3 isSameAsFeaObj(a)
   
    a is a object of LicenseFeature which need to be compared

    if same, return 1;

    if not same, return 0;

=head2 ActiveLicense's atrribute

=head3 lmstatContent()
     
    rw,Str

=head3 alive()
     
    rw,Int

=head3 licenseFile()
    
    rw,EDALicense object

=head3 ActiveLicenseFeatures()

    rw, ArrayRef[ActiveLicenseFeature] (not support)

=head2 ActiveLicense's method

=head3 initWithLmstatResult(a)

     a is the command result of lmstat -a -c 

=head3 generateActiveLicenseFeatures()

     return array ref

=head3 isAlive()
     return 0 or 1

=head2 ActiveLicenseFeature's atrribute

=head3 name()

rw Str

=head3 content()

rw Str

=head3 issuedNum()

rw Int

=head3 usedNum()

rw Int

=head2 AcitveLicenseFeature's method

=head3 new()

=head3 initWithStr(a)

=head1 AUTHOR

EDALicense is developed and maintained by Wei.Zhong

any question, please contact with fanasyiszhongwei@gmail.com

=head1 COPYRIGHT AND LICENSE

=cut

__END__
