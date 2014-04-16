#!/bin/bash


# USAGE INFORMATION:
#
# This script wraps calls to Sun Grid Engine scheduler for
# executing the `do-sra-unpack.sh` batch job. The following
# parameters should be used to customize the run behaviour.
#
#
# `files.index` expected to contain a list of *.sra files
# that will be unpacked to *.fastq files. This file must be
# populated.
#
# `output_dir` should not have a trailing '/'.
#
# `infile_ext` is used by call to `basename`.
#
#
# 2013-10-14 -- Andy Chiang


index_file="files.index"
output_dir="/ifs/scratch/c2b2/ys_lab/ahc2149/Snyderome/fastq-reads"
infile_ext=".lite.sra"

if [ -z $index_file ] || [ ! -e $index_file ]; then
  echo "run-sra-unpack.sh: Bad index filename!"
  exit 1
fi

if [ -z $output_dir ] || [ ! -d $output_dir ]; then
  echo "run-sra-unpack.sh: Bad output directory!"
  exit 1
fi

while read input_file; do
  a_basename=`basename $input_file $infile_ext`
  qsub -N sra-up.${a_basename} do-sra-unpack.sh $input_file $output_dir
done < $index_file

exit 0