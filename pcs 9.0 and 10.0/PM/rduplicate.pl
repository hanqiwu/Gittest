use strict;              # Global variables must be qualified lik
                         # $Package::variable, others must be defined with my.
use English;             # Get aliases for the built-in punctuation variables.
use Carp;                # Get detailed trace back



my %hash;
my $script = $0; # Get the script name

sub usage 
{
        printf("Usage:\n");
        printf("perl $script target destni\n");

}

# If the number of parameters less than 2 ,exit the script
if ( $#ARGV+1 < 2) {

        &usage;
        exit 0;
}


my $source_file = $ARGV[0]; #File need to remove duplicate rows
my $dest_file = $ARGV[1]; # File after remove duplicates rows

open (FILE,"<$source_file") or die "Cannot open file $!\n";
open (SORTED,">$dest_file") or die "Cannot open file $!\n";

while(defined (my $line = <FILE>))
{
        chomp($line);
        $hash{$line} += 1;
        # print "$line,$hash{$line}\n";
}

foreach my $k (keys %hash) {
        print SORTED "$k\n";#改行打印出列和该列出现的次数到目标文件
}
close (FILE);
close (SORTED);