#!/bin/bash

image_path="/scratch/group/jbardlab/colabfold/colabfold_docker:v0.1.sif"
input_fasta="/scratch/group/jbardlab/colabfold/inputs/VACWR169_IF4E.fasta"
database_dir="/scratch/group/jbardlab/colabfold/colabfold_databases/database2"

singularity exec --nv \
    -B "${TMPDIR}:/tmp/matplotlib" \
    -B "${input_fasta}:/input.fasta" \
    -B "${database_dir}:/database_dir" \
    --env "MPLCONFIGDIR=/tmp/matplotlib" \
    "${image_path}" \
    /bin/bash -c \
"mmseqs gpuserver /database_dir/uniref30_2302_db --max-seqs 10000 --db-load-mode 0 --prefilter-mode 1 &
PID1=$! && \
mmseqs gpuserver /database_dir/colabfold_envdb_202108_db --max-seqs 10000 --db-load-mode 0 --prefilter-mode 1 &
PID2=$! && \
colabfold_search --mmseqs mmseqs --gpu 1 --gpu-server 1 /input.fasta /database_dir outputs && \
wait $PID1 $PID2"
