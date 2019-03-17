library(dplyr)
library(lme4)
library(emmeans)
library(purrr)

# Fit Model ----

models <- map(g[ind], ~ tryCatch({
  print(.x)
  lmer(resid ~ strain + (1|spot:array), filter(normdat, gene == .x))
  }, error=function(e) cat("ERROR :",conditionMessage(e), "\n"))
  )

# Pairwise Comparisons ----

pairs <- map(models, ~ tryCatch({
  emmeans(.x, pairwise ~ strain)$contrasts %>%
               as_tibble %>%
               mutate(contrast = as.character(contrast))
  }, error=function(e) cat("ERROR :",conditionMessage(e), "\n"))
  )

# Collect Results ----

pvals <- tryCatch({
  bind_rows(pairs)
}, error=function(e) cat("ERROR :",conditionMessage(e), "\n")
)
