#!/bin/bash

# USAGE INFORMATION:
#
# This is a wrapper script that distributes VDJ counting to multiple workers.
#
# 1. Fill out `files.index` with absolute path and names of alignment files.
# 2. Execute `run-VDJ-count.sh` with argument: output directory.
#
# WARNING: Output directory should not have trailing "/"
#
# 2013-11-08 -- Andy Chiang -- Initial Build


index_file="files.index"
output_dir=$1

if [ -z $output_dir ] || [ ! -d $output_dir ]; then
  echo "run-VDJ-count.sh: Bad output directory."
  exit 1
fi

while read input_file; do
  qsub -N VDJ-count.${input_file##*/} do-VDJ-count.sh $input_file $output_dir
done < $index_file