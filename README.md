# A pipeline for phasing 150,119 sequenced genomes in the UK Biobank

This document contains instructions for running a pipeline that will filter, phase, and index the genotypes in the first release of UK Biobank whole genome sequence data **[1]**. The output data contain 406,184,991 single nucleotide variants and 150,119 individuals. The pipeline is described in "[Statistical phasing of 150,119 sequenced genomes in the UK Biobank](https://www.biorxiv.org/content/10.1101/2022.10.03.510691v1)" **[2]**. 

This pipeline is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY and without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Author: [Brian Browning](https://faculty.washington.edu/browning).  
Last updated: November 9, 2022

## Contents

* [Before starting](#before-starting)
* [Upload resources to the cloud](#upload-resources-to-the-cloud)
* [Phase the genomes](#phase-the-genomes)
* [References](#references)

## Before starting

1. Obtain [tier 3 access](https://www.ukbiobank.ac.uk/enable-your-research/costs) to the UK Biobank data.
2. [Create a project on the UK Biobank Research Analysis Platform and dispense data to your project](https://dnanexus.gitbook.io/uk-biobank-rap/getting-started/creating-a-project). It may take several hours before the data is fully dispensed.
3. Install the DNAnexus **dx** command line client on a unix or linux system. The **dx** command line client is part of the [dx-toolkit](https://documentation.dnanexus.com/downloads).
4. If necessary, increase your [DNAnexus spending limit](https://documentation.dnanexus.com/admin/billing-and-account-management#increasing-your-spending-limit). The cost phasing of chromosomes 1-22 and X with this pipeline is estimated to be between 2,300 and 3,500 British pounds (GBP), depending on how much of the data filtering can be done on lower-cost "spot" compute instances. The cost of storing the compressed, phased data for chromosomes 1-22 and X is around 10 British pounds per month.
5. In your DNAnexus user profile, set your job notification policy to "Only on Failure".  This will reduce the number of e-mails that you receive.  Access your user profile by clicking on the menu in the upper right corner of the [Research Analysis Platform](https://ukbiobank.dnanexus.com/) web interface.  Then set your job notification policy in the "Email" section of the "User Account" tab.

[Contents](#contents)

## Upload resources to the cloud

First, log into DNAnexus platform with the [dx login](https://documentation.dnanexus.com/user/login-and-logout) command.  Use the same username and password that you use for the [Research Analysis Platform](https://ukbiobank.dnanexus.com/) web interface.

Next, run the following three commands.  When you run the third command, replace **PROJECT** with the name of your DNAnexus project.
```
git clone https://github.com/browning-lab/ukb-phasing.git
cd ukb-phasing
./upload.resources PROJECT
```
These commands will:
1. Download a copy of this git repository to your working directory
2. Change your working directory to the top-level "ukb-phasing" directory in the repository
3. Select the project that you substituted for "PROJECT" as your current DNAnexus project
4. Create three folders (_apps/_, _maps/_, and  _phased/_) in your DNAnexus project.
5. Copy genetic maps for each chromosome to the _maps/_ folder, and copy five DNAnexus applets to the _apps/_ folder.

[Contents](#contents)

## Phase the genomes

From the top-level "ukb-phasing" directory in the downloaded repository, run the following command to phase a chromosome. 
When you run the command, replace **PROJECT** with the name of your DNAnexus project, and replace **CHROM** with  **1**, **2**, ..., **22**, or **X**.
```
./phase.ukb PROJECT CHROM
```
This command will filter the chromosome markers with bcftools **[3]**, phase the filtered genotypes with Beagle **[4]**, and index the output phased VCF file with tabix **[5]**. The run time for a chromosome is between one-half and three days. Chromosomes can be processed in parallel.

The marker filter restricts the analysis to SNVs with AAScore > 0.95 and missing genotypes rate < 0.05.  You can include structural variants by changing
```
filter='filter=FILTER="PASS"&INFO/AAScore[*]>0.95&F_MISSING<0.05&TYPE="snp"'
```
to
```
filter='filter=FILTER="PASS"&INFO/AAScore[*]>0.95&F_MISSING<0.05'
```
in the _phase.ukb_ file.  Changing the marker filter will affect both computational cost and phase accuracy **[2]**.

The output phased VCF file is saved on the [Research Analysis Platform](https://ukbiobank.dnanexus.com/) as "**PROJECT**:/phased/chr**CHROM**.filt.phased.vcf.gz", where **PROJECT** is the name of your project, and **CHROM** is the chromosome number.  A temporary folder, named  "**PROJECT**:/tmp.chr**CHROM**/", is used to store interim files during the analysis.  The temporary folder is deleted at the end of the analysis.

You can monitor the progress of your jobs with the [Research Analysis Platform](https://ukbiobank.dnanexus.com/) web interface.  Click on the "PROJECTS" menu and choose "All Projects".  Click on the name of your project in the list of projects, and then click on the "MONITOR" tab.

[Contents](#contents)

## References

**[1]** B V Halldorsson, et al. The sequences of 150,119 genomes in the UK Biobank. Nature 2022 Jul; 607(7920):732-740. doi: [10.1038/s41586-022-04965-x](https://doi.org/10.1038/s41586-022-04965-x). 

**[2]** B L Browning, S R Browning. Statistical phasing of 150,119 sequenced genomes in the UK Biobank. doi: [10.1101/2022.10.03.510691](https://doi.org/10.1101/2022.10.03.510691).

**[3]** Danecek P, et al. Twelve years of SAMtools and BCFtools. Gigascience. 2021 Feb; 10(2):giab008. doi: [10.1093/gigascience/giab008](https://doi.org/10.1093/gigascience/giab008).

**[4]** B L Browning, X Tian, Y Zhou, and S R Browning. Fast two-stage phasing of large-scale sequence data. Am J Hum Genet 2021 Oct; 108(10):1880-1890. doi: [10.1016/j.ajhg.2021.08.005](https://doi.org/10.1016/j.ajhg.2021.08.005).

**[5]** H Li. Tabix: fast retrieval of sequence features from generic TAB-delimited files. Bioinformatics, 2011 Mar; 27(5):718–719. doi: [10.1093/bioinformatics/btq671](https://doi.org/10.1093/bioinformatics/btq671)

[Contents](#contents)

