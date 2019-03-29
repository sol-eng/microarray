##############################################
# Run interactive (i.e. blocking) session
##############################################

# Run
source("run_interactive.R")

# Collect results
map(models, ~ data.frame(logLik = logLik(.x), BIC = BIC(.x), AIC = AIC(.x))) %>%
  bind_rows(.id = "gene") %>%
  mutate_if(is.numeric, round, 4) %>%
  arrange(logLik) %>%
  datatable

##############################################
# Run local jobs
##############################################

# Run
source("run_localjobs.R")

# Collect results
mget(paste0(envs)) %>%
  map("metrics") %>%
  bind_rows %>%
  arrange(logLik) %>%
  datatable

##############################################
# Run launcher jobs
##############################################

# Run
source("run_launcherjobs.R")

# Collect results
map_df(1:njobs, ~ readRDS(paste0("data/env", .x, ".rds"))) %>%
  arrange(logLik) %>%
  datatable
