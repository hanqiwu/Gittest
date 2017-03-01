use strict;              # Global variables must be qualified lik
                         # $Package::variable, others must be defined with my.
use English;             # Get aliases for the built-in punctuation variables.
use Carp;                # Get detailed trace back


######################################################################################

my $dirName =  $ENV{TKTKOA_GENERATOR_BASE_DIR} . "pcosgn/sgn/subsystem/";

my $sgsmeta = $dirName . "sgnrap/sgsmeta_mx.cf";
my $cdb_rawviews = $dirName . "sgncdb/sgncdb_cre_rawviews.sql";
#my $cdb_rawviews_gc = $dirName . "sgncdb/sgncdb_cre_rawviews_gc.sql";
my $rdb_psviews = $dirName . "sgnrdb/sgnrdb_cre_psviews.sql";
my $rdb_pvviews = $dirName . "sgnrdb/sgnrdb_cre_pvviews.sql";
my $rdb_tables = $dirName . "sgnrdb/sgnrdb_cre_tables.sql";


###########################################################################################


print "===============================================================\n";
print "Start Spliting \n";
print "===============================================================\n";

######################################################################################
#################Modify sgscdb_cre_rawviews.sql#######################




my @split9 = qw {

} ;

my @split10 = qw {

} ;



open INPUT, "rlb9.txt" or die "ERROR: cant open file lb10.txt\n";
my @data = ();
my $p = 0;
while(<INPUT>){

m/(.*)-(.*)/;
 push(@split9,"$2");
 print $2;

}

close INPUT;



open F, ">split9.txt" or die "$! Can't create file";
print F $_.$/ foreach @split9;
close F;

open INPUT, "rlb10.txt" or die "ERROR: cant open file lb10.txt\n";
my @data = ();
my $p = 0;
while(<INPUT>){

	m/(.*)-(.*)/;
 push(@split10,"$2");

}

close INPUT;



open F, ">split10.txt" or die "$! Can't create file";
print F $_.$/ foreach @split10;
close F;



