
### Common Gotchas:

 - Be sure that the specified chromosome is consistent with annotation
    - Otherwise, will see an empty output.


### Dependencies

 - Python (> 2.5)
 - `simplejson` (3.3.1)


### To-Do:

 - Use `pysam` to get `.bam` file reading
    - Requires `io` library from Python 2.6
    - And dependencies: `Cython`, `Pyrex`, etc.
 - Should really control the Python environment more closely.
