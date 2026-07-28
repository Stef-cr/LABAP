#!/usr/bin/env Rscript
suppressPackageStartupMessages({library(ggtree); library(treeio); library(ggplot2); library(stringr)})
args <- commandArgs(trailingOnly = TRUE)
treefile <- if (length(args) >= 1) args[1] else "results/phylogenomics/iqtree/MA12_single_copy_tree.treefile"
outprefix <- if (length(args) >= 2) args[2] else "results/figures/MA12_phylogeny"
dir.create(dirname(outprefix), recursive = TRUE, showWarnings = FALSE)
tree <- read.iqtree(treefile)
phy <- as.phylo(tree)
phy$tip.label <- gsub("_", " ", phy$tip.label)
p <- ggtree(phy)
p$data$bootstrap <- vapply(p$data$label, function(x) {
  if (is.na(x) || x == "") return(NA_character_)
  if (grepl("/", x)) return(str_split(x, "/", simplify = TRUE)[2])
  x
}, character(1))
p$data$font_type <- ifelse(p$data$label == "MA12", "bold", "italic")
final <- p +
  geom_tiplab(aes(fontface = font_type), align = TRUE, linesize = 0.3, size = 4, offset = 0.02) +
  geom_tippoint(aes(subset = label == "MA12"), size = 4) +
  geom_text2(aes(subset = !isTip, label = bootstrap), hjust = -0.25, size = 3) +
  xlim(0, max(p$data$x) * 1.8) + theme_tree2()
ggsave(paste0(outprefix, ".png"), final, width = 12, height = 7, dpi = 600)
ggsave(paste0(outprefix, ".pdf"), final, width = 12, height = 7)
