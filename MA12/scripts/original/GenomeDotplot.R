# DOTPLOT MUMMER EN R - COMPLETO
library(ggplot2)

# 1. LEER DATOS
data <- read.table("out.fplot", header=FALSE, skip=2)  # skip=2 salta comentarios
colnames(data) <- c("ref_start", "query_start", "similarity")

# 2. FILTRAR CEROS + PLOT
plot_data <- data[data$ref_start > 0 & data$query_start > 0, ]
plot_data$sim <- plot_data$similarity

# 3. DOTPLOT COLORIDO (Mb)
dot <- ggplot(plot_data, aes(x = ref_start/1e6, y = query_start/1e6, color = sim)) +
  geom_point(size = 0.8, alpha = 0.9) +
  scale_color_gradient2(low = "red", mid = "cyan", high = "blue", 
                        midpoint = 78, name = "% Similarity") +
  theme_minimal() +
  labs(
    x = "P. wereldwijsianum - Mb",
    y = "MA12 - Mb") +
  coord_fixed()

ggsave(filename = "genome_dotplot.png", plot = dot, dpi = 300)

subtitle = paste(nrow(plot_data), "alineamientos | Media:", round(mean(plot_data$sim), 1), "%")
