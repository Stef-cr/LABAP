# Pipelines automatizados del Laboratorio de Bioinformática Aplicada (LABAP)

## Overview

This branch contains the following tools: 1. An automated batch-processing pipeline for slurm clusters, designed to count k-mers from raw genomic reads with the aim to estimate heterozygosity, total proportion of repetitive DNA and total genome length. 2. An automated SLURM-based genomic pipeline designed to perform high-precision variant calling (SNPs and INDELs) from raw Illumina reads. This workflow encompasses the following stages: Quality Trimming, Reference Genome Alignment, Duplicate Marking, Statistical Base Quality Recalibration (BQSR) and a Functional Impact Annotation.

## Workflow summary

### jellyfish.slurm:
1. Download the version adapted to the script.
2. Change the path in the line "for f in /work/squiros/TFG_Sebastian/Quality/QC_Trimm/*_1_val_1.fq.gz; do" to the path where the "paired-end" read files are located.
3. Extract the name and code of each file and call it "filename" and "code", respectively.
4. Define the path of the second file in which the reverse read (or R2) of each "Paired-end" read will be saved.
5. Define a "common folder" where all the files generated from each reading will be stored separately, differentiated by folders with the following format: "code_jellyfish".
6. Perform the joint k-mer count of the paired (forward and reverse) reads of the sample and store the resulting database (.jf) in its respective "code_jellyfish" folder.
7. Calculate the k-mer frequency histogram from the binary file (.jf) and store the resulting table (.histo) in the directory assigned to the sample.

### SNPs.slurm:


## Reproducibility notes
