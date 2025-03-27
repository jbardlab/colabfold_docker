#!/bin/bash

image_path="/scratch/group/jbardlab/colabfold/colabfold_docker:v0.1.sif"
outputs="/scratch/group/jbardlab/colabfold/colabfold_databases/outputs"


singularity exec --nv \
    -B "${TMPDIR}:/tmp/matplotlib" \
    -B "${output}:/input.fasta" \
    --env "MPLCONFIGDIR=/tmp/matplotlib" \
    "${image_path}" \
    /bin/bash -c \
"colabfold_batch /outputs predictions"
