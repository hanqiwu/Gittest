use strict;              # Global variables must be qualified lik
                         # $Package::variable, others must be defined with my.
use English;             # Get aliases for the built-in punctuation variables.
use Carp;                # Get detailed trace back



my %hash;
my $script = $0; # Get the script name

sub usage 
{
        printf("Usage:Compare the difference.\n");
        printf("perl $script first second ftosfilename stoffielname\n");
        

}

# If the number of parameters less than 2 ,exit the script
if ( $#ARGV+1 < 4) {

        &usage;
        exit 0;
}


my $first = $ARGV[0]; #File need to remove duplicate rows
my $second = $ARGV[1]; # File after remove duplicates rows
my $ftos = $ARGV[2];
my $stof = $ARGV[3];


print "===============================================================\n";
print "Start Spliting \n";
print "===============================================================\n";


my @first=();
my @second=();


my @ftos = () ;

my @stof = () ;

open INPUT, $first or die "ERROR: cant open file lb10.txt\n";

while(<INPUT>){

 chomp($_);
push(@first,"$_");
 
 
}
close INPUT;

open INPUT, $second or die "ERROR: cant open file lb10.txt\n";

while(<INPUT>){

 chomp($_);
push(@second,"$_");
 
 
}
print ("@second\n");
close INPUT;



################Compare between different between 9 and 10, then store the difference###############

for ( my $i = 0; $i < scalar( @first ); $i++ )
{
open INPUT, $second or die "ERROR: cant open file lb10.txt\n";
my @data = ();
my $p = 0;
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

print "The missing alarm in second file is:" ;
print ("@ftos\n");

open (F, ">$ftos") or die "$! Can't create file";
print F $_.$/ foreach @ftos;
close F;




for ( my $i = 0; $i < scalar( @second ); $i++ )
{
open INPUT, $first or die "ERROR: cant open file lb10.txt\n";
my @data = ();
my $p = 0;
while(<INPUT>){

       if(m/$second[$i]/i)
	   {
	   $p =1;
	   }

}
 if ($p != 1)
 {
 push(@stof,"$second[$i]");
 }

}
close INPUT;

print "The missing alarm in first file is:" ;
print ("@stof\n");

open (F, ">$stof") or die "$! Can't create file";
print F $_.$/ foreach @stof;
close F;








