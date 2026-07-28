#!/usr/bin/env bash
#SBATCH --job-name=eggnog_annotation
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --time=7-00:00:00
#SBATCH --partition=kura-long
set -euo pipefail
mkdir -p logs results/annotation/eggnog
module load miniconda/3
module load miniconda/eggnog-mapper-2.1.6
PROTEINS=${PROTEINS:-data/proteins/MA12.faa}
THREADS=${SLURM_CPUS_PER_TASK:-10}
emapper.py -i "$PROTEINS" -o MA12_eggnog --output_dir results/annotation/eggnog \
  --itype proteins --excel -m diamond --query_cover 50 --evalue 1e-5 \
  --report_orthologs --go_evidence all --cpu "$THREADS"
