#!/bin/bash
#SBATCH --job-name=Trimgalore
#SBATCH --output=Reads_trim
#SBATCH --ntasks=1
#SBATCH --time=164:00:00
#SBATCH --partition=dribe-long

module load TrimGalore/0.4.3
module load cutadapt/Python3.5-1.9.1
module load fastqc/0.11.9

#trim_galore --paired --clip_R1 5 MP4_MERGED_val_1.fq.gz --clip_R2 15 MP4_MERGED_val_2.fq.gz --fastqc -o FASTQC/

trim_galore --paired --clip_R1 5 MP4_MERGED_val_1.fq.gz --clip_R2 10 MP4_MERGED_val_2.fq.gz --fastqc -o FASTQC/
