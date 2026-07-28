#!/bin/bash
#SBATCH --job-name=structural
#SBATCH --output=structural_manuscript.txt
#SBATCH --ntasks=1
#SBATCH --time=168:00:00
#SBATCH --partition=kura-long

. /opt/Modules/3.2.10/init/sh

module load miniconda/3  
module load miniconda/eggnog-mapper-2.1.6 
module load miniconda/barrnap
module load tRNAscan-SE/2.0.5
module load perl/5.34.0

#*MIT License*
#*Copyright (c) [2025] Stefany Solano-González*
#*Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software for educational purposes only. You must give author appropriate credit, provide a link to the license and source, and indicate if changes were made.*

##eggnog-mapper parameters
#needs fasta file with each individual gene fasta sequence
#need to download a DB
#emapper.py -i Augustus/Polished_canu_HortaeMedusa_neurospora3.aa -o eggmapper_out --itype proteins --excel -m diamond --query_cover 50 --evalue 1e-5 --report_orthologs --go_evidence all --cpu 10

##barrnap v.0.9 parameters
barrnap --kingdom euk --threads 10 --incseq --outseq rRNA_MP4hits.fasta Spades/scaffolds.fasta > MP4_rRNA.gff3

##tRNAscan parameters
#tRNAscan-SE -E -I -o MP4_tRNAscan.out --stats MP4_tRNAscan_stats.txt -b MP4_tRNAscan.bed Spades/scaffolds.fasta

#To cound Cazymes output from dbSCAN server
#awk '$5 != "N"{print $1,$5}' CAZyme.txt | sort -u
#awk '$6 ~ /^Y.*/ {print $0}' CAZyme.txt | wc -l

