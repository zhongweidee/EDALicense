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
                  print Dumper(@terms);
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
    my $self=shift;
    my $cont =$_[0];
    $self->content($cont);
    my @lines = grep {!/^#/} (grep {/\w+/} (split /\n/,$cont));
    foreach my $line (@lines){
    if ($line =~/^SERVER\s+\S+\s+(\S+)\s+/i){
                      $self->hostId($1);
                                    }
    if ($line =~/^DAEMON\s+/i){
                      $self->daemon($line);
                      }
                              }
    $self->vender($self->getVenderName($self->content()));
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
    my @venderList= qw(arm synopsys springsoft cadence);
    my $self =shift;
    my $cont = $_[0];
    foreach(@venderList){
     return $_  if $cont =~ /$_/i; 
                        }    
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
   #extends 'EDALicense'; 
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
   sub generateActiveLicenseFeatures($$)
   {
          my $self = shift;
	  my $cont = $_[0];
	  my @feaList = map {"Users of".$_}(split /Users\s+of/,$cont);
	  my @objList;
	  foreach (@feaList){
		  my $ALicObj = ActiveLicenseFeature->new();
		  $ALicObj->initWithStr($_);
		  push @objList,$ALicObj;
		            }
	  return \@objList;
   }
   sub isAlive($$)
   {
     my $self =shift;
     my $cont =$_[0];	     
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
   has 'issuedNum', is=>'rw',isa=>'Str';
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