# LABAP_Assembly (Ensamblaje y Anotación de Genomas)

## Breve introducción
Este repositorio contiene un flujo de trabajo (pipeline) bioinformático estandarizado diseñado para el ensamblaje de novo, predicción estructural y anotación funcional de genomas eucariotas (específicamente hongos) a partir de datos de secuenciación masiva. En este flujo de trabajo se utilizan entornos de computación de alto rendimiento (HPC), como el supercomputador Kabré, para transformar lecturas de ADN crudas en secuencias genómicas ensambladas y biológicamente descritas. 
> Nota: Es necesario recalcar que se emplea el gestor de tareas SLURM para la correcta ejecución de cada etapa del proceso.
---

### ¿Cómo funciona este flujo de trabajo y qué herramientas integra?
A diferencia de plataformas cerradas de un solo entorno, este pipeline encadena múltiples herramientas bioinformáticas especializadas mediante módulos del clúster:
 * Preprocesamiento y Control de Calidad:
   * `cat`: Concatena archivos de lecturas provenientes de distintos carriles (lanes) de secuenciación.
   * `TrimGalore / FastQC / cutadapt`: Evalúan la calidad de las secuencias y recortan adaptadores o extremos con baja calidad.
 * Ensamblaje y Andamiaje (Scaffolding):
   * `SPAdes`: Ejecuta el ensamblaje de novo a partir de lecturas cortas utilizando múltiples tamaños de k-mers.
   * `MeDuSa`: Ordena y orienta los contigs en scaffolds utilizando genomas de referencia cercanos.
 * Evaluación y Anotación Genómica:
   * `BUSCO`: Evalúa la completitud del genoma o proteoma buscando genes ortólogos universales de copia única.
   * `Augustus`: Predice las coordenadas estructurales de los genes codificantes y extrae sus secuencias de proteínas y CDS.
   * `eggNOG-mapper, barrnap y tRNAscan-SE`: Realizan la anotación funcional de proteínas y la identificación de ARN ribosomal (ARNr) y ARN de transferencia (ARNt).
   * `minimap2 y R (ggplot2)`: Permiten comprobar la sintenia genómica mediante dotplots y graficar las estadísticas de anotación.
### Formatos de archivo clave
A lo largo de este flujo de trabajo se manejan los siguientes formatos estándar:
 * `.fq.gz (FASTQ comprimido)`: Contiene las lecturas crudas o limpias de ADN junto con sus puntajes de calidad por nucleótido.
 * `.fasta`: Formato de texto que almacena secuencias nucleotídicas ensambladas (contigs, scaffolds o secuencias de ARNr).
 * `.gff3 (General Feature Format)`: Archivo tabular que guarda las coordenadas exactas de los elementos predichos en el genoma (exones, intrones, CDS, ARNr).
 * `.aa / .codingseq`: Archivos derivados de la predicción génica que contienen las secuencias traducidas de aminoácidos (proteínas) y las secuencias codificantes de nucleótidos, respectivamente.
 * `.paf (Pairwise mApping Format)`: Archivo de coordenadas de alineamiento entre dos genomas utilizado para generar gráficos de comparación estructural (dotplots).

> El script principal está seccionado y ordenado para comprender fácilmente el propósito de cada herramienta. Está conformado por las siguientes secciones, las cuales se explican línea por línea a continuación: "1. Proceso de Ensamblaje de Genoma", "2. Ejecutar TrimGalore", "3. Usar SPAdes", "4. Usar MeDuSa", "5. Ejecutar BUSCO", "6. Ejecutar Augustus", "7. Ejecutar Structural" y "8. Realizar Comprobación".
## 1. Proceso de Ensamblaje de Genoma
Antes de iniciar el control de calidad, si el centro de secuenciación entregó las lecturas divididas en diferentes carriles (lanes, por ejemplo L1 y L2), es necesario unirlas en un único archivo para las lecturas forward (_1) y otro para las lecturas reverse (_2).

### Unir los archivos de lecturas:
El comando "`cat`" (concatenate) lee múltiples archivos de forma secuencial y une su contenido. En la primera línea, toma los archivos correspondientes a las lecturas hacia adelante ("MA15_L1_1.fq.gz" y "MA15_L2_1.fq.gz") y, mediante el operador ">", redirige y guarda la unión en un nuevo archivo llamado "MA15_1_merged.fq.gz". En la segunda línea ocurre exactamente lo mismo, pero uniendo las lecturas en sentido inverso ("_2") dentro del archivo "MA15_2_merged.fq.gz":
#### Para las lecturas forward (_1):
cat MA15_L1_1.fq.gz MA15_L2_1.fq.gz > MA15_1_merged.fq.gz

#### Para las lecturas reverse (_2):
cat MA15_L1_2.fq.gz MA15_L2_2.fq.gz > MA15_2_merged.fq.gz

---

## 2. Ejecutar TrimGalore
Mediante TrimGalore se realiza la limpieza inicial de las secuencias crudas, eliminando adaptadores remanentes de la secuenciación y recortando los extremos con baja calidad antes de ensamblar.

### Configuración del supercomputador (SLURM):
Los comandos "`#!/bin/bash`" y "`#SBATCH`" le indican al supercomputador las instrucciones que debe seguir al procesar el script. En este caso, "`#!/bin/bash`" define el lenguaje de terminal en el que se debe leer el código; "`--job-name=Trimgalore`" le asigna el nombre al trabajo en la cola; "`--output=Reads_trim`" indica el nombre del archivo de texto donde se guardará el registro (log) de salida; "`--ntasks=1`" especifica la cantidad de tareas o procesos simultáneos; "`--time=164:00:00`" establece el tiempo máximo de ejecución (164 horas); y "`--partition=dribe-long`" indica el grupo de nodos que se debe utilizar:

#!/bin/bash
#SBATCH --job-name=Trimgalore
#SBATCH --output=Reads_trim
#SBATCH --ntasks=1
#SBATCH --time=164:00:00
#SBATCH --partition=dribe-long 

### Cargar módulos necesarios y ejecutar recorte por defecto (Default):
El comando "`module load`" activa en el entorno del servidor los programas requeridos: "TrimGalore/0.4.3", "cutadapt/Python3.5-1.9.1" (herramienta interna que usa TrimGalore para cortar adaptadores) y "fastqc/0.11.9" (para generar reportes visuales de calidad).

En la línea de ejecución, "`trim_galore`" inicia el programa. "`--paired`" indica que se están procesando lecturas emparejadas (forward y reverse, en este ejemplo "MA9A_merged_1.fq.gz" y "MA9A_merged_2.fq.gz", o bien "MA15_1_merged.fq.gz" y "MA15_2_merged.fq.gz" según la muestra). "`--fastqc`" instruye al programa para que ejecute automáticamente un análisis de FastQC una vez finalizado el recorte, y "`-o FASTQC/`" define el directorio de salida donde se guardarán las secuencias limpias y los reportes:

module load TrimGalore/0.4.3
module load cutadapt/Python3.5-1.9.1
module load fastqc/0.11.9

trim_galore --paired MA9A_merged_1.fq.gz MA9A_merged_2.fq.gz --fastqc -o FASTQC/

### Ejecutar recorte con valores específicos:
Si al revisar las gráficas de calidad de FastQC se observa ruido al inicio de las lecturas, se puede repetir el trabajo indicando cuántos nucleótidos exactos recortar.

En las siguientes líneas se mantiene la misma estructura de SLURM y carga de módulos, pero en el comando "`trim_galore`" se agregan los parámetros "`--clip_R1 5`" para cortar 5 bases del extremo 5' de las lecturas forward ("MP4_MERGED_val_1.fq.gz") y "`--clip_R2 15`" o "`--clip_R2 10`" para cortar 15 o 10 bases del extremo 5' de las lecturas reverse ("MP4_MERGED_val_2.fq.gz"), dependiendo de lo observado en las gráficas de calidad:

#!/bin/bash
#SBATCH --job-name=Trimgalore
#SBATCH --output=Reads_trim
#SBATCH --ntasks=1
#SBATCH --time=164:00:00
#SBATCH --partition=dribe-long

module load TrimGalore/0.4.3
module load cutadapt/Python3.5-1.9.1
module load fastqc/0.11.9

#### Los valores clip pueden quitarse para verlo default o cambiarse dependiendo de las gráficas de calidad:
#trim_galore --paired --clip_R1 5 MP4_MERGED_val_1.fq.gz --clip_R2 15 MP4_MERGED_val_2.fq.gz --fastqc -o FASTQC/

trim_galore --paired --clip_R1 5 MP4_MERGED_val_1.fq.gz --clip_R2 10 MP4_MERGED_val_2.fq.gz --fastqc -o FASTQC/

---

## 3. Usar SPAdes
Una vez obtenidas las secuencias limpias y validadas (_val_1.fq.gz y _val_2.fq.gz), se utiliza SPAdes para realizar el ensamblaje genómico de novo.
### Ensamblaje estándar:
Se configura el encabezado #SBATCH para la partición "`dribe-long`" y se cargan con "`module load`" el ensamblador "`SPAdes/3.15.4`", el entorno "`miniconda/3`" y las herramientas de alineamiento y manejo de secuencias "`samtools/1.16`" y "`bwa/0.7.17`".

En la línea de comando, "`spades.py`" inicia el ensamblador. "`-1`" y "`-2`" indican las rutas de los archivos de lecturas forward y reverse ya recortados por TrimGalore. "`--cov-cutoff auto`" le indica al algoritmo que calcule y aplique automáticamente un umbral de cobertura para descartar contigs de muy baja cobertura o ruido. "`-o Spades_trimm`" define el nombre de la carpeta donde se guardarán los resultados del ensamblaje. "`-k 89,95,97,101,107,117,127`" establece la lista de tamaños de fragmentos (k-mers) que el programa utilizará iterativamente para construir los grafos de ensamblaje. Finalmente, "`-t 20`" asigna 20 hilos de procesamiento (threads) para acelerar el cálculo:

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

spades.py -1 FASTQC/MA9A_merged_1_val_1.fq.gz -2 FASTQC/MA9A_merged_2_val_2.fq.gz --cov-cutoff auto -o Spades_trimm -k 89,95,97,101,107,117,127 -t 20

### Ensamblaje en Modo Careful:
En este segundo bloque se ejecuta exactamente el mismo flujo de SPAdes, pero añadiendo la bandera "`--careful`" y guardando los resultados en la carpeta "`-o Spa_care`". El parámetro "`--careful`" activa algoritmos internos de corrección para minimizar el número de desajustes (mismatches) e inserciones/deleciones cortas (indels) durante el ensamblaje:

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

### careful mode on
spades.py -1 MA9A_merged_1_val_1.fq.gz -2 MA9A_merged_2_val_2.fq.gz --careful --cov-cutoff auto -o Spa_care -k 89,95,97,101,107,117,127 -t 20

---

## 4. Usar MeDuSa
> Nota condicional: MeDuSa se debe utilizar únicamente en caso de que exista un genoma de referencia cercano y la muestra ya haya sido previamente identificada mediante marcador molecular o prueba de ITS.
> 
### Andamiaje (Scaffolding) basado en referencias:
En este bloque se solicita la partición "`kura-long`" con un tiempo de "`100:00`". La línea "`. /opt/Modules/3.2.10/init/sh`" inicializa el sistema de módulos dentro de los nodos de la partición kura, permitiendo cargar "`miniconda/medusa`" y el alineador genómico "`mummer/4.0.0beta2`".

En el comando principal, "`java -jar /opt/python/miniconda3/envs/medusa/share/medusa-1.6-2/medusa.jar`" ejecuta el archivo empaquetado de MeDuSa mediante Java. "`-f Medusa`" indica el nombre de la carpeta donde se almacenaron previamente los genomas de referencia cercanos. "`-i /work/tarias/MA15/FASTQC1/Spades2/contigs.fasta`" especifica la ruta del archivo de entrada que contiene los contigs generados por SPAdes. "`-o MA15_medusaQC`" define el nombre del archivo de salida con los scaffolds optimizados. "`-v`" (verbose) solicita que el programa imprima detalles del progreso en pantalla, y "`-scriptPath /work/tarias/medusa_scripts`" indica la ruta de la carpeta que contiene los scripts auxiliares necesarios para que MeDuSa funcione:

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

---

## 5. Ejecutar BUSCO
BUSCO permite evaluar qué tan completo quedó nuestro ensamblaje genómico comparándolo contra bases de datos de genes ortólogos universales de copia única.
### Evaluación del genoma ensamblado:
Tras configurar SLURM en la partición "`kura-long`", inicializar el entorno de módulos y cargar "`miniconda/busco`", se ejecutan tres análisis consecutivos a diferentes niveles taxonómicos.
En cada línea, "`busco`" inicia el programa. "`-f`" (force) obliga a sobrescribir archivos previos si llevan el mismo nombre de salida. "`-m genome`" le indica a BUSCO que el archivo que va a evaluar es un ensamblaje de ADN genómico completo. "`-i Spades/contigs.fasta`" señala el archivo FASTA de entrada generado por el ensamblador. "`-l`" define la base de datos de linaje evolutivo contra la cual se comparará el genoma (en este caso se prueba desde lo más general hasta lo más específico: "`fungi_odb10`", "`ascomycota_odb10`" e "`hypocreales_odb10`", pudiendo cambiarse por bases como Eurotiales según el hongo en estudio). "`-c 8`" asigna 8 núcleos de CPU al proceso, y "`-o`" define el nombre del directorio donde se guardarán los resultados de cada corrida ("`BuscoFungi`", "`BuscoASCO`" y "`BuscoHYPO`"):

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

---

## 6. Ejecutar Augustus
En esta etapa se utiliza Augustus para predecir la estructura de los genes codificantes dentro de los scaffolds ensamblados, utilizando modelos estadísticos de especies fúngicas cercanas disponibles en la lista del programa.
### Predicción estructural de genes y extracción de secuencias:
Se configura el trabajo en SLURM y se cargan las dependencias del sistema junto con "`augustus/3.3`" y "`perl/5.34.0`".

En el primer bloque de comandos, "`augustus Spades/scaffolds.fasta`" ejecuta el predictor sobre el archivo de scaffolds. "`--strand=both`" indica que busque genes en ambas hebras del ADN (forward y reverse). "`--stopCodonExcludedFromCDS=false`" especifica que el codón de parada (stop codon) debe incluirse dentro de la secuencia codificante (CDS). "`--codingseq=on`" y "`--protein=on`" ordenan al programa que escriba las secuencias nucleotídicas codificantes y las secuencias de aminoácidos traducidas dentro de los comentarios del archivo de salida. "`--genemodel=complete`" restringe la predicción únicamente a genes completos (con codón de inicio y de parada). "`--gff3=on`" establece que el formato de salida sea GFF3. "`--species=...`" indica el organismo modelo cercano cuyos parámetros de entrenamiento se usarán (aquí se prueban tres especies: "`aspergillus_fumigatus`", "`aspergillus_nidulans`" y "`aspergillus_oryzae`"). Finalmente, "`> MP4_afum.gff3`" guarda las coordenadas y predicciones en un archivo .gff3 para cada especie.

En el segundo bloque, se utiliza el intérprete "`perl`" para correr el script auxiliar "`/opt/tools/augustus-3.3/scripts/getAnnoFasta.pl`" sobre cada archivo .gff3 generado. Al acompañarlo de "`--protein=on`" y "`--codingseq=on`", este script extrae las secuencias que estaban incrustadas dentro del archivo .gff3 y crea archivos FASTA independientes con las proteínas (.aa) y las secuencias codificantes (.codingseq):

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

######### Augustus Gene Prediction #########

augustus Spades/scaffolds.fasta --strand=both --stopCodonExcludedFromCDS=false --codingseq=on --protein=on --genemodel=complete --gff3=on --species=aspergillus_fumigatus > MP4_afum.gff3 

augustus Spades/scaffolds.fasta --strand=both --stopCodonExcludedFromCDS=false --codingseq=on --protein=on --genemodel=complete --gff3=on --species=aspergillus_nidulans > MP4_anid.gff3

augustus Spades/scaffolds.fasta --strand=both --stopCodonExcludedFromCDS=false --codingseq=on --protein=on --genemodel=complete --gff3=on --species=aspergillus_oryzae > MP4_ory.gff3

### gff3 to CDS using augustus script

perl /opt/tools/augustus-3.3/scripts/getAnnoFasta.pl MP4_afum.gff3 --protein=on --codingseq=on
perl /opt/tools/augustus-3.3/scripts/getAnnoFasta.pl MP4_anid.gff3 --protein=on --codingseq=on
perl /opt/tools/augustus-3.3/scripts/getAnnoFasta.pl MP4_ory.gff3 --protein=on --codingseq=on

---

## 7. Ejecutar Structural (Anotación Funcional y ARN no codificante)
En esta sección final del flujo principal se anotan funcionalmente las proteínas predichas, se identifican los genes de ARN no codificante (ARNr y ARNt) y se contabilizan las enzimas activas en carbohidratos (CAZymes).
### Configuración y carga de módulos:
Se define el trabajo en SLURM sobre la partición "`kura-long`" con un tiempo límite de "`168:00:00`". Se inicializa el entorno de módulos y se cargan "`miniconda/3`", "`miniconda/eggnog-mapper-2.1.6`", "`miniconda/barrnap`", "`tRNAscan-SE/2.0.5`" y "`perl/5.34.0`":

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

### Anotación funcional con eggNOG-mapper:
El comando "`emapper.py`" ejecuta eggNOG-mapper. "`-i Augustus/Polished_canu_HortaeMedusa_neurospora3.aa`" ingresa el archivo FASTA con las secuencias de proteínas obtenidas de Augustus. "`-o eggmapper_out`" define el prefijo de los archivos de salida. "`--itype proteins`" especifica que los datos de entrada son secuencias de aminoácidos. "`--excel`" genera adicionalmente el reporte de anotación en una hoja de cálculo .xlsx. "`-m diamond`" indica que se utilice el algoritmo DIAMOND para realizar la búsqueda rápida de homología. "`--query_cover 50`" exige que el alineamiento cubra como mínimo el 50% de la secuencia consultada. "`--evalue 1e-5`" establece el umbral estadístico de valor E máximo aceptado. "`--report_orthologs`" solicita que se incluya la lista detallada de genes ortólogos detectados. "`--go_evidence all`" incluye todos los códigos de evidencia de Ontología Génica (GO), y "`--cpu 10`" asigna 10 núcleos de procesamiento:

#### eggnog-mapper parameters
emapper.py -i Augustus/Polished_canu_HortaeMedusa_neurospora3.aa -o eggmapper_out --itype proteins --excel -m diamond --query_cover 50 --evalue 1e-5 --report_orthologs --go_evidence all --cpu 10

### Predicción de ARN ribosomal (ARNr) con Barrnap:
Con "`barrnap`" se localizan los genes de ARNr en el genoma. "`--kingdom euk`" ajusta los modelos de búsqueda para organismos eucariotas (subunidades 5S, 5.8S, 18S y 28S). "`--threads 10`" utiliza 10 hilos de CPU. "`--incseq`" adjunta las secuencias FASTA encontradas al final del archivo GFF3 de salida. "`--outseq rRNA_MP4hits.fasta`" guarda las secuencias de ARNr predichas en un archivo FASTA separado. "`Spades/scaffolds.fasta`" indica el genoma de entrada, y "`> MP4_rRNA.gff3`" redirige la tabla de coordenadas al archivo GFF3:

#### barrnap v.0.9 parameters
barrnap --kingdom euk --threads 10 --incseq --outseq rRNA_MP4hits.fasta Spades/scaffolds.fasta > MP4_rRNA.gff3

### Predicción de ARN de transferencia (ARNt) con tRNAscan-SE:
El comando "`tRNAscan-SE`" busca genes de ARNt a lo largo del ensamblaje. "`-E`" configura el programa para buscar ARNt citoplasmáticos eucariotas. "`-I`" activa el motor de búsqueda basado en modelos de covarianza de Infernal para mayor precisión. "`-o MP4_tRNAscan.out`" define el archivo tabular donde se guardará la lista de ARNt detectados. "`--stats MP4_tRNAscan_stats.txt`" genera un resumen estadístico global (total de ARNt, intrones, pseudogenes, etc.). "`-b MP4_tRNAscan.bed`" exporta las coordenadas genómicas en formato BED, y "`Spades/scaffolds.fasta`" indica el archivo de entrada:

#### tRNAscan parameters
tRNAscan-SE -E -I -o MP4_tRNAscan.out --stats MP4_tRNAscan_stats.txt -b MP4_tRNAscan.bed Spades/scaffolds.fasta

### Conteo de enzimas CAZymes ( filtrado de resultados de dbCAN):
Estas dos líneas en lenguaje awk permiten filtrar y contar los resultados descargados del servidor web dbCAN ("`CAZyme.txt`").
 * En la primera línea, "`awk '$5 != "N"{print $1,$5}' CAZyme.txt`" revisa que la columna 5 no sea "`N`" (negativo) e imprime únicamente el identificador del gen (columna 1) y la familia predicha (columna 5); luego "`| sort -u`" ordena la lista y elimina duplicados.
 * En la segunda línea, "`awk '$6 ~ /^Y.*/ {print $0}' CAZyme.txt`" filtra todas las filas cuya columna 6 empiece con la letra "`Y`" (Yes, indicando confirmación positiva), y "`| wc -l`" (word count - lines) cuenta el número total de líneas para saber cuántas CAZymes fueron confirmadas:

#### To count Cazymes output from dbSCAN server
awk '$5 != "N"{print $1,$5}' CAZyme.txt | sort -u
awk '$6 ~ /^Y.*/ {print $0}' CAZyme.txt | wc -l

---

## 8. Realizar Comprobación
Esta sección agrupa análisis de verificación post-anotación para resolver dudas sobre la calidad de las proteínas predichas, evaluar la sintenia estructural contra otra especie y graficar los resultados de ARNt en R.
### 8.1. Comprobación de proteínas con BUSCO (BUSCO2):
Aquí se vuelve a ejecutar "`busco`", pero cambiando el modo a "`-m proteins`" e ingresando como entrada ("`-i`") los archivos de aminoácidos .aa generados por Augustus con distintos modelos de especies ("`MA15_afum3.aa`", "`MA15_anid3.aa`", "`MA15_ory3.aa`" y "`MA15_terr3.aa`") contra la base de datos "`-l eurotiales_odb10`". Esto permite comparar cuál de los modelos de predicción de Augustus logró recuperar el proteoma más completo:

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

### 8.2. Alineamiento genómico para Dotplot (minimap2):
Para comparar visualmente la estructura cromosómica entre dos ensamblajes, se cargan "`miniconda/minimap2`", "`R/4.0.2`" y "`gcc/11.1.0`".
El comando "`minimap2`" ejecuta el alineador de secuencias largas. "`-x asm5`" aplica un ajuste preconfigurado para alinear dos genomas completos con baja divergencia evolutiva (~5%). "`-t 16`" utiliza 16 hilos de procesamiento. Luego se indican el genoma de referencia ("`Pmacrospinosa.fasta`") y el genoma ensamblado a comparar ("`Periconia_medusa.fasta`"), redirigiendo el resultado con "`>`" hacia el archivo "`Periconia_medusa.paf`". Este archivo .paf puede subirse directamente a la plataforma web D-GENIES para visualizar el gráfico de puntos (dotplot):

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
#### Visualización en https://dgenies.toulouse.inra.fr/run

### 8.3. Gráficas estadísticas de tRNAs en R (ggplot2):
Estos bloques de código se ejecutan en el entorno estadístico R para visualizar los datos obtenidos del archivo MP4_tRNAscan_stats.txt.
En el primer gráfico (Cantidad de tRNAs por isótopo/isotipo):
 * "`isotipos <- c(...)`" y "`cantidad <- c(...)`" crean dos vectores con los nombres de los 20 aminoácidos y el conteo de ARNt detectados para cada uno.
 * "`datos <- data.frame(Isotipo = isotipos, Cantidad = cantidad)`" une ambos vectores en una tabla de datos (data frame).
 * "`library(ggplot2)`" carga la librería de visualización.
 * "`ggplot(datos, aes(x = reorder(Isotipo, -Cantidad), y = Cantidad))`" inicializa el lienzo del gráfico ordenando el eje X de mayor a menor cantidad (-Cantidad).
 * "`+ geom_bar(stat = "identity", fill = "steelblue")`" dibuja las barras con los valores exactos de la tabla en color azul acero.
 * "`+ theme_minimal()`" aplica un fondo limpio sin recuadros grises.
 * "`+ labs(...)`" asigna el título principal y las etiquetas de los ejes X e Y.
 * "`+ theme(axis.text.x = element_text(angle = 45, hjust = 1))`" inclina los nombres de los aminoácidos a 45 grados para que no se superpongan:

### GRAFICA RESULTADOS ISOTOPOS
#### Crear vectores
isotipos <- c("Ala", "Gly", "Pro", "Thr", "Val", "Ser", "Arg", "Leu", "Phe", "Asn", 
              "Lys", "Asp", "Glu", "His", "Gln", "Ile", "Met", "Tyr", "Cys", "Trp")
cantidad <- c(11, 13, 9, 10, 11, 13, 18, 5, 5, 6, 9, 11, 11, 5, 7, 10, 8, 9, 3, 3)

#### Crear data frame
datos <- data.frame(Isotipo = isotipos, Cantidad = cantidad)

#### Cargar ggplot2
library(ggplot2)

#### Crear gráfico de barras
ggplot(datos, aes(x = reorder(Isotipo, -Cantidad), y = Cantidad)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme_minimal() +
  labs(title = "Cantidad de tRNAs por isótopo",
       x = "Isótopo",
       y = "Cantidad de tRNAs") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 

En el segundo gráfico (Estadísticas generales de tRNAs) ocurre exactamente la misma estructura de comandos en ggplot2, pero graficando en color naranja oscuro ("`darkorange`") y con una inclinación de texto de 30 grados ("`angle = 30`") las métricas globales del análisis: el total de ARNt, los confirmados por Infernal, los ARNt con intrones, los pseudogenes y los isótopos desconocidos:

### GRAFICA DE OTROS VALORES
#### Datos globales
categorias <- c("Total tRNAs", "Infernal-confirmados", "tRNAs con intrones", "Pseudogenes", "Isótopos desconocidos")
valores <- c(179, 179, 76, 9, 2)

#### Crear data frame
df <- data.frame(Categoria = categorias, Valor = valores)

#### Graficar
ggplot(df, aes(x = reorder(Categoria, -Valor), y = Valor)) +
  geom_bar(stat = "identity", fill = "darkorange") +
  theme_minimal() +
  labs(title = "Estadísticas generales de tRNAs",
       x = "", y = "Cantidad") +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

---

MIT License
Copyright (c) [2025] Stefany Solano-González
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software for educational purposes only. You must give author appropriate credit, provide a link to the license and source, and indicate if changes were made.
