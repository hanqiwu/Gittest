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


########################################################Counter for measurement mobmgmnt mobmgmlr mobmgmra###################################
my @mmmt = qw (
 M50C000 
 M50C001 
 M50C002 
 M50C003 
 M50C004 
 M50C005 
 M50C006 
 M50C007 
 M50C008 
 M50C009 
 M50C010 
 M50C011 
 M50C012 
 M50C013 
 M50C014 
 M50C015 
 M50C016 
 M50C017 
 M50C018 
 M50C019 
 M50C020 
 M50C021 
 M50C022 
 M50C023 
 M50C024 
 M50C025 
 M50C026 
 M50C027 
 M50C028 
 M50C029 
 M50C030 
 M50C031 
 M50C032 
 M50C033 
 M50C034 
 M50C035 
 M50C036 
 M50C037 
 M50C038 
 M50C039 
 M50C040 
 M50C041 
 M50C042 
 M50C043 
 M50C044 
 M50C045 
 M50C046 
 M50C047 
 M50C048 
 M50C049 
 M50C050 
 M50C051 
 M50C052 
 M50C053 
 M50C054 
 M50C055 
 M50C056 
 M50C057 
 M50C058 
 M50C059 
 M50C060 
 M50C061 
 M50C062 
 M50C063 
 M50C064 
 M50C065 
 M50C066 
 M50C067 
 M50C068 
 M50C069 
 M50C070 
 M50C071 
 M50C072 
 M50C073 
 M50C074 
 M50C075 
 M50C076 
 M50C077 
 M50C078 
 M50C079 
 M50C080 
 M50C081 
 M50C082 
 M50C083 
 M50C084 
 M50C085 
 M50C086 
 M50C087 
 M50C088 
 M50C089 
 M50C090 
 M50C091 
 M50C092 
 M50C093 
 M50C094 
 M50C095 
 M50C096 
 M50C097 
 M50C098 
 M50C099 
 M50C100 
 M50C101 
 M50C102 
 M50C103 
 M50C104 
 M50C105 
 M50C106 
 M50C107 
 M50C108 
 M50C109 
 M50C110 
 M50C111 
 M50C112 
 M50C113 
 M50C114 
 M50C115 
 M50C116 
 M50C117 
 M50C118 
 M50C119 
 M50C120 
 M50C121 
 M50C122 
 M50C123 
 M50C124 
 M50C125 
 M50C126 
 M50C127 
 M50C128 
 M50C129 
 M50C130 
 M50C131 
 M50C132 
 M50C133 
 M50C134 
 M50C135 
 M50C136 
 M50C137 
 M50C138 
 M50C139 
 M50C140 
 M50C141 
 M50C142 
 M50C143 
 M50C144 
 M50C145 
 M50C146 
 M50C147 
 M50C148 
 M50C149 
 M50C150 
 M50C151 
 M50C152 
 M50C153 
 M50C154 
 M50C155 
 M50C156 
 M50C157 
 M50C158 
 M50C159 
 M50C160 
 M50C161 
 M50C162 
 M50C163 
 M50C164 
 M50C165 
 M50C166 
 M50C167 
 M50C168 
 M50C169 
 M50C170 
 M50C171 
 M50C172 
 M50C173 
 M50C174 
 M50C175 
 M50C176 
 M50C177 
 M50C178 
 M50C179 
 M50C180 
 M50C181 
 M50C182 
 M50C183 
 M50C184 
 M50C185 
 M50C186 
 M50C187 
 M50C188 
 M50C189 
 M50C190 
 M50C191 
 M50C192 
 M50C193 
 M50C194 
 M50C195 
 M50C196 
 M50C197 
 M50C198 
  M50C199 
 M50C200 
 M50C201 
 M50C202 
 M50C203 
 M50C204 
 M50C205 
 M50C206 
 M50C207 
 M50C208 
 M50C209 
 M50C210 
 M50C211 
 M50C212 
 M50C213 
 M50C214 
 M50C215 
 M50C216 
 M50C217 
 M50C218 
 M50C219 
 M50C220 
 M50C221 
 M50C222 
) ;

my @diff = qw {
Nothing
} ;


print "===============================================================\n";
print "Start Spliting \n";
print "===============================================================\n";

######################################################################################
#################Modify sgscdb_cre_rawviews.sql#######################



open INPUT, "mmmt.txt" or die "ERROR: cant open file mmmt.txt\n";
my @data = ();


       if(1)
	   {
	   print "$mmmt[2]\n";
	   }
	   

close INPUT;

print "The missing counter is:" ;
print ("@diff\n");


