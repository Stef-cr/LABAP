#!/usr/bin/env bash
#SBATCH --job-name=orthofinder
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --time=31-00:00:00
#SBATCH --partition=dribe-long
set -euo pipefail
mkdir -p logs results/phylogenomics
module load miniconda/3
module load miniconda/orthofinder
PROTEOME_DIR=${PROTEOME_DIR:-data/proteomes}
THREADS=${SLURM_CPUS_PER_TASK:-30}
orthofinder -f "$PROTEOME_DIR" -t "$THREADS" -M msa -T fasttree \
  -o results/phylogenomics/orthofinder
