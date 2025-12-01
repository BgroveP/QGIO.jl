# QGIO.jl

## Goal: 

The goal is to have a simple interface that is reuseable across file types and returns one standardized format to julia.
```
# Read haplotypes
QGIO.haplotypes("imaginary/file.vcf")
QGIO.haplotypes("imaginary/file.vcf.gz")
QGIO.haplotype("imaginary/file.bim", "imaginary/file.bam", "imaginary/file.fam")

```
