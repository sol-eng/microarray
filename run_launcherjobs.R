library(dplyr)
library(purrr)
library(DT)

source("~/microarray/R/launcher_job.R")

njobs <- 3
ngenes <- readRDS("~/microarray/data/microarray.rds") %>% distinct(gene) %>% tally %>% pull
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
    file = "~/microarray/task_launcher.R",
    ngenes = ngenes,
    njobs = njobs,
    job = .x
    )
))

