#!/usr/bin/perl -w
use strict;

#  Generate a vagrant box from a virtualbox instance.

# ===========================================================================
#                          V A R I A B L E S
# ===========================================================================

my $f_szVagrantBoxesBaseDirectory = "/vagrant/vagrant_boxes";

# This is the name that VirtualBox uses for the VM.
my $f_szBaseBoxName = "boot_vagrant_org";

my $szDistro = "fedora";
my $szReleaseName = "heisenbug";
my $szArchBits = "64";

my $f_szVagrantDeploymentName = "srv-$szDistro-$szReleaseName$szArchBits";

# ============================================================
#                       F U N C T I O N S
# ============================================================


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

# ============================================================

                #     #    #      ###   #     #
                ##   ##   # #      #    ##    #
                # # # #  #   #     #    # #   #
                #  #  # #     #    #    #  #  #
                #     # #######    #    #   # #
                #     # #     #    #    #    ##
                #     # #     #   ###   #     #

# ============================================================

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
  } elsif ( $ARGV[0] eq "help" ) {
    print "Generate a vagrant box from a virtualbox instance.\n";
    print "   --srcname VIRTUALBOX_NAME (default: $f_szBaseBoxName)\n";
    print "   --dstname VAGRANT_BOX_NAME (default: $f_szVagrantDeploymentName)\n";
    exit;
  } else {
    die("!!! Unknown option: $ARGV[0]");
  }
}

my $szVagrantBoxName = "$f_szVagrantDeploymentName.box";

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
