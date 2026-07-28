# Software and resources

| Component | Version | Purpose | Principal parameters |
|---|---:|---|---|
| Trim Galore | 0.4.3 | Adapter and quality trimming | paired; Q20; minimum length 20 bp; `--clip_R1 10`; `--clip_R2 5` |
| FastQC | 0.11.9 | Post-trimming read QC | Standard report |
| SPAdes | 3.11.0 | De novo assembly | k = 89, 95, 97, 101, 107, 117, 127 |
| MeDuSa | 1.6 | Reference-guided scaffolding | Reference GCA_036250105.1 |
| BBMap | 37.36 | Assembly statistics | N50, L50, GC and related metrics |
| BUSCO | 5.4.3 | Assembly completeness | fungi_odb10, ascomycota_odb10, hypocreales_odb10 |
| AUGUSTUS | 3.3 | Structural annotation | *Fusarium graminearum* species model |
| OrthoFinder | 2.5.2 | Orthology and single-copy ortholog inference | Predicted proteomes |
| IQ-TREE | 3.0.1 | Maximum-likelihood phylogeny | MFP; selected Q.INSECT+F+I+R4; 1000 UFBoot; 1000 SH-aLRT |
| gANI | 1.0.0 | Average nucleotide identity | Default parameters |
| MUMmer | 4.0.0beta1 | Whole-genome alignment and synteny | See original script |
| GGDC | 3.0 web server | dDDH estimation | Formula 2 |
| EggNOG-mapper | 2.1.6 | Functional annotation | See original script |
| antiSMASH | 8.0 web server | BGC prediction | Annotated genome input |
| R | 4.5.1 | Visualization | ggplot2, ggtree, treeio and related packages |
