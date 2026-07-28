#!/usr/bin/env bash
#SBATCH --job-name=ma12_busco
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=7-00:00:00
#SBATCH --partition=kura-long
set -euo pipefail
mkdir -p logs results/quality/busco
module load miniconda/busco
GENOME=${GENOME:-results/assembly/MA12_medusa.fasta}
THREADS=${SLURM_CPUS_PER_TASK:-8}
for LINEAGE in fungi_odb10 ascomycota_odb10 hypocreales_odb10; do
  busco -f -m genome -i "$GENOME" -l "$LINEAGE" -c "$THREADS" \
    -o "MA12_${LINEAGE}" --out_path results/quality/busco
done
