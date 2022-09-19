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
  ggplot(aes(x = mds_1, y = mds_2, color = gene))+
  geom_point()+
  labs(
    title = expression("CDR3"~beta~"multi-dimensional scaling"),
    x = expression(MDS[1]),
    y = expression(MDS[2])
  )+
  theme(legend.position = "none")+
  theme_bw()+
  facet_wrap(. ~ metric, scales = "free") -> f
save_figure(f, "sequence-embeddings")

read.csv("output/diff_metrics.csv") %>%
  ggplot(aes(x = mds_1, y = mds_2, color = metric))+
  geom_point(size = 5)+
  labs(
    x = expression(MDS[1]),
    y = expression(MDS[2])
  )+
  theme_bw() -> f
save_figure(f, "metric-differences")
