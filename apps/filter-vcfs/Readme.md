<!-- dx-header -->
# filter-vcfs (DNAnexus Platform App)

Apply a user-specified filter to a list of VCF files

This is the source code for an app that runs on the DNAnexus Platform.
For more information about how to run or modify it, see
https://documentation.dnanexus.com/.
<!-- /dx-header -->

The filter-vcf app filters and concatenates a list of VCF file.

The four input parameters are:

  1) in_vcf:       an input VCF file (use one in_vcf parameter per input file)
  2) filter:       the bcftools filter expression to be applied
  3) header:       'true' if output files should have a VCF header and 'false' otherwise
  4) out_filename: filename of bgzip-compressed, filtered output file

