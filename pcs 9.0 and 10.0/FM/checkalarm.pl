use strict;              # Global variables must be qualified lik
                         # $Package::variable, others must be defined with my.
use English;             # Get aliases for the built-in punctuation variables.
use Carp;                # Get detailed trace back


my @temparray=();
my @diffarray=();
my $file;

open INPUT, "rpcsalarm.txt" or die "ERROR: cant open file lb9.txt\n";

while(<INPUT>){
	
		push(@temparray,"$_");
		}
####print @temparray;
close INPUT;



my $path="D:\\userdata\\qiwhan\\workspace\\com.nsn.pcsne-9.0\\o2ml\\content\\amanual"; 
##my $path="D:\\userdata\\qiwhan\\Desktop\\Tools\\code\\pcs 9.0 and 10.0\\test";
opendir(TEMPDIR, $path) or die "can't open it:$!";
my @dir =readdir TEMPDIR;

for(my $i = 0; $i < scalar( @temparray ); $i++ ){
my $p=0;
chomp ($temparray[$i]);

foreach $file(@dir)
{
##print $file;
if($file=~/$temparray[$i]/)
{
$p=1;
}
}
if($p!=1)
{
###print "There is difference.\n";
push(@diffarray,"$temparray[$i]");
}
}
close TEMPDIR;


open F, ">diffalarmlist.txt" or die "$! Can't create file";
print F $_.$/ foreach @diffarray;
close F;

open F, ">currentalarm.txt" or die "$! Can't create file";
print F $_.$/ foreach @dir;
close F;