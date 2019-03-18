library(dplyr)
library(purrr)
library(lme4)

normdat <- readRDS("~/data/microarray.rds")
g <- normdat %>% distinct(gene) %>% pull

ngenes <- as.numeric(Sys.getenv("ngenes"))
njobs <- as.numeric(Sys.getenv("njobs"))
job <- as.numeric(Sys.getenv("job"))

print(paste(job,njobs,sep=";"))

if(njobs > 1){
  ind <- split(1:ngenes, cut(1:ngenes, njobs))[[job]]
} else {
  ind <- 1:ngenes
} 

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

# Save Results ----

saveRDS(metrics, paste0("~/microarray/data/env", job, ".rds"))


