library(dplyr)
library(purrr)
library(lme4)
library(DT)

normdat <- readRDS("~/microarray/data/microarray.rds")

g <- normdat %>% distinct(gene) %>% pull
n <- length(g)
n <- 900 # for shorter running jobs

# Fit Model ----

models <- list()
for(i in g[1:n]){
  tryCatch({
    print(i)
    models[[i]] <- lmer(resid ~ strain + (1|spot:array), filter(normdat, gene == i), REML = FALSE)},
    error=function(e) cat("ERROR :",conditionMessage(e), "\n"))
}
