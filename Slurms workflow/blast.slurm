#!/bin/bash
#SBATCH --job-name=blast
#SBATCH --output=blastDOC.txt
#SBATCH --ntasks=1
#SBATCH --time=70:00:00
#SBATCH --partition=dribe

module load blast+/2.11.0

blastp -query Cdiff_CD161.faa -task blastp -db toxins -out Cdiff_cd161_tox -evalue 1e-5 -outfmt 6 -num_threads 36
