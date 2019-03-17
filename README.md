# Microarray

*Use this dataset to demonstrate parallel processing with the Launcher and Jobs features*

![](data/microarray.png)


## Getting started

**We will compute approximately 7,000 models in all, one for each gene**. Use the `simple_sequential.R` to build and assess the models. For a full discussion see the `reports` folder.

*simple_sequential.R*

```{r}
library(dplyr)
library(purrr)
library(lme4)
library(DT)

normdat <- readRDS("microarray.rds")

g <- normdat %>% distinct(gene) %>% pull
n <- length(g)
n <- 300 # for faster running jobs

# Fit Model ----

models <- list()
for(i in g[1:n]){
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

# Summarize ----

datatable(metrics)
```

## Using jobs

**Use the jobs feature to speed things up**. You can fit the models with multiple [Jobs](https://blog.rstudio.com/2019/03/14/rstudio-1-2-jobs/) in RStudio v1.2. See `simple_runjobs.R` and `simple_job.R` for an example of running indepedent jobs simultaneously. Notice the jobs are organized into groups. The `inds` and `envs` list objects are used for the indices and environments of each group.

*simple_runjobs.R*

```{r}
library(dplyr)
library(purrr)
library(lme4)
library(DT)
library(rstudioapi)

normdat <- readRDS("data/microarray.rds")

g <- normdat %>% distinct(gene) %>% pull
n <- length(g)
n <- 300 # for faster running jobs

# Run Jobs ----

jobs <- 3
inds <- split(1:n, cut(1:n, jobs))
envs <- paste0("u", 1:jobs)

for(i in 1:jobs){
  ind <- inds[[i]]
  jobRunScript("simple_job.R", 
               workingDir = ".", 
               importEnv = TRUE, 
               exportEnv = envs[i])
}

# Collect Results ----

metrics <- mget(paste0(envs)) %>%
  map("metrics") %>%
  bind_rows

# Summarize ----

datatable(metrics)
```

*simple_job.R*

```{r}
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
```

## Background

DNA microarrays are used are used to measure the expression levels of large numbers of genes simultaneously. These experimental data come from [yeast genome microarrays](https://www.pnas.org/content/pnas/97/7/3364.full.pdf) and can be [downloaded here](http://genome-www.stanford.edu/swisnf/). Our models borrow from the methodology offered in [Assessing Gene Significance from cDNA Microarray Expression Data via Mixed Models](https://pdfs.semanticscholar.org/608a/4dc9f2464942030cb860a84ddcb215691188.pdf?_ga=2.38984291.1957266298.1552698540-1237907384.1552698540).

