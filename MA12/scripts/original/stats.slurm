#!/bin/bash
#SBATCH --job-name=BBMap
#SBATCH --output=bbmap.txt
#SBATCH --ntasks=1
#SBATCH --time=700:00
#SBATCH --partition=dribe-long

. /opt/Modules/3.2.10/init/sh

module load jdk/13.0.2
module load bbmap/37.36

stats.sh in=/work/narias/LABAP/Results_MA12/MA12_medusa.fasta
