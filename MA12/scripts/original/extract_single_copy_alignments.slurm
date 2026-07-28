#!/usr/bin/env bash
#SBATCH --job-name=concatenados
#SBATCH --partition=kura-all
#SBATCH --nodes=1
#SBATCH --time=1-00:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

. /opt/Modules/3.2.10/init/sh

module load mamba/busco-5.8.3

MSA_DIR="MultipleSequenceAlignments"
OUT_DIR="Single_Copy_Alignments"


mkdir -p "$OUT_DIR"

while read OG; do
    file=$(find "$MSA_DIR" -maxdepth 1 -type f -name "${OG}.*" | head -n 1)

    if [ -n "$file" ]; then
        cp "$file" "$OUT_DIR/"
    else
        echo "WARNING: alignment not found for $OG"
    fi
done < single_copy_ogs.txt
