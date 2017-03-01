use strict;
my $filepcs;
my $filecom;
my $dirpcs = "D:\\userdata\\qiwhan\\workspace\\trunk\\com.nsn.pcsne\\com.nsn.pcsne-9.0\\o2ml\\content\\amanual";
my $dircom = "D:\\userdata\\qiwhan\\workspace\\trunk\\com.nsn.acpcs\\com.nsn.acpcs-10.0\\o2ml\\content\\amanual";
my @dirpcs;
my @dircom;

print "$dirpcs\n";
opendir(DIR,$dircom);
@dircom = readdir DIR;
foreach $filepcs(@dircom)
{
print "$filepcs\n";
}



open F, ">CurrentCOMMANDER10man.txt" or die "$! Can't create file";
print F $_.$/ foreach @dircom;
close F;
