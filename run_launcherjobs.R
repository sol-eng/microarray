library(dplyr)
library(purrr)
library(DT)

source("~/microarray/R/launcher_job.R")

njobs <- 3
ngenes <- readRDS("~/data/microarray.rds") %>% distinct(gene) %>% tally %>% pull
ngenes <- 900 # for shorter running jobs

env <- function(file, ngenes, njobs, job){
  paste(sep = ";",
    paste0("Sys.setenv('ngenes' = ", ngenes,")"),
    paste0("Sys.setenv('njobs' = ", njobs,")"),
    paste0("Sys.setenv('job' = ", job,")"),
    paste0("source('", file, "')")
  )
}

# Run Jobs ----

map(1:njobs, ~ launcher_job(
  env(
    file = "~/microarray/launcherjob.R",
    ngenes = ngenes,
    njobs = njobs,
    job = .x
    )
))


# Collect Results ----

outfile <- function(x) paste0("~/microarray/data/env", x, ".rds")
metrics <- map_df(1:njobs, ~ readRDS(outfile(.x))) %>%
  arrange(logLik)

# Summarize ----

datatable(metrics)
