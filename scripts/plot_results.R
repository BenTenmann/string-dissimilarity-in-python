library(tidyverse)

WORKING_DIR <- Sys.getenv("WORKING_DIR")
FIGURE_DIR <- Sys.getenv("FIGURE_DIR")
setwd(WORKING_DIR)

list.files(
  path = "output",
  pattern = "*.csv",
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
  facet_wrap(. ~ metric, scales = "free")
ggsave(paste(FIGURE_DIR,
             paste(format(Sys.time(), "%Y-%m-%d-%X"), "png", sep = "."),
             sep = "/"),
       height = 7,
       width = 7,
       dpi = 400)
