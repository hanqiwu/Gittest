use strict;              # Global variables must be qualified lik
                         # $Package::variable, others must be defined with my.
use English;             # Get aliases for the built-in punctuation variables.
use Carp;                # Get detailed trace back


my @split9 = qw {

} ;

my @split10 = qw {

} ;
open INPUT, "newPCSdelta.txt" or die "ERROR: cant open file lb10.txt\n";
my @data = ();
my $p = 0;
while(<INPUT>){
 #chomp($_);
m/(\d+)/;
 push(@split9,"$1.man");
 print $1;

}

close INPUT;



open F, ">convertedNEWPCSDELTA.txt" or die "$! Can't create file";
print F $_.$/ foreach @split9;
close F;
