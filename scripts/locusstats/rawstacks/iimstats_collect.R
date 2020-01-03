#!/usr/bin/env Rscript

################################################################################
##### SET-UP #####
################################################################################
## Command-line args:
options(warn = -1)
args <- commandArgs(trailingOnly = TRUE)

outfile_locusstats <- args[1]
ig_grep <- args[2]
og_grep <- args[3]
dir_fasta_og <- args[4]
dir_fasta_w1 <- args[5]
dir_fasta_w2 <- args[6]
dir_fasta_bw <- args[7]
infile_dxy <- args[8]

#######
# outfile_locusstats <- '/datacommons/yoderlab/users/jelmer/proj/iim/locusstats/split/grimurruf.iim1.11.locusstats.txt'
# ig_grep <- 'mgri|mmur|mgan'
# og_grep <- 'mruf'
# dir_fasta_og <- '/work/jwp37/proj/iim/seqdata/fasta/grimurruf.iim1/og/11/'
# dir_fasta_w1 <- '/work/jwp37/proj/iim/seqdata/fasta/grimurruf.iim1/w1/11/'
# dir_fasta_w2 <- '/work/jwp37/proj/iim/seqdata/fasta/grimurruf.iim1/w2/11/'
# dir_fasta_bw <- '/work/jwp37/proj/iim/seqdata/fasta/grimurruf.iim1/bw/11/'
# infile_dxy <- '/datacommons/yoderlab/users/jelmer/proj/hybridzone/seqdata/stacks/hzproj/grimurruf.og/fst/hzproj.grimurruf.og.phistats_ingroup-outgroup.tsv'
#######

## Packages:
suppressMessages(library(tidyverse))
suppressMessages(library(PopGenome))

## Report:
cat("\n#### iimstats_collect.R: Starting script.\n")
cat("#### iimstats_collect.R: outfile_locusstats:", outfile_locusstats, "\n")
cat("#### iimstats_collect.R: ingroup grep:", ig_grep, "\n")
cat("#### iimstats_collect.R: outgroup grep:", og_grep, "\n")
cat("#### iimstats_collect.R: dir_fasta og:", dir_fasta_og, "\n")
cat("#### iimstats_collect.R: dir_fasta w1:", dir_fasta_w1, "\n")
cat("#### iimstats_collect.R: dir_fasta w2:", dir_fasta_w2, "\n")
cat("#### iimstats_collect.R: dir_fasta bw:", dir_fasta_bw, "\n")
cat("#### iimstats_collect.R: input file with dxy:", infile_dxy, "\n\n")

## Check:
if(!dir.exists(dir_fasta_w1)) cat("\n\n\n#### ERROR: W1-FASTA DIR NOT FOUND\n\n\n")
if(!dir.exists(dir_fasta_w2)) cat("\n\n\n#### ERROR: W2-FASTA DIR NOT FOUND\n\n\n")
if(!dir.exists(dir_fasta_bw)) cat("\n\n\n#### ERROR: BW-FASTA DIR NOT FOUND\n\n\n")
if(!dir.exists(dir_fasta_og)) cat("\n\n\n#### ERROR: OUTGROUP-FASTA DIR NOT FOUND\n\n\n")


################################################################################
##### POPGENOME - INGROUP #####
################################################################################
cat("#### iimstats_collect.R: Running PopGenome...\n\n")

## Compute for within1:
cat("#### iimstats_collect.R: Loading w1 fasta in PopGenome...\n")
fa_w1 <- readData(dir_fasta_w1, format = 'fasta', include.unknown = TRUE)
w1 <- as.data.frame(get.sum.data(fa_w1)) %>%
  rename(length = n.sites,
         nvar_w1 = n.biallelic.sites,
         nmiss = n.unknowns,
         nvalid = n.valid.sites) %>%
  rownames_to_column('locus') %>%
  mutate(pmiss_w1 = ifelse(nvalid == 0, NA, round((nmiss / length) * 100, 2))) %>% # Glitch in popgenome - will return no stats, including on Ns, when there is no variation
  select(locus, length, nvar_w1, pmiss_w1)
rm(fa_w1)

## Compute for within2:
cat("#### iimstats_collect.R: Loading w2 fasta in PopGenome...\n")
fa_w2 <- readData(dir_fasta_w2, format = 'fasta', include.unknown = TRUE)
w2 <- as.data.frame(get.sum.data(fa_w2)) %>%
  rename(length = n.sites,
         nvar_w2 = n.biallelic.sites,
         nmiss = n.unknowns,
         nvalid = n.valid.sites) %>%
  rownames_to_column('locus') %>%
  mutate(pmiss_w2 = ifelse(nvalid == 0, NA, round((nmiss / length) * 100, 2))) %>% # Glitch in popgenome - will return no stats, including on Ns, when there is no variation
  select(locus, nvar_w2, pmiss_w2)
rm(fa_w2)

## Compute for between:
cat("#### iimstats_collect.R: Loading bw fasta in PopGenome...\n")
fa_bw <- readData(dir_fasta_bw, format = 'fasta', include.unknown = TRUE)
bw <- as.data.frame(get.sum.data(fa_bw)) %>%
  rename(length = n.sites,
         nvar_bw = n.biallelic.sites,
         nmiss = n.unknowns,
         nvalid = n.valid.sites) %>%
  rownames_to_column('locus') %>%
  mutate(pmiss_bw = ifelse(nvalid == 0, NA, round((nmiss / length) * 100, 2))) %>% # Glitch in popgenome - will return no stats, including on Ns, when there is no variation
  select(locus, nvar_bw, pmiss_bw)
rm(fa_bw)

## Merge:
w <- merge(w1, w2, by = 'locus')
ig <- merge(w, bw, by = 'locus')


################################################################################
##### POPGENOME - OUTGROUP #####
################################################################################
## Outgroup - read data:
cat("#### iimstats_collect.R: Loading og fasta in PopGenome...\n")
fa_og <- readData(dir_fasta_og, format = 'fasta', include.unknown = TRUE)

## Outgroup - population assignments:
first_ok <- which(lapply(get.individuals(fa_og), is.null) == FALSE)[1]
inds_all <- get.individuals(fa_og)[[first_ok]]
cat("\n\n#### iimstats_collect.R: All individuals:\n")
print(inds_all)

inds_ingroup <- inds_all[grep(ig_grep, inds_all)]
inds_outgroup <- inds_all[grep(og_grep, inds_all)]

poplist_outgroup <- list(inds_ingroup, inds_outgroup)
cat("\n\n#### iimstats_collect.R: Poplist for outgroup files:\n")
print(poplist_outgroup)

fa_og <- set.populations(fa_og, poplist_outgroup, diploid = FALSE)

## Outgroup - compute stats:
cat("#### iimstats_collect.R: Getting og divergence stats in PopGenome...\n")
fa_og <- diversity.stats.between(fa_og)
og <- fa_og@nuc.diversity.between

## Outgroup - missing data:
met_og <- get.sum.data(fa_og) %>%
  as.data.frame() %>%
  rename(length = n.sites,
         nmiss = n.unknowns,
         nvalid = n.valid.sites) %>%
  rownames_to_column('locus') %>%
  mutate(pmiss_og = round((nmiss / length) * 100, 2),
         pmiss_og = ifelse(nvalid == 0, NA, pmiss_og)) %>% # Glitch in popgenome - will return no stats, including on Ns, when there is no variation
  select(locus, pmiss_og)

og <- data.frame(og) %>%
  rownames_to_column('locus') %>%
  rename(nvar_og = pop1.pop2) %>%
  merge(., met_og, by = 'locus')

rm(fa_og)

## Merge ingroup and outgroup stats:
pg_all <- merge(ig, og, by = 'locus')


################################################################################
##### DXY #####
################################################################################
cat("\n#### iimstats_collect.R: Processing dxy...\n\n")
dxy <- read.delim(infile_dxy, skip = 2, header = TRUE) %>%
  rename(locus = X..Locus.ID,
         scaffold = Chr,
         start = BP,
         dxy = Dxy) %>%
  select(locus, scaffold, start, dxy) %>%
  mutate(dxy = as.numeric(dxy))


################################################################################
##### COMBINE STATS #####
################################################################################
cat("\n#### iimstats_collect.R: Combining stats...\n\n")

## Popgenome stats:
pg_all <- merge(ig, og, by = 'locus') %>%
  mutate(locus = gsub('Locus(.*).fa', '\\1', locus)) %>%
  select(locus, length, nvar_w1, nvar_w2, nvar_bw, nvar_og,
         pmiss_w1, pmiss_w2, pmiss_bw, pmiss_og)
pg_all$pmiss_ig <- round(rowMeans(pg_all[7:9], na.rm = TRUE), 2)

pg_all <- pg_all %>% mutate(
  pmiss_diff = pmiss_og - pmiss_ig,
  nvar_og = ifelse(!is.na(pmiss_diff),
                   round(nvar_og * (1 + (pmiss_diff/100)), 3),
                   round(nvar_og, 3))
         )

lstats <- merge(pg_all, dxy, by = 'locus', all.x = TRUE) %>%
  select(locus, scaffold, start, length,
         nvar_w1, nvar_w2, nvar_bw, nvar_og, dxy,
         pmiss_w1, pmiss_w2, pmiss_bw, pmiss_og)


################################################################################
##### WRITE FILE #####
################################################################################
cat("\n#### iimstats_collect.R: lstats dimensions:", dim(lstats), "\n\n")
cat("\n#### iimstats_collect.R: Writing final file...\n\n")
write.table(lstats, outfile_locusstats,
            sep = '\t', quote = FALSE, row.names = FALSE)

cat("\n\n#### iimstats_collect.R: Showing head of locusstats file:\n")
print(head(lstats))

cat("\n\n#### iimstats_collect.R: Done with script.\n")
