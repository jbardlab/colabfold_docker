#!/bin/bash
image_path="/scratch/group/jbardlab/colabfold/colabfold_docker:v0.1.sif"
database_dir="/scratch/group/jbardlab/colabfold/colabfold_databases/colabfold_envdb_202108/colabfold_envdb_202108_con"
prefix1="/database_dir/colabfold_envdb_202108"
prefix2="/database_dir/colabfold_envdb_202108_db"

singularity exec --nv \
    -B "${database_dir}:/database_dir" \
    "${image_path}"  \
    /bin/bash -c "mmseqs createindex ${prefix2} ${database_dir} --remove-tmp-files 1 --split 1 --index-subset 2"
