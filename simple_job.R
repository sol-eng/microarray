library(dplyr)
library(purrr)
library(lme4)

# Fit Model ----

models <- list()
for(i in g[ind]){
  tryCatch({
    print(i)
    models[[i]] <- lmer(resid ~ strain + (1|spot:array), filter(normdat, gene == i), REML = FALSE)},
    error=function(e) cat("ERROR :",conditionMessage(e), "\n"))
}

# Collect Results ----

metrics <- map(models, ~ data.frame(logLik = logLik(.x), BIC = BIC(.x), AIC = AIC(.x))) %>%
  bind_rows(.id = "gene") %>%
  mutate_if(is.numeric, round, 4) %>%
  arrange(logLik)

