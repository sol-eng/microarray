library(dplyr)
library(lme4)
library(purrr)
library(emmeans)

dat <- readRDS("microarray.rds")

g <- dat %>% distinct(gene) %>% pull

models <- map(g, ~ try(lmer(resid ~ strain + (1|spot:array), filter(dat, gene == .x))))

pairs <- map(models, ~ emmeans(.x, pairwise ~ strain)$contrasts %>%
               as_tibble %>%
               mutate(contrast = as.character(contrast)))

pvals <- bind_rows(pairs)

