# Mapping between manuscript methods and repository content

| Manuscript method | Repository component | Reproducibility status |
|---|---|---|
| Sample collection, isolation and culture | `workflow/workflow.md` | Documented; wet-lab procedure |
| DNA extraction and sequencing | `workflow/workflow.md` | Documented; outsourced sequencing |
| Trim Galore preprocessing | `workflow/workflow.md` | Exact parameters documented |
| FastQC | `workflow/workflow.md` | Version and stage documented |
| SPAdes assembly | Original assembly SLURM script and workflow | Version and k-mers documented |
| MeDuSa scaffolding | Original assembly workflow/script where present | Reference accession documented |
| BBMap statistics | `scripts/original/` and workflow | Original script retained |
| BUSCO | `scripts/original/` and workflow | Databases and version documented |
| AUGUSTUS | `scripts/original/` and workflow | Training model documented |
| OrthoFinder | `scripts/original/ortho.slurm` | Version and downstream use documented |
| Ortholog concatenation | `scripts/concatenate_alignments_species.py` | Executable local script |
| IQ-TREE | `scripts/original/iqtree*.slurm` | Model-selection strategy and support documented |
| gANI | `scripts/original/ani.slurm` | Original script retained |
| GGDC dDDH | `workflow/workflow.md` | Web analysis; Formula 2 documented |
| MUMmer synteny | `scripts/original/structural.slurm`, dotplot scripts | Original scripts retained |
| EggNOG-mapper | `scripts/original/eggnog_were.slurm` | Original script retained |
| CAZyme extraction | Derived from EggNOG annotations | Explain extraction rules in associated analysis outputs |
| antiSMASH | `docs/antismash_web.md` | Web analysis; version documented |
| R visualization | `GenomeDotplot.R`, `arbol2.R` | Scripts retained |
