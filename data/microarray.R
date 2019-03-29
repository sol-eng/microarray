library(dplyr)
library(purrr)
library(readr)
library(tibble)
library(lme4)

files <- paste0("http://genome-www.stanford.edu/swisnf/",
                c("snf2ypda.txt", "snf2ypdc.txt", "snf2ypdd.txt",
                  "snf2mina.txt", "snf2minc.txt", "snf2mind.txt",
                  "swi1ypda.txt", "swi1ypdc.txt", "swi1ypdd.txt",
                  "swi1mina.txt", "swi1minc.txt", "swi1mind.txt")
)

rawdat <- files %>%
  map(read_delim, delim = "\t") %>%
  map(rowid_to_column, var = "spot") %>%
  bind_rows(.id = "array") %>%
  filter(FLAG == 0) %>%
  mutate(name = ifelse(is.na(NAME), TYPE, NAME),
         gene = ifelse(is.na(GENE), NAME, GENE),
         type = TYPE,
         spot = as.character(spot))

treatment <- rawdat %>%
  mutate(diff = CH1I - CH1B,
         strain = case_when(array <=3 ~ "snf2rich",
                            array <=6 ~ "snf2mini",
                            array <=9 ~ "swi1rich",
                            array <=12 ~ "swi1mini"))

control <- rawdat %>%
  mutate(diff = CH2I - CH2B,
         strain = "wildtype")

moddat <- bind_rows(treatment, control) %>%
  filter(diff > 0) %>%
  mutate(logi = log2(diff)) %>%
  select(array, gene, name, spot, strain, logi) %>%
  arrange(gene, array, spot, strain)

m1 <- lmer(logi ~ strain + (1|array/strain), moddat)

normdat <- moddat %>%
  mutate(resid = resid(m1)) %>%
  filter(!gene %in% c("EMPTY", "NORF", NA))

saveRDS(normdat, "data/microarray.rds")
