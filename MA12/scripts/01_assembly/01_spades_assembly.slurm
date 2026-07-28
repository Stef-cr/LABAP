#!/usr/bin/env bash
#SBATCH --job-name=ma12_spades
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=31-00:00:00
#SBATCH --partition=dribe-long

set -euo pipefail
mkdir -p logs
module load SPAdes/3.15.4

READ1=${READ1:-data/raw/MA12_L1_1_val_1.fq.gz}
READ2=${READ2:-data/raw/MA12_L1_2_val_2.fq.gz}
OUTDIR=${OUTDIR:-results/assembly/Spades_care2}
THREADS=${SLURM_CPUS_PER_TASK:-20}
mkdir -p "$(dirname "$OUTDIR")"

spades.py -1 "$READ1" -2 "$READ2" --careful --cov-cutoff auto \
  -o "$OUTDIR" -k 89,95,97,101,107,117,127 -t "$THREADS"
