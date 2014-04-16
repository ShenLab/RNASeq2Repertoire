BWA-mem Alignment Scripts
=========================


A set of scripts used to align using BWA-MEM instead of BWA-SW (previously used). Two primary motivations:

 1. Speed
 2. Maintenance

As of 2013, the "preferred" `bwa` tool is BWA-MEM. Heng Li et. al. actively maintain that branch of the `bwa` project, as it boasts flexibility in terms of read length and improved performance.


0. Quickstart
-------------

 1. Populate `files.index` with full path and filename for each `fastq` to be aligned.
 2. Run `run-bwa-mem.sh` with argument of output directory. No trailing backslash!

```
% ./run-bwa-mem.sh /path/to/output
```


1. Dependencies
---------------

These scripts depend on having a working install of the `bwa` package. On Titan (C2B2), these are expected to be in the common `ngs` group software directory.


2. File System
--------------

Contents of the filesystem:

 - `do-bwa-mem.sh`: Worker batch script intended for submission to Grid Engine.
 - `run-bwa-mem.sh`: Wrapper script. Running this submits each file in index to SGE.
 - `files.index`: Text file which specifies which files need to be aligned.
 - `errs/`: Subdirectory for run-specific standard error.
 - `logs/`: Subdirectory fo run-specific standard output logs.


3. Authors
----------

 - Andy Chiang (Columbia University, Department of Biomedical Informatics)
 - Boris Grinshpun (Columbia University, Department of Systems Biology)

