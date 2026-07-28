#!/bin/bash
#SBATCH --job-name=structural
#SBATCH --output=structural_manuscript.txt
#SBATCH --ntasks=1
#SBATCH --time=168:00:00
#SBATCH --partition=kura-long

. /opt/Modules/3.2.10/init/sh

module load miniconda/3  
module load miniconda/eggnog-mapper-2.1.6

##eggnog-mapper parameters
#needs fasta file with each individual gene fasta sequence
#need to download a DB
emapper.py -i pwerel.faa -o egg_pwere --itype proteins --excel -m diamond --query_cover 50 --evalue 1e-5 --report_orthologs --go_evidence all --cpu 10
