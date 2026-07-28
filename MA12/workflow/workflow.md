# Reproducible workflow

## 1. Sampling, isolation and sequencing

Mangrove mud was collected in Manuel Antonio National Park, Costa Rica. Fungal isolates were recovered on PDA and YPG media, purified by successive subculturing and preserved in the LABAP collection. Isolate MA12 was cultured in PDB for 7 days at 30 °C and 120 rpm. Genomic DNA was extracted using the FastDNA Spin Kit for Soil. A single Illumina-compatible library was sequenced on an Illumina NovaSeq X Plus platform using 2 × 150 bp paired-end reads.

These wet-laboratory procedures are documented for provenance but are not executed by this repository.

## 2. Read preprocessing

**Software:** Trim Galore v0.4.3

Parameters:

- paired-end mode;
- Phred cutoff: Q20;
- minimum retained read length: 20 bp;
- hard clipping: 10 bp from Read 1;
- hard clipping: 5 bp from Read 2.

Representative command:

```bash
trim_galore   --paired   --quality 20   --length 20   --clip_R1 10   --clip_R2 5   reads_R1.fastq.gz reads_R2.fastq.gz
```

Post-trimming read quality was assessed with FastQC v0.11.9.

## 3. De novo assembly

**Software:** SPAdes v3.11.0

The filtered reads were assembled using k-mer lengths 89, 95, 97, 101, 107, 117 and 127.

```bash
spades.py   -1 reads_R1_val_1.fq.gz   -2 reads_R2_val_2.fq.gz   -k 89,95,97,101,107,117,127   -o spades_output
```

## 4. Reference-guided scaffolding

**Software:** MeDuSa v1.6

The initial SPAdes assembly was scaffolded using *Parasarocladium wereldwijsianum* GCA_036250105.1 as the reference genome. This taxon had initially been selected based on ITS similarity and was subsequently evaluated using genome-wide phylogenomics and structural comparisons.

## 5. Assembly statistics and completeness

Assembly statistics, including N50, L50 and GC content, were calculated using BBMap v37.36.

Genome completeness was assessed with BUSCO v5.4.3 using:

- `fungi_odb10`;
- `ascomycota_odb10`;
- `hypocreales_odb10`.

## 6. Structural annotation

Structural gene annotation and protein prediction were performed using AUGUSTUS v3.3, trained with the *Fusarium graminearum* species model.

## 7. Orthology inference

**Software:** OrthoFinder v2.5.2

Predicted proteomes from MA12 and representative Sordariomycetes taxa were analyzed to identify orthogroups and single-copy orthologs.

The repository includes the original OrthoFinder SLURM script and downstream scripts for alignment recovery and concatenation.

## 8. Single-copy ortholog concatenation

Aligned single-copy ortholog sequences were concatenated by species using:

```bash
python scripts/concatenate_alignments_species.py
```

Expected output:

```text
supermatrix_single_copy_orthologs_species.fasta
```

Missing sequences are represented by gap characters so that all taxa retain the same concatenated alignment length.

## 9. Phylogenomic inference

**Software:** IQ-TREE v3.0.1

The maximum-likelihood tree was inferred from the concatenated amino-acid alignment.

```bash
iqtree3   -s supermatrix_single_copy_orthologs_species.fasta   -m MFP   -B 1000   -alrt 1000
```

ModelFinder selected `Q.INSECT+F+I+R4` according to the Bayesian Information Criterion. Branch support was evaluated with 1,000 ultrafast bootstrap and 1,000 SH-aLRT replicates.

The final tree was visualized in R using `ggtree` and `treeio`.

## 10. Genomic delimitation

Pairwise genomic average nucleotide identity between MA12 and *P. wereldwijsianum* was calculated with gANI v1.0.0 using default parameters.

Digital DNA-DNA hybridization was estimated through the GGDC 3.0 web server using Formula 2.

Species-boundary thresholds:

- ANI: 95%;
- dDDH: 70%.

## 11. Whole-genome alignment and synteny

Whole-genome alignments and synteny analyses were performed using MUMmer v4.0.0beta1. The resulting coordinate data were visualized as a genome dotplot in R.

## 12. Functional annotation and comparative genomics

Predicted proteins were functionally annotated with EggNOG-mapper v2.1.6.

CAZyme-related records were extracted from the EggNOG-mapper annotations and compared among genomes.

OrthoFinder v2.5.2 outputs were also used for comparative orthology analyses.

## 13. Biosynthetic gene clusters

Biosynthetic gene clusters were predicted using the antiSMASH v8.0 web server from annotated genome files. Because this analysis was performed online, no local execution script is included. The input requirements, reporting recommendations and reproducibility metadata are documented in `docs/antismash_web.md`.

## 14. Data visualization

All downstream figures were generated in R v4.5.1 within RStudio. Repository scripts include:

- phylogenomic tree visualization;
- whole-genome dotplot generation.

## 15. Execution order

The computational stages should be executed in this order:

```text
Trim Galore
  ↓
FastQC
  ↓
SPAdes
  ↓
MeDuSa
  ↓
BBMap + BUSCO
  ↓
AUGUSTUS
  ├── EggNOG-mapper → CAZyme comparison
  ├── antiSMASH web → BGC comparison
  └── OrthoFinder
        ↓
      single-copy ortholog alignments
        ↓
      concatenated supermatrix
        ↓
      IQ-TREE phylogeny

MA12 assembly + P. wereldwijsianum assembly
  ├── gANI
  ├── GGDC 3.0 dDDH
  └── MUMmer synteny → R dotplot
```
