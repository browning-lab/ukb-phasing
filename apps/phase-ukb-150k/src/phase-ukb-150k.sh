#!/bin/bash
# phase-ukb-150k 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://documentation.dnanexus.com/developer for tutorials on how
# to modify this file.

main() {

  echo "phase-ukb-150k started on $(date)"

  echo "Value of project:               '${project}'"
  echo "Value of chrom:                 '${chrom}'"
  echo "Value of filter:                '${filter}'"
  echo "Value of beagle_instance_type:  '${beagle_instance_type}'"
  echo "Value of beagle_mem:            '${beagle_mem}'"
  echo "Value of beagle_args:           '${beagle_args}'"

  in_dir="${project}:/Bulk/Whole genome sequences/Whole genome GraphTyper joint call pVCF/"
  tmp_dir="${project}:/tmp.chr${chrom}/"
  apps_dir="${project}:/apps/"
  maps_dir="${project}:/maps/"
  phased_dir="${project}:/phased/"

  dx mkdir -p "${tmp_dir}" "${phased_dir}"

  function filter () {
    if [ $# -ne 4 ]; then
      echo "usage: filter [start_block] [end_block] [header] [instance_type]"
      exit 1
    fi
    start_block=$1
    end_block=$2
    header=$3
    instance_type=$4

    in_vcf_args=$( seq ${start_block} ${end_block} | sed -e "s!^!-i \"in_vcf=\${in_dir}ukb23352_c${chrom}_b!" -e "s!\$!_v1.vcf.gz\"!" | tr '\n' ' ')
    out_filename=chr${chrom}.b${start_block}-${end_block}.filt.gz

    eval "dx run \"\${apps_dir}filter-vcfs\" \
      -y \
      --wait \
      --brief \
      --detach \
      --instance-type ${instance_type} \
      --priority normal \
      --extra-args '{\"executionPolicy\": {\"restartOn\": {\"SpotInstanceInterruption\": 2}, \"maxSpotTries\": 1}}' \
      --destination \"\${tmp_dir}\" \
      --name filter.c${chrom}.b${start_block}-${end_block} \
      ${in_vcf_args} \
      -i \"filter=\${filter}\" \
      -i header=${header} \
      -i out_filename=${out_filename}" &
    }

  filter 0 0 "true" mem1_ssd1_v2_x2
  step="100"
  instance_type="mem1_ssd1_v2_x72"
  max_block=$(dx ls "${in_dir}ukb23352_c${chrom}_b*_v1.vcf.gz" | tail -n +2 | wc -l)
  for block_start in $(seq 1 ${step} ${max_block}); do
    block_end=$(( ${block_start} + ${step} - 1 ))
    block_end=$(( ${max_block} < ${block_end} ? ${max_block} : ${block_end} ))
    filter ${block_start} ${block_end} "false" ${instance_type}
    sleep 15
  done
  wait

  input_files=$(dx ls "${tmp_dir}/chr${chrom}.b*.filt.gz" | sort -V | sed -e "s!^!-i file=${tmp_dir}!" | tr '\n' ' ')

  dx run ${apps_dir}cat-files \
    -y \
    --wait \
    --brief \
    --detach \
    --priority normal \
    --extra-args '{"executionPolicy": {"restartOn": {"SpotInstanceInterruption": 2}, "maxSpotTries": 1}}' \
    --destination ${tmp_dir} \
    --name cat-files.chr${chrom} \
    ${input_files} \
    -i out_filename=chr${chrom}.filt.unph.vcf.gz

  dx run ${apps_dir}beagle \
    -y \
    --instance-type ${beagle_instance_type} \
    --wait \
    --detach \
    --priority high \
    --name "beagle.chr${chrom}" \
    --destination "${phased_dir}" \
    -i "mem=${beagle_mem}" \
    -i "gt=${tmp_dir}chr${chrom}.filt.unph.vcf.gz" \
    -i "map=${maps_dir}plink.chr${chrom}.GRCh38.map" \
    -i "out=chr${chrom}.filt.phased" \
    -i "args=${beagle_args}"

  dx run ${apps_dir}tabix \
    -y \
    --wait \
    --detach \
    --priority normal \
    --extra-args '{"executionPolicy": {"restartOn": {"SpotInstanceInterruption": 2}, "maxSpotTries": 1}}' \
    --destination "${phased_dir}" \
    --name "tabix.chr${chrom}" \
    -i "in_vcf=${phased_dir}chr${chrom}.filt.phased.vcf.gz" \
    -i "out_filename=chr${chrom}.filt.phased.vcf.gz.tbi"

  dx rm "${tmp_dir}chr${chrom}.b*.filt.gz"
  dx rm "${tmp_dir}chr${chrom}.filt.unph.vcf.gz"
  dx rmdir ${tmp_dir}

  echo "phase-ukb-150k finished on $(date)"
}
