#!/bin/bash
#SBATCH --job-name=BUSCO
#SBATCH --output=busco_were.txt
#SBATCH --ntasks=1
#SBATCH --time=700:00
#SBATCH --partition=kura-long

. /opt/Modules/3.2.10/init/sh

module load miniconda/busco

#busco -f -m genome -i p_werel.fasta -l fungi_odb10 -c 8 -o BuscoFungi_were
#busco -f -m genome -i p_werel.fasta -l ascomycota_odb10 -c 8 -o BuscoASCO_were
busco -f -m genome -i p_werel.fasta -l hypocreales_odb10 -c 8 -o BuscoHYPO_were 

