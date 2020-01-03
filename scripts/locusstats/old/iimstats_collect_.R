#!/usr/bin/env Rscript

################################################################################
##### SET-UP #####
################################################################################
## Command-line args:
options(warn = -1)
args <- commandArgs(trailingOnly = TRUE)

setID <- args[1]
ind1 <- args[2]
ind2 <- args[3]
dir_fasta <- args[4]
dir_locusstats <- args[5]
infile_dxy <- args[6]

#######
setID <- 'grimurruf.iim2'
ind1 <- 'mgri051'
ind2 <-  'mmur009'
dir_fasta <- '/home/jelmer/Dropbox/sc_lemurs/proj/iim/seqdata/fasta/grimur.iim2/'
dir_locusstats <- '/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/grimur.iim2/'
infile_dxy <- '/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/stacks/hzproj.all.phistats_mur-E-mruf.tsv'
#######

#######
#setID <- 'grimurruf.iim2'
#ind1 <- 'mgri051'
#ind2 <-  'mmur009'
#dir_fasta <- '/datacommons/yoderlab/users/jelmer/proj/hybridzone/seqdata/stacks/hzproj/grimur.iim2/fasta_ed/bylocus/'
#dir_locusstats <- '/datacommons/yoderlab/users/jelmer/proj/iim/locusstats/grimurruf.iim2/'
#infile_dxy <- '/datacommons/yoderlab/users/jelmer/proj/hybridzone/seqdata/stacks//hzproj/grimurruf.og/fst/hzproj.grimurruf.og.phistats_ingroup-outgroup.tsv'
#######


## Packages:
suppressMessages(library(tidyverse))
suppressMessages(library(PopGenome))

## Process:
outfile_locusstats <- paste0(dir_locusstats, '/', setID, '.locusstats_raw.txt')

poplist_within <- list(c(paste0(ind1, '_0'), c(paste0(ind1, '_1'))),
                       c(paste0(ind2, '_0'), c(paste0(ind2, '_1'))))
poplist_between <- list(c(paste0(ind1, '_0')), c(paste0(ind2, '_0')))

## Report:
cat("\n#### iimstats_collect.R: Starting script.\n")
cat("#### iimstats_collect.R: setID:", setID, "\n")
cat("#### iimstats_collect.R: individual 1:", ind1, "\n")
cat("#### iimstats_collect.R: individual 2:", ind2, "\n")
cat("#### iimstats_collect.R: dir_fasta:", dir_fasta, "\n")
cat("#### iimstats_collect.R: dir_locusstats:", dir_locusstats, "\n")
cat("#### iimstats_collect.R: input file with dxy:", infile_dxy, "\n\n")

## Check:
if(!dir.exists(dir_fasta)) cat("\n\n\n#### ERROR: FASTA DIR NOT FOUND\n\n\n")
if(!file.exists(infile_dxy)) cat("\n\n\n#### ERROR: DXY FILE NOT FOUND\n\n\n")
if(!dir.exists(dir_locusstats)) dir.create(dir_locusstats, recursive = TRUE)


################################################################################
##### POPGENOME #####
################################################################################
cat("#### iimstats_collect.R: Running PopGenome...\n\n")

fa <- readData(dir_fasta, format = 'FASTA', include.unknown = TRUE)
fa_within <- set.populations(fa, poplist_within, diploid = FALSE)
fa_between <- set.populations(fa, poplist_between, diploid = FALSE)

# fa_between@region.data@populations2[[1]]
# as.integer(fa@n.sites)
# length(fa@region.names)
# get.sum.data(fa)

## Compute nucleotide div stats:
fa_between <- diversity.stats.between(fa_between)
fa_within <- diversity.stats(fa_within)

bw <- fa_between@nuc.diversity.between
w <- fa_within@nuc.diversity.within

nucdiff <- data.frame(bw, w) %>%
  rename(nvar_bw = pop1.pop2,
         nvar_w1 = pop.1,
         nvar_w2 = pop.2) %>%
  rownames_to_column('locus') %>%
  mutate(locus = gsub('Locus(.*).fa', '\\1', locus))

## Get missing data and other stats:
met <- get.sum.data(fa) %>%
  as.data.frame() %>%
  rename(length = n.sites,
         nmiss = n.unknowns,
         nvalid = n.valid.sites) %>%
  rownames_to_column('locus') %>%
  mutate(locus = gsub('Locus(.*).fa', '\\1', locus),
         pmiss = round((nmiss / length) * 100, 2),
         pmiss = ifelse(nvalid == 0, NA, pmiss)) %>% # Glitch in popgenome - will return no stats, including on Ns, when there is no variation
  select(locus, length, pmiss)

## Merge:
lstats_pg <- merge(met, nucdiff, by = 'locus')


################################################################################
##### DXY #####
################################################################################
cat("#### iimstats_collect.R: Processing dxy...\n\n")
dxy <- read.delim(infile_dxy, skip = 2, header = TRUE) %>%
  rename(locus = X..Locus.ID,
         scaffold = Chr,
         start = BP,
         dxy = Dxy) %>%
  select(locus, scaffold, start, dxy) %>%
  mutate(dxy = as.numeric(dxy))


################################################################################
##### MERGE AND WRITE FILE #####
################################################################################
lstats <- merge(dxy, lstats_pg, by = 'locus', all.x = TRUE) %>%
  select(locus, scaffold, start, length, nvar_w1, nvar_w2, nvar_bw, dxy, pmiss)
#head(lstats)

write.table(lstats, outfile_locusstats,
            sep = '\t', quote = FALSE, row.names = FALSE)

cat("\n\n#### iimstats_collect.R: Showing head of locusstats file:\n")
lstats %>% print(n = 10)

cat("\n\n#### iimstats_collect.R: Done with script.\n")