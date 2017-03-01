use strict;              # Global variables must be qualified lik
                         # $Package::variable, others must be defined with my.
use English;             # Get aliases for the built-in punctuation variables.
use Carp;                # Get detailed trace back


my @collector=("testcounter-1.1.1");
my @diff9to10=();
my @same10to9=();


#open INPUT, "111.txt" or die "ERROR: cant real data file\n";


open INPUT, "PM201607071400+0530+24C20160707.1345+0530-20160707.1400+0530_PCS9" or die "ERROR: cant real data file\n";

while(<INPUT>){

	my  $ap=$_;
	my  $cp=$_;
		##$cp =~ s/>(.*?-\d\.\d\.\d)|\s+(.*?-\d\.\d\.\d)/; 
		$cp =~ s/>(.*?-\d+\.\d+\.\d+)/;
		push @collector, $1/eg;
		##print $cp;
		$cp =~ s/\s([a-zA-Z].*?-\d+\.\d+\.\d+)/;
		push @collector, $1/eg;
		}
close INPUT;



open F, ">RDCL.txt" or die "$! Can't create file";
print F $_.$/ foreach @collector;
close F;


for ( my $i = 0; $i < scalar( @collector ); $i++ )
{
	
#open INPUT, "com.nsn.acpcs.pcsne-V10_Mapping_Config.xml" or die "ERROR: cant open file com.nsn.acpcs.pcsne-V10_Mapping_Config.xml\n";
open INPUT, "com.nsn.acpcs.pcsne-V10_Mapping_Config.xml" or die "ERROR: cant open file com.nsn.acpcs.pcsne-V10_Mapping_Config.xml\n";
my @data = ();
my $p = 0;
while(<INPUT>){
my $temp = quotemeta ($collector[$i]);
       if(m/$temp/i)
	   {
	   $p =1;
	   push(@same10to9,"$collector[$i]");
	   }

}
 if ($p != 1)
 {
 #print "$collector[$i] \n";
 push(@diff9to10,"$collector[$i]");

}
}
close INPUT;

print "The missing counter in mapping file is:" ;
print ("@diff9to10\n");

open F, ">RDToRresult.txt" or die "$! Can't create file";
print F $_.$/ foreach @diff9to10;
close F;

open F, ">OKlist.txt" or die "$! Can't create file";
print F $_.$/ foreach @same10to9;
close F;