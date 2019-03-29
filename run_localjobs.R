library(dplyr)
library(purrr)
library(lme4)
library(DT)
library(rstudioapi)

normdat <- readRDS("data/microarray.rds")

g <- normdat %>% distinct(gene) %>% pull
n <- length(g)
n <- 300 # for shorter running jobs

# Run Jobs ----

jobs <- 3
inds <- split(1:n, cut(1:n, jobs))
envs <- paste0("u", 1:jobs)

for(i in 1:jobs){
  ind <- inds[[i]]
  jobRunScript("task_local.R", 
               workingDir = ".", 
               importEnv = TRUE, 
               exportEnv = envs[i])
}
