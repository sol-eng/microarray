library(dplyr)
library(ggplot2)
library(purrr)
library(tidyr)
library(DT)
library(rstudioapi)

# Load data

normdat <- readRDS("microarray.rds")
g <- normdat %>% distinct(gene) %>% pull

jobs <- 3
n <- length(g)
n <- 300 # for faster running jobs

inds <- split(1:n, cut(1:n, jobs))
envs <- paste0("u", 1:jobs)

# Run Jobs

for(i in 1:jobs){
  ind <- inds[[i]]
  jobRunScript("testmicro.R", 
               workingDir = ".", 
               importEnv = TRUE, 
               exportEnv = envs[i])
}

# Collect results

pvals <- mget(paste0(envs)) %>%
  map("out") %>%
  map(bind_rows) %>%
  bind_rows %>%
  drop_na %>%
  mutate(n=n()) %>%
  filter(p.value < 0.05 / n) %>%
  arrange(z.ratio)

# Print results

pvals %>%
  select(contrast, estimate, SE, p.value) %>% 
  mutate_if(is.numeric, prettyNum, digits = 4, scientific = TRUE) %>%
  datatable(pvals)

# Plot results

pvals %>%
  mutate(log10 = log10(p.value)) %>%
  ggplot(aes(contrast, log10, fill = contrast)) + 
  geom_boxplot() +
  ggtitle("Distribution of log10 p-values")

