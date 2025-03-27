#!/bin/bash
#SBATCH --job-name=setup_database
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1          # max 32 nodes for partition gpu
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=180G
#SBATCH --gres=gpu:a100:1
#SBATCH --output=stdout.%x.%j
#SBATCH --error=stderr.%x.%j
#SBATCH --mail-type=ALL
#SBATCH --mail-user=pangkx@tamu.edu

# set up ENVIRONMENT
export SINGULARITY_CACHEDIR=$TMPDIR/.singularity
module load WebProxy
bash run_setup_databases.sh
