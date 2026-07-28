install.packages("ggplot2")

install.packages("BiocManager")
BiocManager::install(c("treeio","ggtree"))
BiocManager::install("ggtree", update = T )
library(BiocManager)

library(ggtree)
library(treeio)
library(ggplot2)
library(dplyr)

tree <- read.iqtree("MA12_single_copy_tree.treefile")

p <- ggtree(tree) +
  geom_tiplab(size = 4) +
  geom_text2(
    aes(subset = !isTip, label = label),
    hjust = -0.3,
    size = 3
  ) +
  theme_tree2()

p

ggsave(
  "MA12_phylogeny.pdf",
  p,
  width = 10,
  height = 6
)



library(ggtree)
library(ggplot2)

tree <- read.iqtree("MA12_single_copy_tree.treefile")

p <- ggtree(tree)

p <- p +
  geom_tiplab(size = 4)

p$data$color_group <- ifelse(
  p$data$label == "MA12",
  "MA12",
  "Other"
)

p +
  geom_tippoint(
    aes(color = color_group),
    size = 4
  ) +
  scale_color_manual(
    values = c(
      "MA12" = "red",
      "Other" = "black"
    )
  )

p <- ggtree(tree) +
  geom_tiplab(
    size = 4,
    align = TRUE,
    linesize = 0.3
  ) +
  geom_text2(
    aes(
      subset = !isTip,
      label = label
    ),
    hjust = -0.2,
    size = 3
  ) +
  theme_tree2()

print(p)


##corregido 
library(treeio)
library(ape)

tree <- read.iqtree("MA12_single_copy_tree.treefile")

phy <- as.phylo(tree)

phy$tip.label


tree$tip.label <- c(
  "MA12",
  "Fusarium acutatum",
  "Hypomyces rosellus",
  "Neocosmospora mangrovei",
  "Purpureocillium lilacinum",
  "Parasarocladium wereldwijsianum",
  "Trichoderma harzianum"
)

p <- ggtree(tree) +
  geom_tiplab(
    size = 4,
    align = TRUE,
    fontface = "italic"
  ) +
  xlim(0, max(ggtree(tree)$data$x) * 1.8)

print(p)


### final ###

library(ggtree)
library(treeio)
library(ggplot2)
library(stringr)

tree <- read.iqtree("MA12_single_copy_tree.treefile")
phy <- as.phylo(tree)

phy$tip.label <- gsub("_", " ", phy$tip.label)
phy$tip.label <- gsub("trichoderma harziamum", "Trichoderma harzianum", phy$tip.label)
phy$tip.label <- gsub("fusarium acutatum", "Fusarium acutatum", phy$tip.label)
phy$tip.label <- gsub("hypomyces rosellus", "Hypomyces rosellus", phy$tip.label)
phy$tip.label <- gsub("neocosmospora mangrovei", "Neocosmospora mangrovei", phy$tip.label)
phy$tip.label <- gsub("purpureocillium lilacinum", "Purpureocillium lilacinum", phy$tip.label)
phy$tip.label <- gsub("MA12", "MA12", phy$tip.label)
phy$tip.label <- gsub("pwerel", "P. werel", phy$tip.label)

p <- ggtree(phy)

p$data$bootstrap <- sapply(
  p$data$label,
  function(x) {
    if (is.na(x) || x == "") return(NA)
    if (grepl("/", x)) return(str_split(x, "/", simplify = TRUE)[2])
    return(x)
  }
)

p$data$ma12_group <- ifelse(p$data$label == "MA12", "MA12", "Other")
p$data$font_type <- ifelse(p$data$label == "MA12", "bold", "italic")

p_final <- p +
  geom_tiplab(
    aes(fontface = font_type),
    align = TRUE,
    linesize = 0.3,
    size = 4,
    offset = 0.02
  ) +
  geom_tippoint(
    aes(subset = label == "MA12"),
    size = 4
  ) +
  geom_text2(
    aes(
      subset = !isTip,
      label = bootstrap
    ),
    hjust = -0.25,
    size = 3
  ) +
  xlim(0, max(p$data$x) * 1.8) +
  theme_tree2()

print(p_final)

ggsave("MA12_phylogeny_bootstrap.png", p_final, width = 12, height = 7, dpi = 600)
ggsave("MA12_phylogeny_bootstrap.pdf", p_final, width = 12, height = 7)











options(device = "RStudioGD")

plot(1:10)

dev.cur()
