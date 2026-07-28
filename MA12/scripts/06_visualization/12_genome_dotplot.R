#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
args <- commandArgs(trailingOnly = TRUE)
input <- if (length(args) >= 1) args[1] else "results/comparative_genomics/mummer/were_ma12.fplot"
output <- if (length(args) >= 2) args[2] else "results/figures/genome_dotplot.png"
dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)
dat <- read.table(input, header = FALSE, skip = 2)
colnames(dat) <- c("ref_start", "query_start", "similarity")
dat <- dat[dat$ref_start > 0 & dat$query_start > 0, ]
p <- ggplot(dat, aes(ref_start / 1e6, query_start / 1e6, color = similarity)) +
  geom_point(size = 0.8, alpha = 0.9) +
  scale_color_gradient2(low = "red", mid = "cyan", high = "blue", midpoint = 78,
                        name = "% similarity") +
  labs(x = expression(italic(P.~wereldwijsianum)~"(Mb)"), y = "MA12 (Mb)",
       subtitle = paste(nrow(dat), "alignments; mean similarity:", round(mean(dat$similarity), 1), "%")) +
  coord_fixed() + theme_minimal()
ggsave(output, p, width = 8, height = 7, dpi = 600)
