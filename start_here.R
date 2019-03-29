setwd("~/microarray/")

# Run interactive session - blocks session
source("run_interactive.R")

# Run local jobs - depends on current session
source("run_localjobs.R")

# Run launcher jobs - runs independently
source("run_launcherjobs.R")

# Collect and summarize results
map_df(1:njobs, ~ readRDS(paste0("data/env", .x, ".rds"))) %>%
  arrange(logLik) %>%
  datatable(metrics)
