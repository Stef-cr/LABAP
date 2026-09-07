# Pipelines automatizados del Laboratorio de Bioinformática Aplicada (LABAP)

## Overview

This branch contains the following tools: 1. An automated batch-processing pipeline for slurm clusters, designed to count k-mers from raw genomic reads with the aim to estimate heterozygosity, total proportion of repetitive DNA and total genome length. 2. An automated SLURM-based genomic pipeline designed to perform high-precision variant calling (SNPs and INDELs) from raw Illumina reads. This workflow encompasses the following stages: Quality Trimming, Reference Genome Alignment, Duplicate Marking, Statistical Base Quality Recalibration (BQSR) and a Functional Impact Annotation.

## Workflow summary

### jellyfish.slurm:


### SNPs.slurm:


## Reproducibility notes
