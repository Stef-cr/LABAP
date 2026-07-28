#!/usr/bin/env bash
#SBATCH --job-name=assembly_stats
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --time=12:00:00
#SBATCH --partition=dribe-long
set -euo pipefail
mkdir -p logs results/quality
module load jdk/13.0.2
module load bbmap/37.36
GENOME=${GENOME:-results/assembly/MA12_medusa.fasta}
stats.sh in="$GENOME" > results/quality/MA12_assembly_stats.txt
