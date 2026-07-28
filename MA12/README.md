# Genome assembly, phylogenomics and comparative genomics of *Parasarocladium* sp. MA12

## Overview

This repository contains the scripts, parameters and documentation used for the de novo genome assembly, quality assessment, phylogenomic placement, genomic delimitation, functional annotation and comparative genomic analyses of *Parasarocladium* sp. MA12.

The isolate was recovered from mangrove mud collected in Manuel Antonio National Park, Puntarenas, Costa Rica. The workflow combines Illumina short-read assembly, reference-guided scaffolding, structural and functional annotation, genome-wide phylogenomics, taxonomic delimitation and comparative genomic analyses.

## Workflow summary

1. Sample collection, fungal isolation and DNA extraction.
2. Illumina NovaSeq X Plus paired-end sequencing (2 × 150 bp).
3. Adapter and quality trimming with Trim Galore v0.4.3.
4. Read quality assessment with FastQC v0.11.9.
5. De novo genome assembly with SPAdes v3.11.0.
6. Reference-guided scaffolding with MeDuSa v1.6 using *P. wereldwijsianum* GCA_036250105.1.
7. Assembly statistics with BBMap v37.36.
8. Genome completeness assessment with BUSCO v5.4.3.
9. Structural gene prediction with AUGUSTUS v3.3.
10. Orthology inference with OrthoFinder v2.5.2.
11. Single-copy ortholog concatenation and phylogenomic inference with IQ-TREE v3.0.1.
12. Genomic delimitation using gANI v1.0.0 and GGDC 3.0.
13. Whole-genome alignment and synteny analysis with MUMmer v4.0.0beta1.
14. Functional annotation with EggNOG-mapper v2.1.6.
15. CAZyme comparison and biosynthetic gene-cluster prediction with antiSMASH v8.0.
16. Figure generation in R v4.5.1.

A detailed step-by-step description is available in [`workflow/workflow.md`](workflow/workflow.md).

## Repository structure

```text
.
├── README.md
├── LICENSE
├── CITATION.cff
├── CHANGELOG.md
├── CONTRIBUTING.md
├── config/
│   └── paths.example.sh
├── docs/
│   ├── data_availability.md
│   ├── methods_mapping.md
│   ├── software_versions.md
│   └── antismash_web.md
├── workflow/
│   ├── workflow.md
│   └── workflow.mmd
└── scripts/
    ├── original/
    └── ...
```

## Reproducibility notes

The scripts in `scripts/original/` preserve the commands used during the analysis. Public-facing scripts should be configured with local file paths and cluster-specific SLURM settings before execution. Large raw reads, genome assemblies and third-party database files are not distributed through this repository and should be obtained from the accession numbers reported in the associated article.

The study represents a de novo structural genome assembly from one isolate; therefore, no biological replicates were generated.

## External web analyses

Two analyses were performed using web services:

- digital DNA-DNA hybridization using GGDC 3.0, Formula 2;
- biosynthetic gene-cluster prediction using antiSMASH v8.0.

See [`docs/antismash_web.md`](docs/antismash_web.md) and [`docs/methods_mapping.md`](docs/methods_mapping.md).

## Citation

Please cite the associated article and the archived repository release. After depositing the GitHub release in Zenodo, replace the placeholders in `CITATION.cff` and `docs/data_availability.md` with the final DOI and accession numbers.

## License

Code and workflow documentation are distributed under the MIT License. Third-party software and databases retain their original licenses.
