#!/usr/bin/env bash
#SBATCH --job-name=MA12_ANI
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --time=31-00:00:00
#SBATCH --partition=dribe-long
set -euo pipefail
mkdir -p logs results/comparative_genomics/ani
module load ANIcalculator/1.0.0
REFERENCE=${REFERENCE:-data/genomes/P_wereldwijsianum.fasta}
QUERY=${QUERY:-results/assembly/MA12_medusa.fasta}
ANIcalculator -genome1fna "$REFERENCE" -genome2fna "$QUERY" \
  -outfile results/comparative_genomics/ani/MA12_vs_P_wereldwijsianum.tsv
