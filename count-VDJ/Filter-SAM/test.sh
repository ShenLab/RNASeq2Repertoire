#!/bin/bash

echo "There should be 3 lines in each of the following outputs."

### The dash argument here is important! We use "-" to denote piped intput/output
### i.e. as part of a pipeline.
echo "
Testing piped input and output."
echo "TRA lines:" `cat test.sam | python filter_SAM.py --config=coordinates/TRA.json - | wc -l`
echo "TRB lines:" `cat test.sam | python filter_SAM.py --config=coordinates/TRB.json - | wc -l`
echo "IGH lines:" `cat test.sam | python filter_SAM.py --config=coordinates/IGH.json - | wc -l`

### This use case expects input files to have consistent file extensions `pre` and
### will string replace with consistent file extension `post`.
echo "
Testing filename input and output."
python filter_SAM.py --config=coordinates/TRA.json --pre=.sam --post=.TRA.sam test.sam
echo "TRA lines:" `wc -l test.TRA.sam`
python filter_SAM.py --config=coordinates/TRB.json --pre=.sam --post=.TRB.sam test.sam
echo "TRB lines:" `wc -l test.TRB.sam`
python filter_SAM.py --config=coordinates/IGH.json --pre=.sam --post=.IGH.sam test.sam
echo "IGH lines:" `wc -l test.IGH.sam`
rm test.*.sam

### For custom filtering, can specify chromosome and genomic coordinates using
### command line arguments `chrom`, `min`, and `max`.
echo "
Testing custom chromosome names."
echo "JUNK lines:" `cat test.sam | python filter_SAM.py --chrom=JUNK - | wc -l`

echo "
Finished tests!"

exit 0