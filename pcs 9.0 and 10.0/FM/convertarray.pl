use strict;              # Global variables must be qualified lik
                         # $Package::variable, others must be defined with my.
use English;             # Get aliases for the built-in punctuation variables.
use Carp;                # Get detailed trace back

my @split9 = qw {

} ;

my @split10 = qw {

} ;

my %hash;
my $script = $0; # Get the script name

sub usage 
{
        printf("Usage:Convert the .\n");
        printf("perl $script first second ftosfilename stoffielname\n");
        

}

# If the number of parameters less than 2 ,exit the script
if ( $#ARGV+1 < 4) {

        &usage;
        exit 0;
}


my $first = $ARGV[0]; #File need to remove duplicate rows
my $second = $ARGV[1]; # File after remove duplicates rows

open INPUT, "split9.txt" or die "ERROR: cant open file lb10.txt\n";
my @data = ();
my $p = 0;
while(<INPUT>){
chomp;
$_=~ s/^\s+|\s+$//g;
s/.*/"$_",\n/;
push @data,$_;
}

close INPUT;

open F, ">array9.txt" or die "$! Can't create file";
foreach(@data) {
print F;
}
close F;