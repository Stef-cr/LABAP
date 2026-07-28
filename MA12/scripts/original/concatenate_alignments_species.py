#!/usr/bin/env python3

from pathlib import Path
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
import csv
import re
import sys

alignment_dir = Path("Single_Copy_Alignments")
orthogroups_tsv = Path("Orthogroups/Orthogroups.tsv")
output_file = "supermatrix_single_copy_orthologs_species.fasta"

if not alignment_dir.exists():
    sys.exit("ERROR: Single_Copy_Alignments not found")

if not orthogroups_tsv.exists():
    sys.exit("ERROR: Orthogroups/Orthogroups.tsv not found")

# Read Orthogroups.tsv by OG
og_to_species_genes = {}

with open(orthogroups_tsv, newline="") as f:
    reader = csv.DictReader(f, delimiter="\t")
    species_names = reader.fieldnames[1:]

    for row in reader:
        og = row["Orthogroup"]
        og_to_species_genes[og] = {}

        for species in species_names:
            genes_raw = row[species].strip()
            genes = []

            if genes_raw:
                genes = [g.strip() for g in re.split(r",\s*", genes_raw) if g.strip()]

            og_to_species_genes[og][species] = genes

# Store matrix by species
supermatrix = {species: "" for species in species_names}

fasta_files = sorted([
    f for f in alignment_dir.iterdir()
    if f.suffix.lower() in [".fa", ".faa", ".fasta", ".fas", ".aln"]
])

used_ogs = 0
skipped_ogs = 0

for fasta_file in fasta_files:
    og = fasta_file.stem

    if og not in og_to_species_genes:
        print(f"WARNING: {og} not found in Orthogroups.tsv, skipped")
        skipped_ogs += 1
        continue

    records = list(SeqIO.parse(fasta_file, "fasta"))

    if not records:
        print(f"WARNING: empty alignment skipped: {fasta_file.name}")
        skipped_ogs += 1
        continue

    aln_length = len(records[0].seq)

    # Map gene ID -> aligned sequence in this OG
    gene_to_seq = {}
    for record in records:
        gene_to_seq[record.id] = str(record.seq)

    # Add one sequence per species, in Orthogroups.tsv order
    for species in species_names:
        genes = og_to_species_genes[og][species]

        found = None
        for gene in genes:
            if gene in gene_to_seq:
                found = gene_to_seq[gene]
                break

        if found is not None:
            supermatrix[species] += found
        else:
            supermatrix[species] += "-" * aln_length
            print(f"WARNING: missing {species} in {og}; added gaps")

    used_ogs += 1

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

print(f"Alignments used: {used_ogs}")
print(f"Alignments skipped: {skipped_ogs}")
print(f"Species: {len(records_out)}")
print(f"Final alignment length: {len(records_out[0].seq)}")
print(f"Output file: {output_file}")
