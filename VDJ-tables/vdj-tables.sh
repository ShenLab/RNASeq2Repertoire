#!/bin/bash

WORKING_DIR="wd"

OUTPUT_PREFIX="vdj"
OUTPUT_DIR="${WORKING_DIR}/vdj-tables/tsv"
SCRIPT="${WORKING_DIR}/vdj-tables/vdj-table.py"

function make_table {
  local SEQUENCE=$1
  local METHOD=$2
  local TYPE=$3

  local OUTPUT_FILE="${OUTPUT_DIR}/${OUTPUT_PREFIX}-${SEQUENCE}-${METHOD}-${TYPE}.tsv"
  local INPUT_DIR="${WORKING_DIR}/vdj-${METHOD}/${SEQUENCE}"
  local INPUT_PATTERN="*.${TYPE}ProbNoReadsName"

  python $SCRIPT `find $INPUT_DIR -name $INPUT_PATTERN` > $OUTPUT_FILE
}

pushd $WORKING_DIR &> /dev/null
mkdir --parents $OUTPUT_DIR

SEQUENCES=( IGH TRA TRB )
METHODS=( mem sw )
TYPES=( single combine )

for SEQ in "${SEQUENCES[@]}"; do
  for MET in "${METHODS[@]}"; do
    for TYP in "${TYPES[@]}"; do
      make_table $SEQ $MET $TYP
    done
  done
done

popd &> /dev/null
exit 0
