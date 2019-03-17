# Microarray

DNA microarrays are used to measure the expression levels of large numbers of genes simultaneously. These experimental data come from [yeast genome microarrays](https://www.pnas.org/content/pnas/97/7/3364.full.pdf) and can be downloaded [here](http://genome-www.stanford.edu/swisnf/). In this analysis we use a two stage mixed model approach as described in [here](https://pdfs.semanticscholar.org/608a/4dc9f2464942030cb860a84ddcb215691188.pdf?_ga=2.38984291.1957266298.1552698540-1237907384.1552698540). In the first stage, a mixed model normalizes the data. In the second stage, we build independent models for each gene. **We compute approximately 7,000 models in all, one for each gene**.

### Getting started

Use the code below to build the models and assess the significant interactions. For a full discussion see `full_demo.Rmd`.

```{r}
library(dplyr)
library(lme4)
library(purrr)
library(emmeans)

dat <- readRDS("microarray.rds")

g <- dat %>% distinct(gene) %>% pull

models <- map(g, ~ try(lmer(resid ~ strain + (1|spot:array), filter(dat, gene == .x))))

pairs <- map(models, ~ emmeans(.x, pairwise ~ strain)$contrasts %>%
               as_tibble %>%
               mutate(contrast = as.character(contrast)))

pvals <- bind_rows(pairs)
```

### Jobs

Because these models are independent, you can also parallelize them with the [`Jobs` feature](https://blog.rstudio.com/2019/03/14/rstudio-1-2-jobs/) in RStudio v1.2. See `full_demo.Rmd` for an example.