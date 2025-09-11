#!/bin/bash
#SBATCH --job-name=augustus
#SBATCH --output=augustus.txt
#SBATCH --ntasks=1
#SBATCH --time=700:00
#SBATCH --partition=dribe-long

module load augustus/3.3
module load perl/5.34.0

##MIT License
#Copyright (c) [2025] Stefany Solano-Gonzalez
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
#documentation files (the “Software”), to deal in the Software for educational purposes only. You must give
#author appropriate credit, provide a link to the license and source, and indicate if changes were made.


# load the modules and display the available species

augustus --species=help 

######### Augustus Gene Prediction ######

augustus file.fasta  --strand=both --stopCodonExcludedFromCDS=false --codingseq=on --protein=on --genemodel=complete --gff3=on --species=select_ > file_name.gff3 


## gff3 to CDS using augustus script

# this second script will create two files, the fasta with the predicted proteome and another fasta with the corresponding nucleotides
perl /opt/tools/augustus-3.3/scripts/getAnnoFasta.pl file_name.gff3 --protein=on --codingseq=on
