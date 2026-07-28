#!/usr/bin/env bash
#SBATCH --job-name=iqtree3
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --cpus-per-task=32
#SBATCH --time=31-00:00:00
#SBATCH --partition=dribe-long
set -euo pipefail
mkdir -p logs results/phylogenomics/iqtree
module load iqtree3/3.0.1
ALIGNMENT=${ALIGNMENT:-supermatrix_single_copy_orthologs_species.fasta}
iqtree3 -s "$ALIGNMENT" -m MFP -B 1000 -alrt 1000 -T AUTO \
  --threads-max "${SLURM_CPUS_PER_TASK:-32}" \
  --prefix results/phylogenomics/iqtree/MA12_single_copy_tree
