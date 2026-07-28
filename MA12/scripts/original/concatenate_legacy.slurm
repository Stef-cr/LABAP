#!/usr/bin/env bash
#SBATCH --job-name=concat_msa
#SBATCH --output=concat_msa_species_%j.out
#SBATCH --error=concat_msa_species_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=04:00:00
#SBATCH --partition=dribe-long


echo "Starting single-copy ortholog concatenation..."
date

module load mamba/busco-5.8.3

SCO_DIR="Single_Copy_Orthologue_Sequences"
MSA_DIR="MultipleSequenceAlignments"
OUT_DIR="Single_Copy_Alignments_Renamed"
OG_LIST="single_copy_ogs.txt"
SUPERMATRIX="supermatrix_single_copy_orthologs_species.fasta"
CONCAT_SCRIPT="concatenate_msa_species.py"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

ls "$SCO_DIR" | sed 's/\..*$//' | sort > "$OG_LIST"

cat > "$CONCAT_SCRIPT" << 'EOF'
#!/usr/bin/env python3

from pathlib import Path
from collections import defaultdict
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
import sys

msa_dir = Path("MultipleSequenceAlignments")
og_list_file = Path("single_copy_ogs.txt")
out_dir = Path("Single_Copy_Alignments_Renamed")
output_file = Path("supermatrix_single_copy_orthologs_species.fasta")

species_names = [
    "MA12",
    "fusarium_acutatum",
    "hypomyces_rosellus",
    "neocosmospora_mangrovei",
    "purpureocillium_lilacinum",
    "pwerel",
    "trichoderma_harziamum"
]

def get_species(record_id):
    for species in species_names:
        if record_id == species or record_id.startswith(species + "_"):
            return species
    return None

if not msa_dir.exists():
    sys.exit("ERROR: no existe MultipleSequenceAlignments")

out_dir.mkdir(exist_ok=True)

with open(og_list_file) as f:
    single_copy_ogs = [line.strip() for line in f if line.strip()]

supermatrix = {species: "" for species in species_names}

ogs_used = 0
ogs_missing = 0
unmapped = 0

for og in single_copy_ogs:
    msa_files = sorted(list(msa_dir.glob(og + ".*")))

    if not msa_files:
        print("WARNING: no se encontró alineamiento para " + og)
        ogs_missing += 1
        continue

    msa_file = msa_files[0]
    records = list(SeqIO.parse(msa_file, "fasta"))

    if not records:
        print("WARNING: alineamiento vacío: " + msa_file.name)
        continue

    aln_len = len(records[0].seq)
    seq_by_species = {}
    renamed_records = []

    for record in records:
        species = get_species(record.id)

        if species is None:
            print("WARNING: no se pudo reconocer especie en " + record.id + " de " + og)
            unmapped += 1
            continue

        seq = str(record.seq)
        seq_by_species[species] = seq

        renamed_records.append(
            SeqRecord(
                Seq(seq),
                id=species,
                name=species,
                description=""
            )
        )

    if not seq_by_species:
        print("WARNING: ningún registro válido en " + og)
        continue

    SeqIO.write(renamed_records, out_dir / msa_file.name, "fasta")

    for species in species_names:
        if species in seq_by_species:
            supermatrix[species] += seq_by_species[species]
        else:
            supermatrix[species] += "-" * aln_len
            print("WARNING: falta " + species + " en " + og + "; se agregan gaps")

    ogs_used += 1

records_out = [
    SeqRecord(
        Seq(supermatrix[species]),
        id=species,
        name=species,
        description=""
    )
    for species in species_names
]

SeqIO.write(records_out, output_file, "fasta")

print("OGs usados: " + str(ogs_used))
print("OGs sin alineamiento: " + str(ogs_missing))
print("Secuencias no reconocidas: " + str(unmapped))
print("Especies/genomas: " + str(len(records_out)))
print("Supermatriz: " + str(output_file))

for species in species_names:
    print(species + "\t" + str(len(supermatrix[species])))
EOF

python "$CONCAT_SCRIPT"

echo "Final taxa:"
grep "^>" "$SUPERMATRIX"

echo "Sequence lengths:"
awk '/^>/ {if (seq!="") print name, length(seq); name=$0; seq=""; next} {seq=seq$0} END {print name, length(seq)}' "$SUPERMATRIX"

echo "Finished concatenation."
date
