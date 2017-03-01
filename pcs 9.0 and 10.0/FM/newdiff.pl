use strict;              # Global variables must be qualified lik
                         # $Package::variable, others must be defined with my.
use English;             # Get aliases for the built-in punctuation variables.
use Carp;                # Get detailed trace back



my %hash;
my $script = $0; # Get the script name

sub usage 
{
        printf("Usage:Compare the difference.\n");
        printf("perl $script first second ftosfilename \n");
        

}

# If the number of parameters less than 2 ,exit the script
if ( $#ARGV+1 < 3) {

        &usage;
        exit 0;
}


my $first = $ARGV[0]; #File need to compare
my $second = $ARGV[1]; # File need to be compared
my $ftos = $ARGV[2]; # result output

print "===============================================================\n";
print "Start Spliting \n";
print "===============================================================\n";


my @first=();
my @second=();

my @ftos = () ;

open INPUT, $first or die "ERROR: cant open file lb10.txt\n";

while(<INPUT>){

 chomp($_);
push(@first,"$_");
 
}
#print ("@first\n");
close INPUT;

open INPUT, $second or die "ERROR: cant open file lb10.txt\n";

while(<INPUT>){

 chomp($_);
push(@second,"$_");
 
 
}
#print ("@second\n");
close INPUT;



################Compare between different between 9 and 10, then store the difference###############

for ( my $i = 0; $i < scalar( @first ); $i++ )
{
open INPUT, $second or die "ERROR: cant open file lb10.txt\n";
my @data = ();
my $p = 0;
#print ("Current content is :$first[$i]111\n");
while(<INPUT>){

       if(m/$first[$i]/i)
	   {
	   $p =1;
	   }

}
 if ($p != 1)
 {
 push(@ftos,"$first[$i]");
 }

}
close INPUT;

print "The missing alarm in second file is:\n" ;
print ("@ftos\n");

open (F, ">$ftos") or die "$! Can't create file";
print F $_.$/ foreach @ftos;
close F;










