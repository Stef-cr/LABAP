# Pipelines automatizados del Laboratorio de Bioinformática Aplicada (LABAP)
# Automated pipelines of the Laboratorio de Bioinformática Aplicada (LABAP)

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

### SNPs_cafe.slurm:
1. Environment and Paths Setup: Specify the sample identifier (SAMPLE_ID), input read paths (R1, R2), reference genome (REF), and executable paths for GATK and Picard (GATK_JAR, PICARD_JAR).
2. Directory Initialization: Create the working directories QC/ and Esamples/ to organize quality reports, alignments, and variant outputs.
3. Reference Genome Indexing: Generate the alignment and sequence indices for the reference FASTA using bwa index, samtools faidx, and Picard's CreateSequenceDictionary.
4. Quality Trimming and Adapter Removal: Process raw paired-end reads using TrimGalore (--paired, clipping primers and low-quality ends) and run automated FastQC reports inside QC/.
5. Reference Genome Alignment: Align the trimmed paired reads against the reference using bwa mem, assigning read group metadata (@RG), and output the alignment file (.sam) to Esamples/.
6. Duplicate Marking and Sorting: Identify and flag PCR/optical duplicates and coordinate-sort the alignment using GATK's MarkDuplicatesSpark, producing a deduplicated BAM file (.bam) and duplication metrics (_dedup_metrics.txt).
7. Alignment Quality Assessment: Compute mapping summaries, insert size distributions, and base coverage depth across the genome using Picard (AlignmentSummaryMetrics, CollectInsertSizeMetrics) and samtools depth.
8. Initial Variant Calling: Perform raw variant discovery across the deduplicated BAM using GATK's HaplotypeCaller, generating an initial raw VCF file (_raw_variants.vcf).
9. Raw Variant Separation: Split raw calls into distinct files for single nucleotide polymorphisms (_raw_snps.vcf) and insertions/deletions (_raw_indels.vcf) using GATK's SelectVariants.
10. Hard Filtering of Raw Variants: Apply quality thresholds via GATK's VariantFiltration (filtering by QD, FS, MQ, SOR, MQRankSum, and ReadPosRankSum) to tag low-confidence calls.
11. Extraction of High-Confidence Sites: Exclude filtered low-confidence calls using GATK's SelectVariants --exclude-filtered to generate trusted training sets of SNPs and INDELs for recalibration.
12. Base Quality Score Recalibration (BQSR) Modeling: Build a systematic error model using GATK's BaseRecalibrator based on the trusted variant sites, generating a recalibration table (_recal_data.table).
13. Application of Recalibration: Adjust base quality scores in the deduplicated alignment using GATK's ApplyBQSR, producing a recalibrated BAM file (_recal_reads.bam).
14. Recalibrated Variant Calling: Re-run GATK's HaplotypeCaller on the recalibrated BAM file to discover high-precision variants (_raw_variants_recal.vcf).
15. Recalibrated Variant Separation and Hard Filtering: Split the recalibrated variants into SNPs and INDELs and apply the hard filtration criteria again to produce the final filtered variant sets (FINAL_SNPS and FINAL_INDELS).
16. Functional Impact Annotation: Annotate the biological and functional impact of the final filtered SNPs using snpEff, generating an HTML summary report and an annotated VCF file (_ann.vcf).


## Reproducibility notes

## MIT License
#Copyright (c) [2025] Stefany Solano-Gonzalez
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
#documentation files (the “Software”), to deal in the Software for educational purposes only. You must give
#author appropriate credit, provide a link to the license and source, and indicate if changes were made.
