#!/bin/bash
#SBATCH --job-name=ANI
#SBATCH --output=ANI_MA12
#SBATCH --ntasks=1
#SBATCH --time=740:00:00
#SBATCH --partition=dribe-long

module load ANIcalculator/1.0.0

/opt/bioinf/ANIcalculator/ANIcalculator -genome1fna p_werel.fasta -genome2fna Results_MA12/MA12_medusa.fasta -outfile MA12_ANI


#Results are shown in tab-delimited format with following headers:
#   Genome1 <name of FNA file of genome1>
#   Genome2 <name of FNA file of genome2>
#   ANI(1->2) <Average nucleotide idenitity of the first genome to the second>
#   ANI(2->1) <Average nucleotide idenitity of the second genome to the first>
#   AF(1->2) <Alignment Fraction of the first genome to the second>
#   AF(2->1) <Alignment Fraction of the second genome to the first> 
