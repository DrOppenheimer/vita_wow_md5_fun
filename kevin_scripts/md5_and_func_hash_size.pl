#!/usr/bin/env perl

use warnings;
use Getopt::Long;
use Cwd;
#use Cwd 'abs_path';
#use FindBin;
use File::Basename;
#use Statistics::Descriptive;
use Devel::Size qw(size total_size);

my($file_in, $help, $verbose, $debug);



# check input args and display usage if not suitable
if ( (@ARGV > 0) && ($ARGV[0] =~ /-h/) ) { &usage(); }

if ( ! GetOptions (
		   "i|file_in=s"  => \$file_in,
		   "h|help!"      => \$help, 
		   "v|verbose!"   => \$verbose,
		   "d|debug!"     => \$debug
		  )
   ) { &usage(); }

unless ( @ARGV > 0 || $file_in ) { &usage(); }
if( $help ){ &usage(); }

# open files
my $file_out = "REDUNDANT_MD5S.txt";
open(FILE_IN, "<", $file_in) or die "Can't open FILE_IN $file_in";
if($debug){
  open(FILE_OUT, ">", $file_out) or die "Can't open $file_out";
}

# Create object to hold md5 function hash
my $md5_hash;

# First get md5 for the best hit (one with the highest bit score)
# assumes that the file is already sorted this way 
while (my $line = <FILE_IN>){
  chomp $line;
  my @line_array = split("\t", $line);
  unless( $md5_hash -> { $line_array[0] } ){
    $md5_hash -> { $line_array[0] } = $line_array[1];
  }else{
    if($debug){
      print FILE_OUT $line."\n";
    }
  }
}

# count number of keys
my @key_array=keys($md5_hash);
my $num_keys=$#key_array;

# get the size of the hash - in bytes - then cal MB and GB
my $hash_size = total_size($md5_hash);
#my $hash_size_mb = int $hash_size/1048576;
#my $hash_size_gb = int $hash_size/1073741824;
my $hash_size_mb = $hash_size/1048576;
my $hash_size_gb = $hash_size/1073741824;

print STDOUT "\n"."hash size = ".$hash_size." bytes"."\n";
print STDOUT "hash size = ".$hash_size_mb." MB"."\n";
print STDOUT "hash size = ".$hash_size_gb." GB"."\n";
print STDOUT "\n"."num keys  = ".$num_keys."\n\n";

sub usage {
  my ($err) = @_;
  my $script_call = join('\t', @_);
  my $num_args = scalar @_;
  print STDOUT ($err ? "ERROR: $err" : '') . qq(
script:               $0

DESCRIPTION:
Read through md5_annot tab delimited file, Determine size of hash created from it
   
USAGE: md5_and_func_hash_size.pl -i file_in (tab delimited two columns, md5 and annotation)
 
    -i|--file_in (string)  no default
 _______________________________________________________________________________________

    -h|help                       (flag)       see the help/usage
    -v|verbose                    (flag)       run in verbose mode
    -d|debug                      (flag)       run in debug mode
                                               Note that debug creates REDUNDANT_MD5S.txt
                                               contains redundant MD5S, from 2nd instance on

);
  exit 1;
}
