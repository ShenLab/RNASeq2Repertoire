#!/bin/bash

#$ -cwd
#$ -o logs
#$ -e errs
#$ -R y
#$ -l mem=5G,time=12::

# USAGE INFORMATION:
#
# Worker batch script that executes TCR counting.
#
# Script expects two arguments:
#  - input filename
#  - output directory
#
# WARNING: Output directory should not have trailing "/"
#
# 2013-11-08 -- Andy Chiang -- Initial build.
# 2013-11-11 -- Andy Chiang -- Reduce space + time requirements.

time1=$( date "+%s" )
echo [INIT] `date`
echo [HOST] `hostname`



INPUT_FILENAME=$1
TRA_DIR="${2}/TRA"
TRB_DIR="${2}/TRB"
IGH_DIR="${2}/IGH"

mkdir --parents $TRA_DIR
mkdir --parents $TRB_DIR
mkdir --parents $IGH_DIR


BASE_FILENAME=`basename $INPUT_FILENAME .bam`
TRA_FILENAME=${TRA_DIR}/${BASE_FILENAME}.TRA.sam
TRB_FILENAME=${TRB_DIR}/${BASE_FILENAME}.TRB.sam
IGH_FILENAME=${IGH_DIR}/${BASE_FILENAME}.IGH.sam

FILTER_WD="/ifs/scratch/c2b2/ys_lab/ahc2149/scripts/count-VDJ/Filter-SAM"

pushd $FILTER_WD > /dev/null
samtools view $INPUT_FILENAME | python filter_SAM.py --config=coordinates/TRA.json - > $TRA_FILENAME
samtools view $INPUT_FILENAME | python filter_SAM.py --config=coordinates/IMGT-TRB.json - > $TRB_FILENAME
samtools view $INPUT_FILENAME | python filter_SAM.py --config=coordinates/IGH.json - > $IGH_FILENAME
popd > /dev/null

SORTED_TRA_FILENAME=${TRA_DIR}/${BASE_FILENAME}.TRA.sort.sam
SORTED_TRB_FILENAME=${TRB_DIR}/${BASE_FILENAME}.TRB.sort.sam
SORTED_IGH_FILENAME=${IGH_DIR}/${BASE_FILENAME}.IGH.sort.sam

sort $TRA_FILENAME > $SORTED_TRA_FILENAME
sort $TRB_FILENAME > $SORTED_TRB_FILENAME
sort $IGH_FILENAME > $SORTED_IGH_FILENAME

rm $TRA_FILENAME
rm $TRB_FILENAME
rm $IGH_FILENAME

COUNT_WD="/ifs/scratch/c2b2/ys_lab/ahc2149/scripts/count-VDJ/Count-VDJ"
pushd $COUNT_WD > /dev/null
perl TRA-VDJ-probabilities.pl $SORTED_TRA_FILENAME
perl TRB-VDJ-probabilities.pl $SORTED_TRB_FILENAME
perl IGH-VDJ-probabilities.pl $SORTED_IGH_FILENAME
popd > /dev/null



time2=$( date "+%s" )
echo [TIME] $(( $time2 - $time1 ))
echo [TERM] `date`