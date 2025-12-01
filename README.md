# QGIO.jl

## Goal: 
The goal is to have a simple interface that is reuseable across file types and returns one standardized format to julia.


### Example
```
# Read haplotypes
QGIO.haplotypes("imaginary/file.vcf")
QGIO.haplotypes("imaginary/file.vcf.gz") 
QGIO.haplotypes("imaginary/file.bim", "imaginary/file.bam", "imaginary/file.fam") # Doesnt exist yet

```

## Functionalities
1. Read data from relevant formats.
2. Write data to relevant formats (and my consequence, enable conversion).
3. Subset data while loading such that not all needs to be explicitly loaded.
4. Efficient utility functions for the internal data types such as allele frequencies

## Current structure (up for debate)
.. / 
  QGIO /
    ...
    src /
      ...
      VCF /

