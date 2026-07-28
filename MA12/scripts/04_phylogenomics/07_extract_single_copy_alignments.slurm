#!/usr/bin/env bash
#SBATCH --job-name=extract_sco
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --nodes=1
#SBATCH --time=1-00:00:00
#SBATCH --partition=kura-all
set -euo pipefail
mkdir -p logs
MSA_DIR=${MSA_DIR:-MultipleSequenceAlignments}
SCO_LIST=${SCO_LIST:-single_copy_ogs.txt}
OUT_DIR=${OUT_DIR:-Single_Copy_Alignments}
mkdir -p "$OUT_DIR"
while read -r OG; do
  [[ -z "$OG" ]] && continue
  file=$(find "$MSA_DIR" -maxdepth 1 -type f -name "${OG}.*" | head -n 1)
  if [[ -n "$file" ]]; then cp "$file" "$OUT_DIR/"; else echo "WARNING: alignment not found for $OG" >&2; fi
done < "$SCO_LIST"
