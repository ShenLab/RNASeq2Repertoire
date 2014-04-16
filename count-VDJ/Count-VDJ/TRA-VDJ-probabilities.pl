#######This code is to identify the VDJ domain combination. For each read, the combined VDJ region are printed in 
#######the output file *.VDJ.combine.sam. 
#######For each read, all regions are printed line by line in the file *.VDJ.single.sam, which will be used for 
#######counting domain usage.
#######Count domain usage can be done as:  cat *.VDJ.single.sam | cut -f 2| sort | uniq -c
####### "OtherIG222_HUGOGeneNomenclatureCommitte.PosUCSC_IgHOnly.txt" is the IgH annotation file.

#!/usr/bin/perl
use strict;
use warnings;
use List::MoreUtils qw(uniq);

### Auto_120305: 2792192 reads; Auto_..87: 1584373 reads; Auto_..90: 1504752 reads; 
### Auto_120305: Auto_..87 : Auto..90 = 1.86:1.05:1

open(FinIgHpos,'/ifs/scratch/c2b2/ys_lab/ahc2149/scripts/count-VDJ/Count-VDJ/coordinates/TRA.v37.YapingCoordinates_VDJonly.txt');
my $temps = <FinIgHpos>; # remove the header line
my @IgHanno;
while (<FinIgHpos>) {
	chomp;
	push @IgHanno, [split('\t', $_)]; # put annotation in two-dimensional array @IgHanno
}
close(FinIgHpos);

#
# THIS IS A HUGE HACK!!! Annotation coordinates in `YapingCoordinates`
# are given *relative* to start of gene, but the alignment coordinates
# are given in absolute genomic locations. Need to "bump" the location.
#
for (my $i=0;$i<=$#IgHanno;$i++){
    $IgHanno[$i][2]=$IgHanno[$i][2]+22090056;
    $IgHanno[$i][3]=$IgHanno[$i][3]+22090056;
}

my $InputFileName = $ARGV[0];
open (Fout, ">$InputFileName.VDJ.singleProbNoReadsName");
open (Fout1, ">$InputFileName.VDJ.combineProbNoReadsName");
open (mF, $InputFileName);

my $indxI=0;
my @ChrPos;

my $chr = 14;
my $start = 22090057;
my $end = 23021075;

my $size = $end-$start+1000;
for (my $i=0;$i<$size; $i++){
    $ChrPos[$i]=0;
}

my $indxP=0;
my @IgHuniq_ex;
my @IgH_join;
my @IgH_joinUniq;
my $ReadsID_ex;
my @VDJcount;

while (<mF>){
    chomp;
    my @values = split('\t', $_);
    my @num;
    my @cigar;
    my @startM;
    my @endM;
    my $indxJ=0;
    
    $startM[0] = $values[3];
    $endM[0] = $startM[0];
    while ($#values > 3 && $values[5]=~m/(\d+)([MDN])/g){
        push (@num,   $1);   # number of match, deletion, insertion, ...
        push (@cigar, $2);   # MIDNSHP=X
        $endM[$indxJ] = $startM[$indxJ]+$1;
        $indxJ++;
        $startM[$indxJ]=$endM[$indxJ-1];
    }
    
    my @IgHsum;
    my @IgHuniq;
    for (my $i=0;$i<=$#num;$i++) {
        my $anno1;		
        if ($num[$i]>=8&&$cigar[$i]=~m/^M$/){
            for (my $j=0; $j<112; $j++){
                if ($startM[$i]>=$IgHanno[$j][2]&&$startM[$i]<=$IgHanno[$j][3]){
                    push(@IgHsum,$IgHanno[$j][1]);
                    $indxJ++;
                }  
                if ($endM[$i]>=$IgHanno[$j][2]&&$endM[$i]<=$IgHanno[$j][3]){
                    push(@IgHsum, $IgHanno[$j][1]);
                } 
            }
        }
    }
    @IgHuniq = uniq @IgHsum;
    
    if ($indxP==0){
        @IgHuniq_ex = @IgHuniq;
        $ReadsID_ex = $values[0];
    }
    elsif ($values[0] eq $ReadsID_ex) {
        @IgH_join = (@IgHuniq, @IgHuniq_ex);
        @IgH_joinUniq =  uniq @IgH_join;
        @IgHuniq_ex = @IgH_joinUniq;
        $ReadsID_ex = $values[0]
    }
    elsif ($values[0] ne $ReadsID_ex){
        my (@Vonly);
        my (@Donly);
        my (@Jonly);
        for (my $i=0; $i<=$#IgHuniq_ex; $i++){
            my $iWhile = 0;
            while ($IgHuniq_ex[$i] ne $IgHanno[$iWhile][1] ){
                $iWhile++;
            }
            if ($iWhile >= 0 && $iWhile < 54 ){
                push (@Vonly,$IgHanno[$iWhile][1]);
            } 
            elsif ($iWhile >= 54 && $iWhile < 112 ){
                push (@Jonly,$IgHanno[$iWhile][1]);
            }
        }
        for (my $i=0; $i<=$#Vonly;$i++){
            my $prob = 1/($#Vonly+1);
            print Fout "$Vonly[$i]\t$prob\n";
        }
        for (my $i=0; $i<=$#Donly;$i++){
            my $prob = 1/($#Donly+1);
            print Fout "$Donly[$i]\t$prob\n";
        }
        for (my $i=0; $i<=$#Jonly;$i++){
            my $prob = 1/($#Jonly+1);
            print Fout "$Jonly[$i]\t$prob\n";
        }
        for (my $i=0; $i<=$#Vonly;$i++){
            for (my $j=0; $j<=$#Donly; $j++){
                my $prob = 1/($#Vonly+1)/($#Donly+1);
                print Fout1 "$Vonly[$i] $Donly[$j]\t$prob\n"
            }
        }
        for (my $i=0; $i<=$#Vonly;$i++){
            for (my $j=0; $j<=$#Jonly; $j++){
                my $prob = 1/($#Vonly+1)/($#Jonly+1);
                print Fout1 "$Vonly[$i] $Jonly[$j]\t$prob\n"
            }
        }
        for (my $i=0; $i<=$#Donly;$i++){
            for (my $j=0; $j<=$#Jonly; $j++){
                my $prob = 1/($#Donly+1)/($#Jonly+1);
                print Fout1 "$Donly[$i] $Jonly[$j]\t$prob\n"
            }
        }
        @IgHuniq_ex = @IgHuniq;
        $ReadsID_ex = $values[0];
    }
    $indxP++;	
}

my (@Vonly);
my (@Donly);
my (@Jonly);
for (my $i=0; $i<=$#IgHuniq_ex; $i++){
    my $iWhile = 0;
    while ($IgHuniq_ex[$i] ne $IgHanno[$iWhile][1] ){			
        $iWhile++;
    }
    if ($iWhile >= 0 && $iWhile < 54 ){
        push (@Vonly,$IgHanno[$iWhile][1]);		
    } 
    elsif ($iWhile >= 54 && $iWhile < 112 ){
        push (@Jonly,$IgHanno[$iWhile][1]);			
    }		
}
for (my $i=0; $i<=$#Vonly;$i++){
    my $prob = 1/($#Vonly+1);
    print Fout "$Vonly[$i]\t$prob\n";
}
for (my $i=0; $i<=$#Donly;$i++){
    my $prob = 1/($#Donly+1);
    print Fout "$Donly[$i]\t$prob\n";
}
for (my $i=0; $i<=$#Jonly;$i++){
    my $prob = 1/($#Jonly+1);
    print Fout "$Jonly[$i]\t$prob\n";
}
for (my $i=0; $i<=$#Vonly;$i++){
    for (my $j=0; $j<=$#Donly; $j++){
        my $prob = 1/($#Vonly+1)/($#Donly+1);
        print Fout1 "$Vonly[$i] $Donly[$j]\t$prob\n"
    }
}
for (my $i=0; $i<=$#Vonly;$i++){
    for (my $j=0; $j<=$#Jonly; $j++){
        my $prob = 1/($#Vonly+1)/($#Jonly+1);
        print Fout1 "$Vonly[$i] $Jonly[$j]\t$prob\n"
    }
}
for (my $i=0; $i<=$#Donly;$i++){
    for (my $j=0; $j<=$#Jonly; $j++){
        my $prob = 1/($#Donly+1)/($#Jonly+1);
        print Fout1 "$Donly[$i] $Jonly[$j]\t$prob\n"
    }
}

close(Fout);
close(Fout1);
close(mF);

exit 0;
