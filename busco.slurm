#!/bin/bash
#SBATCH --job-name=BUSCO
#SBATCH --output=busco.txt
#SBATCH --ntasks=1
#SBATCH --time=700:00
#SBATCH --partition=kura-long

. /opt/Modules/3.2.10/init/sh

module load miniconda/busco

# To revise the available lineages within the instalation
busco --lineage-dataset 

busco -f -m genome -i file.fasta -l fungi_odb10 -c 8 -o file_name

