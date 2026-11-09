# BRIEF INTRODUCTION
Este repositorio contiene un flujo de trabajo (pipeline) bioinformático estandarizado diseñado para procesar datos de secuenciación masiva y transformarlos en genomas ensamblados y funcionalmente anotados. El script está estructurado y optimizado para ejecutarse en entornos de computación de alto rendimiento (HPC), específicamente en el supercomputador Kabré, haciendo uso del gestor de tareas SLURM.

​El objetivo de este flujo es tomar lecturas crudas de ADN, limpiar su ruido técnico, ensamblarlas de novo en secuencias continuas y predecir sus estructuras biológicas. El proceso incluye la identificación de genes codificantes, la búsqueda de ARN no codificante (ARNt y ARNr), la clasificación de enzimas CAZymes y la evaluación integral de la completitud genómica y similitud estructural.

# 1. PROCESO DE ENSAMBLAJE DE GENOMA

cat MA15_L1_1.fq.gz MA15_L2_1.fq.gz > MA15_1_merged.fq.gz

cat MA15_L1_2.fq.gz MA15_L2_2.fq.gz > MA15_2_merged.fq.gz

# 2. EJECUTAR TRIMGALORE

#!/bin/bash
#SBATCH --job-name=Trimgalore
#SBATCH --output=Reads_trim
#SBATCH --ntasks=1
#SBATCH --time=164:00:00
#SBATCH --partition=dribe-long        

module load TrimGalore/0.4.3
module load cutadapt/Python3.5-1.9.1
module load fastqc/0.11.9

trim_galore --paired MA9A_merged_1.fq.gz MA9A_merged_2.fq.gz --fastqc -o FASTQC/

MA15_1_merged.fq.gz 
MA15_2_merged.fq.gz 

#con valores para el recorte
#!/bin/bash
#SBATCH --job-name=Trimgalore
#SBATCH --output=Reads_trim
#SBATCH --ntasks=1
#SBATCH --time=164:00:00
#SBATCH --partition=dribe-long

module load TrimGalore/0.4.3
module load cutadapt/Python3.5-1.9.1
module load fastqc/0.11.9

#trim_galore --paired --clip_R1 5 MP4_MERGED_val_1.fq.gz --clip_R2 15 MP4_MERGED_val_2.fq.gz --fastqc -o FASTQC/   #los valores clip pueden quitarse para verlo default

trim_galore --paired --clip_R1 5 MP4_MERGED_val_1.fq.gz --clip_R2 10 MP4_MERGED_val_2.fq.gz --fastqc -o FASTQC/     # y cambiarse por otros valores dependiendo de las graficas de calidad


# 3. USAR SPADES

#!/bin/bash
#SBATCH --job-name=spades
#SBATCH --output=spades
#SBATCH --ntasks=1
#SBATCH --time=164:00:00
#SBATCH --partition=dribe-long

module load SPAdes/3.15.4
module load miniconda/3
module load samtools/1.16
module load bwa/0.7.17

spades.py -1 FASTQC/MA9A_merged_1_val_1.fq.gz -2 FASTQC/MA9A_merged_2_val_2.fq.gz --cov-cutoff auto -o Spades_trimm -k 89,95,97,101,107,117,127 -t 20  #se puede a�adir o quitar el careful mode on 
--careful #para a�adirlo

#MODO CAREFUL 
#!/bin/bash
#SBATCH --job-name=spades
#SBATCH --output=spa
#SBATCH --ntasks=1
#SBATCH --time=164:00:00
#SBATCH --partition=dribe-long

module load SPAdes/3.15.4
module load miniconda/3
module load samtools/1.16
module load bwa/0.7.17

#careful mode on
spades.py -1 MA9A_merged_1_val_1.fq.gz -2 MA9A_merged_2_val_2.fq.gz --careful --cov-cutoff auto -o Spa_care -k 89,95,97,101,107,117,127 -t 20


# 4. USAR MEDUSA

#!/bin/bash
#SBATCH --job-name=medusa
#SBATCH --output=medusa.txt
#SBATCH --ntasks=1
#SBATCH --time=100:00
#SBATCH --partition=kura-long

. /opt/Modules/3.2.10/init/sh

module load miniconda/medusa
module load mummer/4.0.0beta2


java -jar /opt/python/miniconda3/envs/medusa/share/medusa-1.6-2/medusa.jar -f Medusa -i /work/tarias/MA15/FASTQC1/Spades2/contigs.fasta -o MA15_medusaQC -v -scriptPath /work/tarias/medusa_scripts

# 5. EJECUTAR BUSCO

# 6. EJECUTAR AUGUSTUS

# 7. EJECUTAR STRUCTURAL

# REALIZAR COMPROBACIÓN
