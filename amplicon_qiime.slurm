## Pipeline para correr qiime utilizando datos de metagenómica de amplicones

# *MIT License*
# *Copyright (c) [2025] Tatiana Arias-Rojas & Stefany Solano-González*
# *Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software for educational purposes only. You must give author appropriate credit, provide a link to the license and source, and indicate if changes were made.*

# Pipeline qiime estandarizado para el supercomputador de Kabre



#Qiime2 es una herramienta bioinformatica para analizar datos de secuenciacion de de comunidades microbianas (por ejemplo, datos de 16S, 18S, ITS, shotgun, etc.). 

#Este funciona por medio de plugins, que son como aplicaciones especificas para ejecutar una accion particular, por ejemplo: 

#q2-demux= manejar datos demultiplexados.

#q2-dada2= filtrar y desreplicar secuencias, detectar variantes de secuencia.

#q2-feature-table= manejar tablas de abundancia de OTUs/ASVs.

#entre otros

#Asi mismo se usan diferentes tipos semanticos, que es un sistema especial de tipo de datos.No solo dicen el formato del archivo, sino tambiÈn el significado biolÛgico de esos datos.

#Esto protege al usuario de cometer errores, por ejemplo: 

#SampleData[SequencesWithQuality]= secuencias crudas con calidades (FASTQ).

#FeatureTable[Frequency]= tabla de abundancias de ASVs/OTUs.

#Phylogeny[Rooted]= ·rbol filogenÈtico enraizado.

#Taxonomy= anotaciones taxonÛmicas.

#TIPOS DE ARCHIVO 
#.qza = QIIME Zipped Artifact. Representan datos generados por QIIME2/ si elo formato del archivo no es este NO va a funcionar
#Son archivos pensados para ser usados dentro de QIIME 2 como pasos intermedios en un flujo de an·lisis.

#.qzv = QIIME Zipped Visualization. Representan resultados para interpretar, como gr·ficas, tablas interactivas, taxonomÌa etc.
#Est·n hechos para ser vistos por humanos y no como entrada en otros an·lisis.
#La forma de ver estos archivos es por medio de qiime2view: https://view.qiime2.org/ 
#Para mas informacion: https://amplicon-docs.qiime2.org/en/latest/explanations/getting-started.html 

#ANTES DE COMENZAR
#Conozca sus datos y la manera en que debe subir la informacion:

#øEstan demultiplexeados o multiplexeados?

#øtiene metadata? archivo con informaciÛn que describe las caracteristicas que describen cada dato, como: fecha de muestreo, posiciÛn geogr·fica, condiciones ambientales, ect. 
este debe seguir el formato especifico aceptado por qiime, sin esto NO va a funcionar su archivo. 
#Siempre la primera columna debe ir con un Sample-id, ejemplo: 
sample-id	Bucket	SampleNumber	SampleType
#q2:types	categorical	numeric	categorical
8092ad80	1	1	Bulking Material
4482d2bc	1	2	Bulking Material
f2979533	1	3	Bulking Material
355cbba7	1	4	Inside Toilet Pre Use
de8f6a92	1	5	Soil Nearby Toilet
52f2a5eb	1	6	SunMar Microbe Mix
6c055796	1	7	Human Excrement
1ce93c87	1	8	Human Excrement
f88c3e66	1	9	Human Excrement
bcfdfab6	1	10	Human Excrement
1c9d1ab0	1	11	Human Excrement Compost Pre-Roll
772b5c41	1	12	Human Excrement Compost
3ec3c78c	1	13	Human Excrement Compost Pre-Roll
f48dce8e	1	14	Human Excrement Compost
7c46c840	1	15	Human Excrement Compost Pre-Roll
e706dd01	1	16	Human Excrement Compost
b1e34ca3	1	17	Human Excrement Compost Pre-Roll
ccbfb567	1	18	Human Excrement Compost
 #Debe cargarse como un archivo .tsv la forma mas comun de generar estos archivos es usando Microsoft Excel o Google sheets, en esta puede usar la herramienta keemei que revisa su metadata y aprueba su correcta estructura 
#https://keemei.qiime2.org/

#Basado en el tutorial de qiime2 "moving pictures tutorial" https://amplicon-docs.qiime2.org/en/latest/tutorials/moving-pictures.html
#En este tutorial, se realiza un an·lisis de muestras del microbioma humano de dos individuos en cuatro partes del cuerpo y cinco momentos distintos, el primero de los cuales fue inmediatamente despuÈs del uso de antibiÛticos. Las muestras utilizadas aquÌ se publicaron originalmente en Caporaso et al. (2011). Los datos utilizados aquÌ son un pequeÒo subconjunto de los generados para el artÌculo.

#input-file = el archivo que quiero utilizar 
#output file = el archivo que quiero obtener 
#visualization = el visualizable .qzv
===========================================================EJEMPLO=========================================================================================================================================
#descargar el archivo 
wget -O 'sample-metadata.tsv' \
  'https://moving-pictures-tutorial.readthedocs.io/en/latest/data/moving-pictures/sample-metadata.tsv'
  
#VER ARCHIVO DE METADATA
#!/bin/bash
#SBATCH --job-name=qiime-metadata
#SBATCH --output=qiime-metadata.txt
#SBATCH --partition=dribe
#SBATCH --ntasks=1
#SBATCH --time=01:00:00

# cargar modulos necesarios
module load miniconda/qiime2-2024.2
qiime metadata tabulate --m-input-file sample-metadata.tsv --o-visualization sample-metadata.qzv
==========================================================EJEMPLO==================================================================================================================================================

#Para descargar los datos depender· de como estan almacenados los mismos, por lo que el codigo de importar cambia basado en el formato de sus datos
#Continuando con los datos del tutorial "moving pictures tutorial"

===========================================================EJEMPLO=========================================================================================================================================
#usando el mismo archivo de metadata, seguidamente descargue para tener el archivo en el formato especifico para importar los datos:
wget -O 'emp-single-end-sequences.zip' \
  'https://moving-pictures-tutorial.readthedocs.io/en/latest/data/moving-pictures/emp-single-end-sequences.zip'

unzip -d emp-single-end-sequences emp-single-end-sequences.zip

#IMPORTAR DATOS QUE NO ESTAN DEMULTIPLEXEADOS 
#!/bin/bash
#SBATCH --job-name=qiime-demultiplex
#SBATCH --output=qiime-demultiplex.txt
#SBATCH --partition=dribe
#SBATCH --ntasks=1
#SBATCH --time=01:00:00

# cargar modulos necesarios
module load miniconda/qiime2-2024.2 
#EMPSingleEndSequences/ EMPPairedEndSequences depende de sus secuencias 

qiime tools import --type 'EMPSingleEndSequences' --input-path emp-single-end-sequences --output-path emp-single-end-sequences.qza
===========================================================EJEMPLO=========================================================================================================================================
#seguidamente se deben demultiplexear los datos, para demultiplexar secuencias, necesitamos saber quÈ secuencia de cÛdigo de barras est· asociada a cada muestra.
#Esta informaciÛn se encuentra en el archivo de metadatos de la muestra, por eso es importante y necesario tener un archivo de metadatos. 

===========================================================EJEMPLO=========================================================================================================================================

#DEMULTIPLEXEAR DATOS 
#!/bin/bash
#SBATCH --job-name=qiime-demultiplex
#SBATCH --output=qiime-demultiplex.txt
#SBATCH --partition=dribe
#SBATCH --ntasks=1
#SBATCH --time=01:00:00

# cargar modulos necesarios
module load miniconda/qiime2-2024.2 

#single-end o paired-end/ depende de sus datos 

qiime demux emp-single --i-seqs emp-single-end-sequences.qza --m-barcodes-file sample-metadata.tsv --m-barcodes-column barcode-sequence --o-per-sample-sequences demux.qza --o-error-correction-details demux-details.qza
#Visualizar archivo 
qiime demux summarize --i-data demux.qza --o-visualization demux.qzv
===========================================================EJEMPLO=========================================================================================================================================
#Estos archivos nos brindan informacion para la siguiente parte. 
#basado en el grafico que aparece en la seccion "interactive quality plot" podemos ver la calidad de las secuencias (lo ideal es que esten arriba de 20 o 15) y basado en eso se puede ver que debemos recortar 
#de igual manera se genera un archivo .tsv donde se puede filtar los resultados y ver de mejor manera la caida de calidad y donde es recomendable recortar 

#IMPORTAR CON EL ARCHIVO DEMUX.QZA 
#podemos solo tener el archivo demux.qza de una vez, esto nos permite comenzar con el denoising

#IMPORTAR DATOS SIN METADATA 
#se necesita un archivo manifest.tsv para poder establecer nuestros datos en el sistema, este tiene un formato en especifico. 
#este archivo sirve para indicarle a QIIME dÛnde est·n los archivos de secuencias en tu computadora, relaciona cada archivo FASTQ con su muestra (sample-id).
#Ademas, se especifica si las secuencias son forward o reverse, por ejemplo: 
#MANIFEST SINGLE-END
sample-id absolute-filepath
sample-1  /scratch/microbiome/sample1_R1.fastq.gz
sample-2  /scratch/microbiome/sample2_R1.fastq.gz

#MANIFEST PAIRED-END
sample-id forward-absolute-filepath   reverse-absolute-filepath
sample-1  /scratch/microbiome/sample1_R1.fastq.gz  /scratch/microbiome/sample1_R2.fastq.gz
sample-2  /scratch/microbiome/sample2_R1.fastq.gz  /scratch/microbiome/sample2_R2.fastq.gz
===========================================================EJEMPLO=========================================================================================================================================
#!/bin/bash
#SBATCH --job-name=qiime-dada2
#SBATCH --output=qiime-dada2.txt
#SBATCH --partition=dribe
#SBATCH --ntasks=1
#SBATCH --time=01:00:00

# cargar modulos necesarios
module load miniconda/qiime2-2024.2 

qiime tools import --type "SampleData[SequencesWithQuality]" --input-format SingleEndFastqManifestPhred33V2 --input-path ./manifest.tsv --output-path ./demux_seqs.qza

#archivo visualizacion 
qiime demux summarize --i-data ./demux_seqs.qza --o-visualization ./demux_seqs.qzv
===========================================================EJEMPLO=========================================================================================================================================

#DENOISING CON DADA2 
#Este es un proceso para limpiar los datos de secuenciaciÛn, su funciÛn principal es detectar y corregir errores en las lecturas, y adem·s eliminar aquellas que provienen de phiX o que resultan ser quimeras
#--p-trim-left=  recorta las primeras bases de las secuencias
#--p-trunc-left= trunca la secuencia en n posicion 
#de igual manera puede incluir sus primers para que sean recordatos automaticamente 

#seguimos con el tutorial anterior
===========================================================EJEMPLO=========================================================================================================================================
#!/bin/bash
#SBATCH --job-name=qiime-dada2
#SBATCH --output=qiime-dada2.txt
#SBATCH --partition=dribe
#SBATCH --ntasks=1
#SBATCH --time=01:00:00

# cargar modulos necesarios
module load miniconda/qiime2-2024.2 

#eliminar ruido y hacer tabla de caracteristicas
#denoise-single para secuencias single-end
#denoise-paired para secuencias paired-end 
qiime dada2 denoise-single --i-demultiplexed-seqs /work/tarias/qiimetuto/demux_seqs.qza --p-trim-left 0 --p-trunc-len 120 --o-table ./table.qza --o-representative-sequences ./rep-seqs.qza --o-denoising-stats ./stats.qza

# Ver las estadisticas de eliminaciÛn 
qiime metadata tabulate --m-input-file stats.qza --o-visualization stats.qzv

===========================================================EJEMPLO=========================================================================================================================================

#El siguiente comando permite visualizar la tabla de caracterÌsticas 
===========================================================EJEMPLO=========================================================================================================================================
#!/bin/bash
#SBATCH --job-name=qiime-fetable
#SBATCH --output=fetable.txt
#SBATCH --partition=dribe
#SBATCH --ntasks=1
#SBATCH --time=01:00:00

# cargar modulos necesarios
module load miniconda/qiime2-2024.2 
#--m-sample-metadata-file en caso de que se tenga archivo de metadatos

qiime feature-table summarize --i-table table.qza --m-sample-metadata-file sample-metadata.tsv --o-visualization table.qzv

qiime feature-table tabulate-seqs --i-data rep-seqs.qza --o-visualization rep-seqs.qzv
===========================================================EJEMPLO=========================================================================================================================================
#con los archivos obtenidos se continua la ejecuccion de los demas pasos

#ARBOL FILOGENETICO PARA ANALISIS DE DIVERSIDAD O SUBIR A HERRAMIENTAS DE VISUALIZACION
===========================================================EJEMPLO=========================================================================================================================================
#!/bin/bash
#SBATCH --job-name=qiime-tree
#SBATCH --output=qiime-tree.txt
#SBATCH --partition=dribe
#SBATCH --ntasks=1
#SBATCH --time=01:00:00

# cargar modulos necesarios
module load miniconda/qiime2-2024.2  #incluye mafft tree
qiime phylogeny align-to-tree-mafft-fasttree --i-sequences ./rep-seqs.qza --o-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza --o-tree unrooted-tree.qza --o-rooted-tree rooted-tree.qza
===========================================================EJEMPLO=========================================================================================================================================

#ANALISIS DE DIVERSIDAD ALFA-BETA 

#DIVERSIDAD ALFA: mide la diversidad dentro de una muestra, como los parametros: 
#Õndice de diversidad de Shannon (una medida cuantitativa de la riqueza de la comunidad)
#CaracterÌsticas observadas (una medida cualitativa de la riqueza de la comunidad)
#Diversidad filogenÈtica de Faith (una medida cualitativa de la riqueza de la comunidad que incorpora relaciones filogenÈticas entre las caracterÌsticas)
#Uniformidad (o uniformidad de Pielou; una medida de la uniformidad de la comunidad)

#ANALISIS BETA: mide la diversidad entre muestras, como los parametros: 
#Distancia de Jaccard (una medida cualitativa de la disimilitud de la comunidad)
#Distancia de Bray-Curtis (una medida cuantitativa de la disimilitud de la comunidad)
#distancia UniFrac no ponderada (una medida cualitativa de la disimilitud de la comunidad que incorpora relaciones filogenÈticas entre las caracterÌsticas)
#distancia UniFrac ponderada (una medida cuantitativa de la disimilitud de la comunidad que incorpora relaciones filogenÈticas entre las caracterÌsticas)

#En los an·lisis de diversidad  hay que dar un par·metro --p-sampling-depth, que define la profundidad de muestreo uniforme
#Esto significa que todas las muestras se ìajustanî para tener la misma cantidad de secuencias, porque si cada muestra tiene n˙meros muy distintos, las comparaciones no serÌan justas
#Por lo que basado en el archivo table.qza se toma un n˙mero que se indica y selecciona al azar, de esta manera todas quedan iguales en cantidad 
#Pero si alguna muestra tiene menos de ese n˙mero, se elimina autom·ticamente del an·lisis porque no alcanza
===========================================================EJEMPLO=========================================================================================================================================
#!/bin/bash
#SBATCH --job-name=qiime-alfa
#SBATCH --output=qiime-alfa.txt
#SBATCH --partition=dribe
#SBATCH --ntasks=1
#SBATCH --time=01:00:00

# cargar modulos necesarios
module load miniconda/qiime2-2024.2 

qiime diversity core-metrics-phylogenetic --i-phylogeny rooted-tree.qza --i-table table.qza --p-sampling-depth 1103 --m-metadata-file sample-metadata.tsv --output-dir diversity-core-metrics-phylogenetic
===========================================================EJEMPLO=========================================================================================================================================
#se obtiene una carpeta llena de archivos .qza y otros .qzv 
#los visualizables se ven en emperorpor medio de qiime2view
#despues de calcular las metricas de diversidad, lo siguiente es relacionar esa diversidad con la informacion de las muestras, por esto es necesario tener metadatos
#en este caso, primero se comparan las asociaciones entre las columnas de metadatos categÛricos y los datos de diversidad alfa. Lo haremos aquÌ para la Diversidad FilogenÈtica de la Fe (una medida de la riqueza de la comunidad) y las mÈtricas de uniformidad
===========================================================EJEMPLO=========================================================================================================================================
#!/bin/bash
#SBATCH --job-name=qiime-alfgroup
#SBATCH --output=qiime-alfagroup.txt
#SBATCH --partition=dribe
#SBATCH --ntasks=1
#SBATCH --time=01:00:00

# cargar modulos necesarios
module load miniconda/qiime2-2024.2 

qiime diversity alpha-group-significance --i-alpha-diversity diversity-core-metrics-phylogenetic/faith_pd_vector.qza --m-metadata-file sample-metadata.tsv --o-visualization faith-pd-group-significance.qzv

qiime diversity alpha-group-significance --i-alpha-diversity diversity-core-metrics-phylogenetic/evenness_vector.qza --m-metadata-file sample-metadata.tsv --o-visualization evenness-group-significance.qzv
===========================================================EJEMPLO=========================================================================================================================================
#en este conjunto de datos, ninguna columna de metadatos de muestra continua (p. ej., dias desde el comienzo del experimento) est· correlacionada con la diversidad alfa, por lo que no analizaremos estas asociaciones
#Si le interesa realizar estas pruebas (para este conjunto de datos o para otros), puede usar el qiime diversity alpha-correlation 

#PERMANOVA DE DIVERSIDAD BETA 
#analiza la composiciÛn de la muestra en el contexto de metadatos categÛricos
#se probara si las distancias entre muestras dentro de un grupo, como muestras del mismo sitio del cuerpo (p. ej., intestino), son m·s similares entre sÌ que con las muestras de los otros grupos (p. ej., lengua, palma izquierda y palma derecha)
#Si llama a este comando con el --p-pairwise, tambiÈn realizar· pruebas por pares que le permitir·n determinar quÈ pares especÌficos de grupos (p. ej., lengua e intestino) difieren entre sÌ, si los hay
#Este comando puede ser lento de ejecutar, especialmente al pasar --p-pairwise, ya que se basa en pruebas de permutaciÛn. Entonces, a diferencia de los comandos anteriores, lo ejecutaremos beta-group-significanceen columnas especÌficas de metadatos que nos interesa explorar, en lugar de todas las columnas de metadatos a las que es aplicable. 
#AquÌ aplicaremos esto a nuestras distancias UniFrac no ponderadas, utilizando dos columnas de metadatos de muestra
===========================================================EJEMPLO=========================================================================================================================================
#!/bin/bash
#SBATCH --job-name=qiime-beta-permanova
#SBATCH --output=qiime-beta-permanova.txt
#SBATCH --partition=kura
#SBATCH --ntasks=1
#SBATCH --time=00:40:00
  . /opt/Modules/3.2.10/init/sh

# cargar qiime
module load miniconda/qiime2-2024.2
#An·lisis de PERMANOVA a las distancias UniFrac no ponderadas entre sitio del cuerpo y grupo 
qiime diversity beta-group-significance --i-distance-matrix diversity-core-metrics-phylogenetic/unweighted_unifrac_distance_matrix.qza --m-metadata-file sample-metadata.tsv --m-metadata-column body-site --p-pairwise --o-visualization unweighted-unifrac-body-site-group-significance.qzv

#An·lisis de PERMANOVA a las distancias UniFrac no ponderadas entre sitio del cuerpo y sujeto 
qiime diversity beta-group-significance --i-distance-matrix diversity-core-metrics-phylogenetic/unweighted_unifrac_distance_matrix.qza --m-metadata-file sample-metadata.tsv --m-metadata-column subject --p-pairwise --o-visualization unweighted-unifrac-subject-group-significance.qzv
===========================================================EJEMPLO=========================================================================================================================================
#nuevamente, ninguno de los metadatos de muestra continua que tenemos para este conjunto de datos est· correlacionado con la composiciÛn de la muestra, por lo que no analizaremos estas asociaciones
#si le interesa realizar estas pruebas, puede usar los comandos ` qiime metadata distance-matrix en combinaciÛn con` qiime diversity mantel y qiime diversity bioenv

#ademas, se pueden generar gr·ficos de Emperor (PCoA) para ver cÛmo se organizan las comunidades microbianas entre muestra, con el par·metro --p-custom-axes se puede agregar informaciÛn extra, como el tiempo, para observar cÛmo cambian las comunidades durante el experimento
#se generan gr·ficos para UniFrac y Bray-Curtis no ponderados, mostrando los principales ejes y la evoluciÛn temporal
===========================================================EJEMPLO=========================================================================================================================================
#!/bin/bash
#SBATCH --job-name=qiime-beta-perm2
#SBATCH --output=qiime-beta-perma2.txt
#SBATCH --partition=kura
#SBATCH --ntasks=1
#SBATCH --time=00:40:00
  . /opt/Modules/3.2.10/init/sh

# cargar qiime
module load miniconda/qiime2-2024.2

qiime emperor plot --i-pcoa diversity-core-metrics-phylogenetic/unweighted_unifrac_pcoa_results.qza --m-metadata-file sample-metadata.tsv --p-custom-axes days-since-experiment-start --o-visualization unweighted-unifrac-emperor-days-since-experiment-start.qzv

qiime emperor plot --i-pcoa diversity-core-metrics-phylogenetic/bray_curtis_pcoa_results.qza --m-metadata-file sample-metadata.tsv --p-custom-axes days-since-experiment-start --o-visualization bray-curtis-emperor-days-since-experiment-start.qzv
===========================================================EJEMPLO=========================================================================================================================================
#ALFA RAREFRACION
#es un an·lisis que se hace para evaluar si la diversidad dentro de cada muestra (diversidad alfa) est· bien estimada seg˙n la cantidad de secuencias que tenemos
#se graficar·n los valores promedio de diversidad para cada muestra a cada profundidad de muestreo par, y las muestras se pueden agrupar seg˙n los metadatos en la visualizaciÛn
===========================================================EJEMPLO=========================================================================================================================================
#!/bin/bash
#SBATCH --job-name=qiime-alpha-rarefaction
#SBATCH --output=qiime-alpha-rarefaction.txt
#SBATCH --partition=dribe
#SBATCH --ntasks=1
#SBATCH --time=03:00:00

# cargar qiime
module load miniconda/qiime2-2024.2
qiime diversity alpha-rarefaction --i-table table.qza --i-phylogeny rooted-tree.qza --p-max-depth 4000 --m-metadata-file sample-metadata.tsv --o-visualization alpha-rarefaction.qzv
===========================================================EJEMPLO=========================================================================================================================================

#CLASIFICACION TAXONOMICA 
#por medio de la asignacion taxonomica se puede ver composiciÛn taxonÛmica de las muestras y es posible relacionar con sus metadatos
#existen muchos clasificadores preentrenados, por ejemplo greengenes (el que se usara en el ejemplo) o la base de datos Silva
#la decision de cual usar dependera de cual es mas conveniente para sus datos 
#de igual manera puede entrenar un clasificador por su cuenta si ninguno se adapta bien a sus datos
===========================================================EJEMPLO=========================================================================================================================================
#descargar base de datos greengenes
wget -O 'gg-13-8-99-515-806-nb-classifier.qza' \
  'https://moving-pictures-tutorial.readthedocs.io/en/latest/data/moving-pictures/gg-13-8-99-515-806-nb-classifier.qza'
 
#!/bin/bash
#SBATCH --job-name=qiime-taxonomy
#SBATCH --output=qiime-taxonomy.txt
#SBATCH --partition=kura
#SBATCH --ntasks=1
#SBATCH --time=00:40:00

  . /opt/Modules/3.2.10/init/sh

# cargar qiime
module load miniconda/qiime2-2024.2

qiime feature-classifier classify-sklearn --i-classifier gg-13-8-99-515-806-nb-classifier.qza --i-reads rep-seqs.qza --o-classification taxonomy.qza

qiime metadata tabulate --m-input-file taxonomy.qza --o-visualization taxonomy.qzv

===========================================================EJEMPLO=========================================================================================================================================
#TAXONOMIA CON SILVA 
#en este link puede encontrar diferentes clasificadores de Silva: https://www.arb-silva.de/arb-files
En este caso se va a usar silva-138-99-nb-classifier.qza

===========================================================EJEMPLO=========================================================================================================================================
#descargar base de datos SILVA

#!/bin/bash
#SBATCH --job-name=qiime-taxonomysilva
#SBATCH --output=qiime-taxonomysilva.txt
#SBATCH --partition=kura
#SBATCH --ntasks=1
#SBATCH --time=00:40:00

  . /opt/Modules/3.2.10/init/sh

# cargar qiime
module load miniconda/qiime2-2024.2

qiime feature-classifier classify-sklearn --i-classifier silva-138-99-nb-classifier.qza --i-reads rep-seqs.qza --o-classification taxonomy.qza

qiime metadata tabulate --m-input-file taxonomy.qza --o-visualization taxonomy.qzv
===========================================================EJEMPLO=========================================================================================================================================

#GRAFICA DE BARRAS EN TAXONOMIA 
===========================================================EJEMPLO=========================================================================================================================================
#!/bin/bash
#SBATCH --job-name=qiime-taxo-bar
#SBATCH --output=qiime-taxo-bar.txt
#SBATCH --partition=kura
#SBATCH --ntasks=1
#SBATCH --time=01:00:00

  . /opt/Modules/3.2.10/init/sh
  
#cargar qiime
module load miniconda/qiime2-2024.2

qiime taxa barplot --i-table table.qza --i-taxonomy taxonomy.qza --m-metadata-file sample-metadata.tsv --o-visualization taxa-bar-plots.qzv
===========================================================EJEMPLO=========================================================================================================================================

#de igual manera puede hacer pruebas de adonis, pruebas ANCOM-BC y muchas otras mas, esto dependera que la informacion que desee obtener a partir de sus datos
