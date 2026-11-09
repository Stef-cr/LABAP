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

# 4. USAR MEDUSA

# 5. EJECUTAR BUSCO

# 6. EJECUTAR AUGUSTUS

# 7. EJECUTAR STRUCTURAL

# REALIZAR COMPROBACIÓN
