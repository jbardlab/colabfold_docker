#!/bin/bash
image_path="/scratch/group/jbardlab/colabfold/colabfold_docker:v0.1.sif"
input_dir="/scratch/group/jbardlab/colabfold/colabfold_databases/uniref30_2302_s2/uniref30_2302_con"
prefix1="/input_dir/uniref30_2302"
prefix2="/input_dir/uniref30_2302_db"

singularity exec --nv \
    -B "${input_dir}:/input_dir" \
    "${image_path}"  \
    /bin/bash -c "mmseqs tsv2exprofiledb ${prefix1} ${prefix2} --gpu 1"
