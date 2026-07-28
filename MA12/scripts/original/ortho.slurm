#!/bin/bash
#SBATCH --job-name=orthofinder
#SBATCH --output=orthoarbol2.txt
#SBATCH --ntasks=4
#SBATCH --time=744:00:00
#SBATCH --partition=dribe-long


module load miniconda/3
module load miniconda/orthofinder


orthofinder -b /work/narias/LABAP/parasaro/OrthoFinder/Results_May29 -t 30 -M msa -T fasttree 
