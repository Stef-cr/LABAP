#!/bin/bash
#SBATCH --job-name=IQ3
#SBATCH --output=iq3.txt
#SBATCH --time=31-00:00:0
#SBATCH --cpus-per-task=10
#SBATCH --partition=dribe-long

. /opt/Modules/3.2.10/init/sh

module load miniconda/busco
module load miniconda/trimal
module load muscle/3.8.31
module load fasttree/2.1.10
module load iqtree3/3.0.1

iqtree3 -s supermatrix_single_copy_orthologs_species.fasta \
  -m MFP \
  -B 1000 \
  -T AUTO \
  --threads-max 32 \
  -alrt 1000 \
  --prefix MA12_single_copy_tree
