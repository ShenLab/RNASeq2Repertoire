#!/bin/bash

#$ -cwd
#$ -V
#$ -R y
#$ -l mem=12G,time=24::
#$ -o logs
#$ -e errs


# TODO: Write
#       great
#       docs!


fastq_dump="/ifs/scratch/c2b2/ys_lab/ahc2149/software/sratoolkit.2.3.3-4-centos_linux64/bin/fastq-dump"


input_file=$1
output_dir=$2


if [ -z $input_file ] || ! [ -a $input_file ]; then
  echo "do-sra-unpack.sh: Bad input file! Ka-chow!"
  exit 1
fi

if [ -z $output_dir ] || ! [ -d $output_dir ]; then
  echo "do-sra-unpack.sh: Bad output directory! Ka-chigga!"
  exit 1
fi


start_time=$( date "+%s" )
echo [INIT] `date`
echo [HOST] `hostname`

echo " "
echo [FILENM] $input_file
echo [OUTDIR] $output_dir


UNPACK_CMD="$fastq_dump --split-spot --outdir $output_dir --gzip --origfmt $input_file"


echo " "
echo [UNPACK] $UNPACK_CMD

echo " "
$UNPACK_CMD # Unpack the *.sra file to a gzipped *.fastq file.


stop_time=$( date "+%s" )
echo " "
echo [TIME] $(( $stop_time - $start_time ))
echo [TERM] `date`


exit 0