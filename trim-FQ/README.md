Trim FASTQ Files
================

Scripts for truncating reads based on moving-average quality scores. The logic behind this is to reduce mismatches and increase the accuracy of downstream processing.


0. Quickstart
-------------

Copy to `files.index` a list of absolute-path-ed files to be trimmed. Check in `trim.pl` that the output location and filename extension are sensible / acceptable. Then deploy `trim.pl` jobs to Grid Engine via:

```
% ./run-trim.sh
```

1. Authors
----------

 - Andy Chiang (Columbia University, Department of Biomedical Informatics)
 - Yaping Feng (Columbia University, Department of Systems Biology)

