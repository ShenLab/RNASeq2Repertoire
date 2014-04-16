#!/usr/bin/perl

use strict;
use warnings;

my @Readsname;
my $NumFile=0;
my @line;
my $l;
my $number;
my %qtable;
my $inFile = $ARGV[0];

open (mF, $inFile);
my $coreName;
if ($inFile =~ m/.*\/(.+)\..+/){
	$coreName=$1;
}
open(Fout, ">/ifs/scratch/c2b2/ys_lab/ahc2149/Snyderome/fastq-trimmed/$coreName.trimmed.fastq");
open(Fout2, ">/ifs/scratch/c2b2/ys_lab/ahc2149/Snyderome/fastq-trimmed/$coreName.removed.txt");
my $wSize = 5;
my $cutoffM = 15;
my $indx=0;

while(<mF>){
  	my @means;
  	# if it is the line before the quality line
  	chomp(my $readID = $_);
  	chomp(my $dnaSeq = <mF>);
  	my $tmp = <mF>;
  	chomp(my $l = <mF>);  # get the quality line
	@line = split(//,$l); # divide in chars
    for(my $i = 0; $i <=$#line; $i+=$wSize){ # for each char
      my $total = 0;
 	  for (my $j=$i;$j<$i+$wSize;$j++){
			if (defined $line[$j]){
	#		print "$i, $j, $line[$j]\n";
 	  		$number = ord($line[$j])-33;
 	  		$total+=$number;
 	  		}
 	  	}
 	 	my $mean = $total/$wSize; 
 	  	push(@means, $mean);
 	  
     }
      my $indxm = ($#line+1)/$wSize; ###the first window >15 from 3'-end  
    while ($means[$indxm-1]<=15 &&$indxm>=0){ 
      	$indxm--;
      }
    if ($indxm>=0){ ###all windows are trimmed if $indxm<0
      my $indxn = 0;
      while ($means[$indxn]<=15 && $indxn<($#line+1)/$wSize){
      	$indxn++;
      }
     
    #my $thresh=100;
    if ($indxn<$indxm){
       	my $cutPos3 = $indxn*$wSize;
    	my $cutLen = $wSize*($indxm-$indxn);
	  #print Fout "\n*****$indxm\t$cutPos3\t$cutLen\n";
     	my $trimDna = substr($dnaSeq, $cutPos3, $cutLen);
     	my $trimQs = substr($l,$cutPos3, $cutLen);
	   #if($cutLen>=$thresh){
      	      print Fout "$readID\t$cutPos3\t$cutLen\n"; #<-- add in this part for quick histograms
     	      print Fout "$trimDna\n";
    	      print Fout "$tmp";
     	      print Fout "$trimQs\n";
     	   #}
	   #else {
	   #	print Fout2 "$readID\tremoved\n";
	   #}
  	}
  	else {
  		print "$readID\n";
  	}
    }
    else {
	print Fout2 "$readID\tremoved\n";
	print Fout2 "N\tremoved\n";
	print Fout2 "+\tremoved\n";
	print Fout2 "#\tremoved\n";
     }	  
}

close(Fout2);
close(Fout);
close(mF);	
