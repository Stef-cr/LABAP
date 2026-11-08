#PROCESO DE ENSAMBLAJE DE GENOMA 

#1. unir los 2 archivos, en este caso 
# Para las lecturas forward (_1):
cat MA15_L1_1.fq.gz MA15_L2_1.fq.gz > MA15_1_merged.fq.gz

# Para las lecturas reverse (_2):
cat MA15_L1_2.fq.gz MA15_L2_2.fq.gz > MA15_2_merged.fq.gz

#2. EJECUTAR TRIMMGALORE 

#TRIMM DEFAULT 
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

#3. USAR SPADES 
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

#4. MEDUSA
 
#USAR MEDUSA SOLO EN CASO DE QUE EXISTA GENOMA DE REFERENCIA Y ESTE YA CON MARCADOR MOLECULAR O PRUEBA DE ITS 
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
#se hace una carpeta "Medusa" para tener los genomas de referencia 
#uso los contigs generados por SPAdes y los "medusa scripts" debe pasarlos la profe

#5. EJECUTAR BUSCO 
#!/bin/bash
#SBATCH --job-name=BUSCO
#SBATCH --output=busco.txt
#SBATCH --ntasks=1
#SBATCH --time=700:00
#SBATCH --partition=kura-long

. /opt/Modules/3.2.10/init/sh

module load miniconda/busco

busco -f -m genome -i Spades/contigs.fasta -l fungi_odb10 -c 8 -o BuscoFungi
busco -f -m genome -i Spades/contigs.fasta -l ascomycota_odb10 -c 8 -o BuscoASCO
busco -f -m genome -i Spades/contigs.fasta -l hypocreales_odb10 -c 8 -o BuscoHYPO 

#depende de los resultados se pueden usar otras bases de datos como Eurotiales o Eurotiomycetes

#6. EJECUTAR AUGUSTUS 

#veo en la lista los organismos mas cercanos al que estoy trabajando para ver cual utilizar
#!/bin/bash
#SBATCH --job-name=augustus
#SBATCH --output=augustus_MP4.txt
#SBATCH --ntasks=1
#SBATCH --time=700:00
#SBATCH --partition=dribe-long

module load bwa/0.7.17
module load samtools/1.9
module load gcc/11.1.0
module load SPAdes/3.11.0
module load python/3.5.2
module load jdk/15.0.2
module load mummer/4.0.0beta2
module load augustus/3.3
module load perl/5.34.0

##MIT License
#Copyright (c) [2025] Stefany Solano-Gonzalez
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
#documentation files (the �Software�), to deal in the Software for educational purposes only. You must give
#author appropriate credit, provide a link to the license and source, and indicate if changes were made.

######### Augustus Gene Prediction ######

#augustus Spades/scaffolds.fasta  --strand=both --stopCodonExcludedFromCDS=false --codingseq=on --protein=on --genemodel=complete --gff3=on --species=aspergillus_fumigatus > MP4_afum.gff3 

#augustus Spades/scaffolds.fasta  --strand=both --stopCodonExcludedFromCDS=false --codingseq=on --protein=on --genemodel=complete --gff3=on --species=aspergillus_nidulans > MP4_anid.gff3

#augustus Spades/scaffolds.fasta  --strand=both --stopCodonExcludedFromCDS=false --codingseq=on --protein=on --genemodel=complete --gff3=on --species=aspergillus_oryzae  > MP4_ory.gff3

## gff3 to CDS using augustus script

perl /opt/tools/augustus-3.3/scripts/getAnnoFasta.pl MP4_afum.gff3 --protein=on --codingseq=on
perl /opt/tools/augustus-3.3/scripts/getAnnoFasta.pl MP4_anid.gff3 --protein=on --codingseq=on
perl /opt/tools/augustus-3.3/scripts/getAnnoFasta.pl MP4_ory.gff3 --protein=on --codingseq=on

#7. EJECUTAR STRUCTURAL/PARTE FINAL
#!/bin/bash
#SBATCH --job-name=structural
#SBATCH --output=structural_manuscript.txt
#SBATCH --ntasks=1
#SBATCH --time=168:00:00
#SBATCH --partition=kura-long

. /opt/Modules/3.2.10/init/sh

module load miniconda/3  
module load miniconda/eggnog-mapper-2.1.6 
module load miniconda/barrnap
module load tRNAscan-SE/2.0.5
module load perl/5.34.0

#*MIT License*
#*Copyright (c) [2025] Stefany Solano-Gonz�lez*
#*Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software for educational purposes only. You must give author appropriate credit, provide a link to the license and source, and indicate if changes were made.*

##eggnog-mapper parameters
#needs fasta file with each individual gene fasta sequence
#need to download a DB
#emapper.py -i Augustus/Polished_canu_HortaeMedusa_neurospora3.aa -o eggmapper_out --itype proteins --excel -m diamond --query_cover 50 --evalue 1e-5 --report_orthologs --go_evidence all --cpu 10

##barrnap v.0.9 parameters
barrnap --kingdom euk --threads 10 --incseq --outseq rRNA_MP4hits.fasta Spades/scaffolds.fasta > MP4_rRNA.gff3

##tRNAscan parameters
#tRNAscan-SE -E -I -o MP4_tRNAscan.out --stats MP4_tRNAscan_stats.txt -b MP4_tRNAscan.bed Spades/scaffolds.fasta

#To cound Cazymes output from dbSCAN server
#awk '$5 != "N"{print $1,$5}' CAZyme.txt | sort -u
#awk '$6 ~ /^Y.*/ {print $0}' CAZyme.txt | wc -l

#de aqui para abajo es comprobaci�n en caso de tener dudas sobre el genoma 
#busco de nuevo pero con archivos con proteinas 
#!/bin/bash
#SBATCH --job-name=BUSCO2
#SBATCH --output=busco2.txt
#SBATCH --ntasks=1
#SBATCH --time=700:00
#SBATCH --partition=kura-long

. /opt/Modules/3.2.10/init/sh

module load miniconda/busco

busco -f -m proteins -i MA15_afum3.aa -l eurotiales_odb10 -c 8 -o Buscoafum
busco -f -m proteins -i MA15_anid3.aa -l eurotiales_odb10 -c 8 -o Buscoanid
busco -f -m proteins -i MA15_ory3.aa -l eurotiales_odb10 -c 8 -o Buscoory 
busco -f -m proteins -i MA15_terr3.aa -l eurotiales_odb10 -c 8 -o Buscoterr 

#como hacer un dotplot 
#!/bin/bash
#SBATCH --job-name=dotplot
#SBATCH --output=dotplot.txt
#SBATCH --ntasks=1
#SBATCH --time=350:00
#SBATCH --partition=dribe-long

module load miniconda/minimap2
module load R/4.0.2
module load gcc/11.1.0

minimap2 -x asm5 -t 16 Pmacrospinosa.fasta Periconia_medusa.fasta > Periconia_medusa.paf 

#Visualizaci�n en  https://dgenies.toulouse.inra.fr/run

#GRAFICA RESULTADOS ISOTOPOS
  
#basado en isotopos y la cantidad que tienen 
# Crear vectores
isotipos <- c("Ala", "Gly", "Pro", "Thr", "Val", "Ser", "Arg", "Leu", "Phe", "Asn", 
              "Lys", "Asp", "Glu", "His", "Gln", "Ile", "Met", "Tyr", "Cys", "Trp")
cantidad <- c(11, 13, 9, 10, 11, 13, 18, 5, 5, 6, 9, 11, 11, 5, 7, 10, 8, 9, 3, 3)

# Crear data frame
datos <- data.frame(Isotipo = isotipos, Cantidad = cantidad)

# Cargar ggplot2
library(ggplot2)

# Crear gr�fico de barras
ggplot(datos, aes(x = reorder(Isotipo, -Cantidad), y = Cantidad)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme_minimal() +
  labs(title = "Cantidad de tRNAs por is�topo",
       x = "Is�topo",
       y = "Cantidad de tRNAs") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  
  
#GRAFICA DE OTROS VALORES

 # Datos globales
categorias <- c("Total tRNAs", "Infernal-confirmados", "tRNAs con intrones", "Pseudogenes", "Is�topos desconocidos")
valores <- c(179, 179, 76, 9, 2)

# Crear data frame
df <- data.frame(Categoria = categorias, Valor = valores)

# Graficar
ggplot(df, aes(x = reorder(Categoria, -Valor), y = Valor)) +
  geom_bar(stat = "identity", fill = "darkorange") +
  theme_minimal() +
  labs(title = "Estad�sticas generales de tRNAs",
       x = "", y = "Cantidad") +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))
  
  #grafica basada en annotaciones 
  

