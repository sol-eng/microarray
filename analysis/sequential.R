library(dplyr)
library(lme4)
library(emmeans)
library(purrr)

normdat <- readRDS("microarray.rds")

g <- normdat %>% distinct(gene) %>% pull

# Fit Model

models <- map(g, ~ try(lmer(resid ~ strain + (1|spot:array), filter(normdat, gene == .x))))

# Pairwise Comparisons

pairs <- map(models, ~ emmeans(.x, pairwise ~ strain)$contrasts %>%
               as_tibble %>%
               mutate(contrast = as.character(contrast)))

# Collect Results

pvals <- bind_rows(pairs)

