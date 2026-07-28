# Software, databases, and principal parameters

| Analysis | Software | Recorded version | Principal parameters |
|---|---|---:|---|
| Genome assembly | SPAdes | 3.15.4 | `--careful`, `--cov-cutoff auto`, k-mers 89,95,97,101,107,117,127, 20 threads |
| Assembly statistics | BBMap `stats.sh` | 37.36 | Default statistics |
| Completeness | BUSCO | Not encoded in original module name | Genome mode; fungi_odb10, ascomycota_odb10, hypocreales_odb10; 8 CPUs |
| Functional annotation | EggNOG-mapper | 2.1.6 | Protein input; DIAMOND; query coverage 50; E-value 1e-5; ortholog reporting; all GO evidence; 10 CPUs |
| rRNA prediction | barrnap | Original comment reports 0.9 | Eukaryotic mode; 10 threads; sequence output enabled |
| tRNA prediction | tRNAscan-SE | 2.0.5 | Eukaryotic and infernal modes (`-E -I`) |
| Orthology | OrthoFinder | Not encoded in original module name | MSA gene trees; FastTree; 30 threads in standardized script |
| Phylogeny | IQ-TREE | 3.0.1 | ModelFinder Plus (`-m MFP`); 1,000 UFBoot; 1,000 SH-aLRT; automatic threads, maximum 32 |
| ANI | ANIcalculator | 1.0.0 | Pairwise directional ANI and alignment fractions |
| Genome alignment | MUMmer | 4.0.0beta2 | `nucmer`; `delta-filter -1`; `show-coords -rcl`; `mummerplot --filter --layout` |
| Functional visualization | R / ggplot2 | Record before release | Custom scripts |
| Tree visualization | R / ggtree / treeio | Record before release | Tip labels, branch support, MA12 highlighting |
| BGC prediction | antiSMASH web server | **Add exact version** | **Add selected web options and submission date** |

## Required archival details

Before creating the version cited in the paper, replace all “not encoded” or “add” fields with exact values obtained from execution logs, module metadata, web result pages, or package session information.
