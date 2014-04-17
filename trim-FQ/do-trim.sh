#! /bin/bash

#$ -cwd
#$ -o logs
#$ -e errs
#$ -R y
#$ -l mem=8G,time=24::

# USAGE INFORMATION:
#
# Batch script to execute perl script. So much indirection!
# Andy couldn't be bothered to figure out how to run the
# perl script directly.
#
# Arguments: Expects one argument:
# *.fastq.gz file to be trimmed by trim.pl
#
# 2013-10-01 -- Andy Chiang

BASE_WD=`pwd`

input_file=$1
fastq_file=${input_file%%.gz}
trim_script="${BASE_WD}/trim.pl"

gunzip -c $input_file > $fastq_file
$trim_script $fastq_file

exit 0
