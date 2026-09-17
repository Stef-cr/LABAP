#!/bin/bash
#SBATCH --job-name=Trimgalore
#SBATCH --output=Reads_trim
#SBATCH --ntasks=1
#SBATCH --time=164:00:00
#SBATCH --partition=dribe-long


module load TrimGalore/0.4.3
module load cutadapt/Python3.5-1.9.1
module load fastqc/0.11.9

trim_galore --paired MA1/MA1_L1_1.fq.gz MA1/MA1_L1_2.fq.gz --fastqc -o QC/
trim_galore --paired MA1/MA1_L2_1.fq.gz MA1/MA1_L2_2.fq.gz --fastqc -o QC/
trim_galore --paired MA1/MA1_L3_1.fq.gz MA1/MA1_L3_2.fq.gz --fastqc -o QC/
