#!/bin/bash
#SBATCH --job-name=spades
#SBATCH --output=spades2.txt
#SBATCH --ntasks=1
#SBATCH --time=744:00:00
#SBATCH --partition=dribe-long


module load SPAdes/3.15.4
module load miniconda/3
module load samtools/1.16
module load bwa/0.7.17



#default
#spades.py -1 FASTQC2/MA12_L1_1_val_1.fq.gz -2 FASTQC2/MA12_L1_2_val_2.fq.gz --cov-cutoff auto -o Spades_trimm2 -k 89,95,97,101,107,117,127 -t 20


#caferful mode on
spades.py -1 FASTQC2/MA12_L1_1_val_1.fq.gz -2 FASTQC2/MA12_L1_2_val_2.fq.gz --careful --cov-cutoff auto -o Spades_care2 -k 89,95,97,101,107,117,127 -t 20
