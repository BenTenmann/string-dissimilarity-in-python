library(dplyr)
library(ggplot2)
library(purrr)
library(stringr)

WORKING_DIR <- Sys.getenv("WORKING_DIR")
FIGURE_DIR <- Sys.getenv("FIGURE_DIR")
setwd(WORKING_DIR)

save_figure <- function(figure, prefix) {
  ggsave(paste(FIGURE_DIR,
               paste(paste(prefix,
                           format(Sys.time(), "%Y-%m-%d-%X"),
                           sep = "-"),
                     "png",
                     sep = "."),
               sep = "/"),
         plot = figure,
         height = 10,
         width = 12,
         dpi = 400)
}

list.files(
  path = "output",
  pattern = "^[a-z]+\\.csv$",
  full.names = TRUE,
) %>%
  map(~ {
    read.csv(.x) %>%
      mutate(metric = str_match(.x, ".*/([a-z]+)\\.csv")[,2])
  }) %>%
  bind_rows() %>%
  ggplot(aes(x = t0, y = t1, color = gene))+
  geom_point()+
  labs(
    title = expression("CDR3"~beta~italic(t)-SNE~"embeddings"),
    x = expression(italic(t)-SNE[1]),
    y = expression(italic(t)-SNE[2])
  )+
  theme(legend.position = "none")+
  theme_bw()+
  facet_wrap(. ~ metric, scales = "free") -> f
save_figure(f, "sequence-embeddings")

read.csv("output/corr_metrics.csv") %>%
  ggplot(aes(x = from, y = to, fill = spearman_r))+
  geom_tile()+
  geom_text(aes(label = round(spearman_r, 3)))+
  theme_bw() -> f
save_figure(f, "metric-corr")

read.csv(
  "output/silhouette_score.csv",
  header = FALSE,
  col.names = c("metric", "score")
) %>%
  ggplot(aes(x = reorder(metric, -score), y = score))+
  geom_bar(stat = "identity", fill = "steelblue")+
  labs(
    title = "Mean Silhouette score per distance function",
    y = "Silhouette score",
    x = ""
  )+
  coord_flip()+
  theme_bw() -> f
save_figure(f, "metric-score")
