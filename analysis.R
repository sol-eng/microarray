library(dplyr)
library(lme4)
library(purrr)
library(emmeans)

normdat <- readRDS("microarray.rds")

g <- normdat %>% distinct(gene) %>% pull

models <- map(g, ~ try(lmer(resid ~ strain + (1|spot:array), filter(normdat, gene == .x))))

pairs <- map(models, ~ emmeans(.x, pairwise ~ strain)$contrasts %>%
               as_tibble %>%
               mutate(contrast = as.character(contrast)))

pvals <- bind_rows(pairs)

