#!/bin/bash
#SBATCH --job-name=Jellyfish
#SBATCH --output=Jellyfish.txt
#SBATCH --ntasks=1
#SBATCH --time=700:00
#SBATCH --partition=dribe-long

module load jellyfish/2.3.0

### Individual ###

#jellyfish count -C -m 21 -s 1000000000 -t 10 file.fastq -o reads.jf

#Export the histogram text file

#jellyfish histo -t 10 reads.jf > reads.histo

###### Bucle Jellyfish por Muestra (Paired-End) ####

for f in /work/squiros/TFG_Sebastian/Quality/QC_Trimm/*_1_val_1.fq.gz; do

    # Extraer el nombre del archivo (ej: 819597_1_val_1.fq.gz)
    filename=$(basename "$f")
    
    # Extraer el código eliminando el sufijo _1_val_1.fq.gz (ej: 819597)
    code=${filename%_1_val_1.fq.gz}
    
    # Definir la ruta del archivo mate (R2)
    f2="/work/squiros/TFG_Sebastian/Quality/QC_Trimm/${code}_2_val_2.fq.gz"
    
    # Carpeta de salida EXCLUSIVA para esta muestra
    outdir="/work/squiros/TFG_Sebastian/Jellyfish/${code}_jellyfish"
    mkdir -p "$outdir"

    echo "================= Procesando Jellyfish para muestra $code ================="

    # 1. Correr jellyfish count guardando en su respectiva carpeta
    jellyfish count -C -m 21 -s 1000000000 -t 10 <(gzip -dc "$f" "$f2") -o "$outdir/${code}.jf"

    # 2. Exportar el histograma dentro de la misma carpeta
    jellyfish histo -t 10 "$outdir/${code}.jf" > "$outdir/${code}.histo"

done
