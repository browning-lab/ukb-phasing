<!-- dx-header -->
# Beagle 5.4 (DNAnexus Platform App)

The Beagle software package performs genotype phasing and imputation

This is the source code for an app that runs on the DNAnexus Platform.
For more information about how to run or modify it, see
https://documentation.dnanexus.com/.
<!-- /dx-header -->

The Beagle app uses Beagle to phase genotype in a VCF file.

The five input parameters are:

  1) mem:  the maximum memory used by the java program
  2) gt:   the VCF file to be phased
  3) map:  the PLINK format genetic map file
  4) out:  the output file prefix
  5) args: additional arguments passed to Beagle (optional)

There are two output files:
  1) a log file: "${out}.log"
  2) a VCF file with genotyped genotypes: "${out}.vcf.gz"

