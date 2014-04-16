#! /bin/bash


# USAGE INFORMATION:
#
# `files.index`: an "index" file that line-by-line lists
# full (absolute) path and filename of fastq file for alignment.
#
# Script expects a single argument:
# output directory to place *.bam files
#
# By default, alignment is to a "masked" human reference genome with
# additional IMGT "pseudo-chromosome" appended.
#
# PROCESS: TCR-B region from hg19 has been masked and a corrected
#          sequence appended.
#
# PURPOSE: Required for correct alignment to TCR-B. The masking
#          prevents alignment to incorrect sequence in reference.
#          Must append corrected sequence to get correct mappings.
#
# WARNING: Output directory should _not_ have a trailing '/'
#
# 2013-10-08 -- Andy Chiang -- Initial Build


index_file="files.index"
output_dir=$1

fasta_dir="/ifs/scratch/c2b2/ys_lab/ahc2149/reference"
fasta="human_g1k_v37.MaskTRB.TRBp8.fasta"

reference=$fasta_dir/$fasta

if [ -z $output_dir ] || [ ! -d $output_dir ]; then
  echo "run-bwa-sw.sh: Bad output directory!"
  exit 1
fi

while read input_file; do
  qsub -N bwa-mem.${input_file##*/} do-bwa-mem.sh $input_file $reference $output_dir
done < $index_file