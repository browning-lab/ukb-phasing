<!-- dx-header -->
# phase-ukb-150k (DNAnexus Platform App)

Phases 150,119 sequenced samples in the UK Biobank

This is the source code for an app that runs on the DNAnexus Platform.
For more information about how to run or modify it, see
https://documentation.dnanexus.com/.
<!-- /dx-header -->

The phase-ukb-150k app filters and phases a chromosome of sequence data
for 150,119 individuals in UK Biobank.

The six input parameters are:

  1) project:              the DNAnexus project
  2) chrom:                a chromosome index (1, 2, ..., 22, or X)
  3) filter:               a bcftools filter expression
  4) beagle_instance type: instance type for Beagle analysis
  5) beagle_mem:           java -Xmx parameter
  6) beagle_args           additional Beagle arguments

The phased VCF output file is saved as "${project}:phased/chr${chrom}.filt.phased.vcf.gz"
