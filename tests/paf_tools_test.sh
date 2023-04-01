#!/usr/bin/env bash

# Script to test pafs

# exit when any command fails
set -e

# log the commands its running
#set -x

working_dir=$(mktemp -d -t temp_chains-XXXXXXXXXX)
# Make sure we cleanup the temp dir
trap "rm -rf ${working_dir}" EXIT

# Get the sequences
wget https://raw.githubusercontent.com/UCSantaCruzComputationalGenomicsLab/cactusTestData/master/evolver/mammals/loci1/simCow.chr6 -O ${working_dir}/simCow.chr6.fa
wget https://raw.githubusercontent.com/UCSantaCruzComputationalGenomicsLab/cactusTestData/master/evolver/mammals/loci1/simDog.chr6 -O ${working_dir}/simDog.chr6.fa

# Run lastz
lastz ${working_dir}/*.fa --format=paf > ${working_dir}/output.paf

# Run paf_view
echo "minimum local alignment identity"
paf_view -i ${working_dir}/output.paf ${working_dir}/*.fa | cut -f9 | sort | head -n1

# Run paf_view with invert
echo "paf_invert minimum local alignment identity"
paf_invert -i ${working_dir}/output.paf | paf_view ${working_dir}/*.fa | cut -f9 | sort | head -n1

# Run paf_view with chain
echo "paf_chain minimum local alignment identity"
paf_chain -i ${working_dir}/output.paf | paf_view ${working_dir}/*.fa | cut -f9 | sort | head -n1

# Run paf_view with shatter
echo "paf_shatter minimum local alignment identity (will be low as equal to worst run of matches)"
paf_shatter -i ${working_dir}/output.paf | paf_view ${working_dir}/*.fa | cut -f9 | sort | head -n1

# Run paf_view with tile
echo "paf_tile minimum local alignment identity"
paf_tile -i ${working_dir}/output.paf | paf_view ${working_dir}/*.fa | cut -f9 | sort | head -n1

# Run paf_add_mismatches
echo "adding mismatches"
paf_add_mismatches -i ${working_dir}/output.paf ${working_dir}/*.fa | paf_view ${working_dir}/*.fa | cut -f9 | sort | head -n1

# Run paf_add_mismatches
echo "adding and then remove mismatches"
paf_add_mismatches -i ${working_dir}/output.paf ${working_dir}/*.fa | paf_add_mismatches -a | paf_view ${working_dir}/*.fa | cut -f9 | sort | head -n1

# Run paf_view with trim (identity may be higher as we trim the tails)
echo "paf_trim minimum local alignment identity"
paf_add_mismatches -i ${working_dir}/output.paf ${working_dir}/*.fa | paf_trim | paf_view ${working_dir}/*.fa | cut -f9 | sort | head -n1

# Run paf_view with trim (identity may be higher as we trim the tails)
echo "paf_trim minimum local alignment identity, ignoring mismatches"
paf_trim -r 0.95 -i ${working_dir}/output.paf | paf_view ${working_dir}/*.fa | cut -f9 | sort | head -n1
