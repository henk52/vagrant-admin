#!/usr/bin/perl -w
use strict;
use Data::Dumper;

#  Generate a vagrant box from a virtualbox instance.

# ===========================================================================
#                          V A R I A B L E S
# ===========================================================================

my $f_szVagrantBoxesBaseDirectory = "$ENV{HOME}/vagrant_boxes";

# This is the name that VirtualBox uses for the VM.
my $f_szBaseBoxName = "boot_vagrant_org";

my $szDistro = "fedora";
my $szReleaseName = "heisenbug";
my $szArchBits = "64";

my $f_szVagrantDeploymentName = "srv-$szDistro-$szReleaseName$szArchBits";

my %f_hConfiguration = (
 "description" => "(long) description",
 "short_description" => "Short description.",
 "company"  => "local",
 "version" => "0.0.0",
 "description_html" => "description_html",
 "description_markdown" => "description_markdown",
 "providers_url" => "http:\/\/XXX.XXX.XXX.XXX/Storage/Vagrant/"
                       );





# ============================================================
#                       F U N C T I O N S
# ============================================================


# -----------------------------------------------------------------
# ---------------
sub ReadCfg {
  my $szConfigFile = shift;
  my $refhConfig = shift;

  open(CFG, "<$szConfigFile") || die("!!! Unable to read $szConfigFile: $!");

  while (<CFG>) {
    chomp;

    next if (/^\s*$/);  
    next if (/^#/);  

    my ( $szVariableName, $szValue ) = $_ =~ /(.*?)\s*:\s*(.*)/;
    $refhConfig->{$szVariableName} = $szValue;
  }

  #  print Dumper(%{$refhConfig});
} # end readcfg



# -----------------------------------------------------------------
# ---------------
sub AddNewBox {
  my $szVagrantDeploymentName = shift;
  my $szVagrantBoxesBaseDirectory = shift;

  my @arOutput = `vagrant box list`;
  foreach my $szLine (@arOutput) {
    my $szBoxName = (split('\s+', $szLine))[0];
    $szBoxName = RemoveOptionalEscapeSequence($szBoxName);
    #$szBoxName =~ s/.*[^[:print:]]+//;
    #print "DDD is  '$szBoxName' " . length($szBoxName) . " eq '$szVagrantDeploymentName' " . length($szVagrantDeploymentName) ."\n";
    if ( "$szBoxName" eq "$szVagrantDeploymentName" ) {
      print "III vagrant box remove -f $szBoxName\n";
      `vagrant box remove $szBoxName`;
      die("!!! Failed to remove $szBoxName.") unless($? == 0);
    }

  }
  print "III Adding $szVagrantDeploymentName\n";
  `cd $szVagrantBoxesBaseDirectory; vagrant box add $szVagrantDeploymentName $szVagrantDeploymentName.box`;
  die("!!! Failed to add $szVagrantDeploymentName.") unless($? == 0);
} # end AddNewBox



# -----------------------------------------------------------------
# ---------------
sub RemoveOptionalEscapeSequence {
  my $szString = shift;

  my $szReturnString;

  my @arSplitString = split(//, $szString);
  if ( ord($arSplitString[0]) == 27 ) {
    shift @arSplitString;
    shift @arSplitString;
    shift @arSplitString;
    shift @arSplitString;
  }

  $szReturnString = join('', @arSplitString);
  return($szReturnString);
}

# -----------------------------------------------------------------
# ---------------
sub WriteJsonFile {
  my $szBoxName = shift;
  my $refhConfiguration = shift;

  my %hConfiguration = %{$refhConfiguration};

#  print Dumper(\%hConfiguration);

  open(JSON, ">${szBoxName}.json") || die("!!! Unable to open file for write: $!");
  print JSON "{\n";
  print JSON "  \"description\": \"$hConfiguration{description}\",\n";
  print JSON "  \"short_description\": \"$hConfiguration{short_description}\",\n";
  print JSON "  \"name\": \"$hConfiguration{company}/$szBoxName\",\n";
  print JSON "  \"versions\": [{\n";
  print JSON "      \"version\": \"$hConfiguration{version}\",\n";
  print JSON "      \"status\": \"active\",\n";
  print JSON "      \"description_html\": \"$hConfiguration{description_html}\",\n";
  print JSON "      \"description_markdown\": \"$hConfiguration{description_markdown}\",\n";
  print JSON "      \"providers\": [{\n";
  print JSON "          \"name\": \"virtualbox\",\n";
  print JSON "          \"url\": \"$hConfiguration{providers_url}/${szBoxName}.box\"\n";
  print JSON "      }]\n";
  print JSON "  }]\n";
  print JSON "}\n";
  close(JSON);
}



# -----------------------------------------------------------------
# ---------------
sub ShowPostOperations {
  my $szVagrantBoxName = shift;

  print "To share this box do the following:\n";
  print "   scp $szVagrantBoxName $f_szVagrantDeploymentName.json ADM\@SERVER:/Path\n";
}




# ============================================================

                #     #    #      ###   #     #
                ##   ##   # #      #    ##    #
                # # # #  #   #     #    # #   #
                #  #  # #     #    #    #  #  #
                #     # #######    #    #   # #
                #     # #     #    #    #    ##
                #     # #     #   ###   #     #

# ============================================================


`mkdir $f_szVagrantBoxesBaseDirectory` unless( -d "$f_szVagrantBoxesBaseDirectory" );

while ( $#ARGV > -1 ) {
  if ( $ARGV[0] eq "--srcname" ) {
    my $szDummy = shift @ARGV;
    if ( ($#ARGV > -1) && ( $ARGV[0] !~ /^--/ ) ) {
      $f_szBaseBoxName = shift @ARGV;
    } else {
      die("!!! Missing parameter for --srcname");
    }
  } elsif ( $ARGV[0] eq "--dstname" ) {
    my $szDummy = shift @ARGV;
    if ( ($#ARGV > -1) && ( $ARGV[0] !~ /^--/ ) ) {
      $f_szVagrantDeploymentName = shift @ARGV;
    } else {
      die("!!! Missing parameter for --dstname");
    }
  } elsif ( $ARGV[0] eq "--sharecfg" ) {
    my $szDummy = shift @ARGV;
    if ( ($#ARGV > -1) && ( $ARGV[0] !~ /^--/ ) ) {
      my $szFileName = shift @ARGV;
      ReadCfg($szFileName, \%f_hConfiguration);
    } else {
      die("!!! Missing parameter for --sharecfg");
    }
  } elsif ( ( $ARGV[0] eq "help" ) || ( $ARGV[0] eq "--help" ) || ( $ARGV[0] eq "-h" )){
    print "Generate a vagrant box from a virtualbox instance.\n";
    print "   --srcname VIRTUALBOX_NAME (default: $f_szBaseBoxName)\n";
    print "   --dstname VAGRANT_BOX_NAME (default: $f_szVagrantDeploymentName)\n";
    print "   --sharecfg FILE_NAME (default: none) Input to json file.\n";
    exit;
  } else {
    die("!!! Unknown option: $ARGV[0]");
  }
}



my $szVagrantBoxName = "$f_szVagrantDeploymentName.box";


WriteJsonFile($f_szVagrantDeploymentName, \%f_hConfiguration);
ShowPostOperations($szVagrantBoxName);

my $szVagrantBoxFile = "$f_szVagrantBoxesBaseDirectory/$szVagrantBoxName";
if ( -f $szVagrantBoxFile )  {
  print "III Removing old box: $szVagrantBoxName\n";
  # TODO V Check the return value of the execute.
  `rm $szVagrantBoxFile`;
  die("!!! Failed to remove box file.") unless($? == 0);
}

# TODO V support --vagrantfile ...txt
my $szCmd = "cd $f_szVagrantBoxesBaseDirectory; vagrant package --base $f_szBaseBoxName --output $szVagrantBoxName";
print "III Executing: $szCmd\n";

`$szCmd`;
if ( $? == 0 ) {
  AddNewBox($f_szVagrantDeploymentName, $f_szVagrantBoxesBaseDirectory);
  print "To start using the new vagrant box:\n";
  print "  mkdir NEW_RANDOM_DIR\n";
  print "  cd NEW_RANDOM_DIR\n";
  print "  vagrant init $f_szVagrantDeploymentName\n";
} else {
  die("!!! Failed to create the new vagrant box.");
}

ShowPostOperations($szVagrantBoxName);
