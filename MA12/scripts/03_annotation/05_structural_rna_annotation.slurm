#!/usr/bin/env bash
#SBATCH --job-name=structural_rna
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --time=7-00:00:00
#SBATCH --partition=kura-long
set -euo pipefail
mkdir -p logs results/annotation/structural
module load miniconda/3
module load miniconda/barrnap
module load tRNAscan-SE/2.0.5
GENOME=${GENOME:-results/assembly/MA12_medusa.fasta}
THREADS=${SLURM_CPUS_PER_TASK:-10}
barrnap --kingdom euk --threads "$THREADS" --incseq \
  --outseq results/annotation/structural/MA12_rRNA.fasta "$GENOME" \
  > results/annotation/structural/MA12_rRNA.gff3
tRNAscan-SE -E -I -o results/annotation/structural/MA12_tRNAscan.out \
  --stats results/annotation/structural/MA12_tRNAscan_stats.txt \
  -b results/annotation/structural/MA12_tRNAscan.bed "$GENOME"
