#!/bin/bash
image_path="/scratch/group/jbardlab/colabfold/colabfold_docker:v0.1.sif"
input_dir="/scratch/group/jbardlab/colabfold/inputs"
input_fasta="/scratch/group/jbardlab/colabfold/inputs/VACWR169_IF4E.fasta"
database_dir="/scratch/group/jbardlab/colabfold/colabfold_databases/database1"
output_dir="/scratch/group/jbardlab/colabfold/outputs"


singularity exec --nv \
    -B "${input_dir}:/input_dir" \
    -B "${input_fasta}:/input_fasta" \
    -B "${database_dir}:/database_dir" \
    -B "${output_dir}:/output_dir" \
    "${image_path}" \
    /bin/bash -c \
"mmseqs gpuserver ${database_dir/colabfold_envdb_202108_db} --max-seqs 10000 --db-load-mode 0 --prefilter-mode 1 & PID1=$! &&\
mmseqs gpuserver ${database_dir/uniref30_2302} --max-seqs 10000 --db-load-mode 0 --prefilter-mode 1 & PID2=$! &&\
colabfold_search --mmseqs mmseqs ${input_fasta} ${database_dir} ${output_dir}"
