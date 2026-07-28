#!/bin/bash
#SBATCH --job-name=BUSCO
#SBATCH --output=busco.txt
#SBATCH --ntasks=1
#SBATCH --time=700:00
#SBATCH --partition=kura-long

. /opt/Modules/3.2.10/init/sh

module load miniconda/busco

busco -f -m genome -i Spades_care2/contigs.fasta -l fungi_odb10 -c 8 -o BuscoFungi
busco -f -m genome -i Spades_care2/contigs.fasta -l ascomycota_odb10 -c 8 -o BuscoASCO
busco -f -m genome -i Spades_care2/contigs.fasta -l hypocreales_odb10 -c 8 -o BuscoHYPO 

