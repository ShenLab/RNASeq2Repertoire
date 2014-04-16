#! /bin/bash


# USAGE INFORMATION:
#
# `files.index` should provide list of *.fastq files
# to be trimmed.
#
# Script takes no arguments. For now, the output location
# is baked into the perl script.
#
# 2013-10-01 -- Andy Chiang


index_file="files.index"

while read input_file; do
  qsub -N trim.${input_file##*/} do-trim.sh $input_file
done < $index_file