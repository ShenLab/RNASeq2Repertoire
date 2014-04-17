#! /bin/bash


#$ -cwd
#$ -o logs
#$ -e errs
#$ -pe smp 4
#$ -R y
#$ -l mem=10G,time=24::



# USAGE INFORMATION:
#
# Worker batch job script for running BWA-mem. Intended
# for use with Grid Engine on cluster. Should also work
# as a normal shell script.
#
# Arguments: Expects three (3) arguments:
# *.fastq input w/ sequenced (possibly quality trimmed) reads
# *.fasta genome reference file to be aligned to
# directory to hold output *.bam files
#
# WARNING: Output path should _not_ have trailing '/'
#
# 2013-10-08 -- Andy Chiang -- Initial Development



time1=$( date "+%s" )
echo [INIT] `date`
echo [HOST] `hostname`

BWA=bin/bwa

fastq_file=$1
reference=$2
output_dir=$3

output_name=`basename $fastq_file .fastq`

echo [FASTA] $reference
echo [FASTQ] $fastq_file
echo [WRITE] $output_name

$BWA mem -a -t 4 -E 1 -O 4 -w 100 -T 10 -r 1 $reference $fastq_file > $output_dir/$output_name.sam
#         ^  ^    ^    ^    ^      ^     ^
#         |  |    |    |    |      |     |                  #
#         |  |    |    |    |      |     internal seeds     # Parameters for running
#         |  |    |    |    |      minimum score to output  # bwa-mem that are chosen
#         |  |    |    |    band width for banded alignment # are mostly inherited
#         |  |    |    gap open penalty                     # from Boris Grinshpun's
#         |  |    gap extension penalty                     # bwa scripts ... we mimic  
#         |  number of threads                              # their alignment settings.
#         output all alignments                             #

samtools view -bS $output_dir/$output_name.sam > $output_dir/$output_name.bam

rm $output_dir/$output_name.sam


time2=$( date "+%s" )
echo [TIME] $(( $time2 - $time1 ))
echo [TERM] `date`
