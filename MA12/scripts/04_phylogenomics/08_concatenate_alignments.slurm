#!/usr/bin/env bash
#SBATCH --job-name=concat_sco
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=04:00:00
#SBATCH --partition=dribe-long
set -euo pipefail
mkdir -p logs
module load mamba/busco-5.8.3
python scripts/04_phylogenomics/concatenate_alignments_species.py
