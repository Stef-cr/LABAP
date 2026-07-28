#!/usr/bin/env bash
#SBATCH --job-name=mummer_dotplot
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=500G
#SBATCH --time=31-00:00:00
#SBATCH --partition=dribe-long
set -euo pipefail
mkdir -p logs results/comparative_genomics/mummer
module load mummer/4.0.0beta2
REFERENCE=${REFERENCE:-data/genomes/P_wereldwijsianum.fasta}
QUERY=${QUERY:-results/assembly/MA12_medusa.fasta}
PREFIX=results/comparative_genomics/mummer/were_ma12
nucmer --prefix="$PREFIX" "$REFERENCE" "$QUERY"
delta-filter -1 "${PREFIX}.delta" > "${PREFIX}.filter"
show-coords -rcl "${PREFIX}.filter" > "${PREFIX}.coords"
show-aligns "${PREFIX}.filter" "$REFERENCE" "$QUERY" > "${PREFIX}.aligns"
mummerplot "${PREFIX}.filter" -R "$REFERENCE" -Q "$QUERY" --filter --layout --prefix "$PREFIX"
