library(tidyverse)
library(lme4)
library(emmeans)

# Microarray Model ----

out <- list()
for (i in g[ind]) {
  d <- filter(normdat, gene == i)
  k <- tryCatch({
    print(i)
    out[[i]] <- lmer(resid ~ strain + (1|spot:array), d) %>%
      emmeans(pairwise ~ strain) %>%
      .$contrasts %>%
      as_tibble() %>%
      mutate(contrast = as.character(contrast))
  }, error=function(e) cat("ERROR :",conditionMessage(e), "\n"))
}
