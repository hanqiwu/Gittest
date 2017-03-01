use strict;              # Global variables must be qualified lik
                         # $Package::variable, others must be defined with my.
use English;             # Get aliases for the built-in punctuation variables.
use Carp;                # Get detailed trace back


my %hash;
my $script = $0; # Get the script name

sub usage 
{
        printf("Usage:Convert the alarm no. to NetAct Format\n");
        printf("perl $script target destni\n");
        

}

# If the number of parameters less than 2 ,exit the script
if ( $#ARGV+1 < 2) {

        &usage;
        exit 0;
}


my $source_file = $ARGV[0]; #File need to remove duplicate rows
my $dest_file = $ARGV[1]; # File after remove duplicates rows



my @pcsalarm = ();
my @netactalarm = ();
my $p = 0;
open INPUT, $source_file or die "ERROR: cant open file ";

while(<INPUT>){

       if(m/(\d+)\-(\d+)/i)
	   {
	   push(@pcsalarm,"\'$1-$2\'\:\'Critical\'");
	   $p= $1*2**16+$2;
	   print "$p\n";
		push(@netactalarm,"$p");
		}
 }

close INPUT;

#open (F, ">pcstempalarm.txt") or die "$! Can't create file";
#print F $_.$/ foreach @pcsalarm;
#close F;

open (F, ">$dest_file") or die "$! Can't create file";
print F $_.$/ foreach @netactalarm;
close F;