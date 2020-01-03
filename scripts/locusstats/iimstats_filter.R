#!/usr/bin/env Rscript

################################################################################
#### SET-UP ####
################################################################################
## Packages:
suppressMessages(library(tidyverse))
suppressMessages(library(grid))
suppressMessages(library(gridExtra))
suppressMessages(library(ggpubr))
suppressMessages(library(cowplot))
suppressMessages(library(scales)) # For comma in 1000s in plots
suppressMessages(library(valr)) # bedtools-like
options(scipen = 999)

## Command-line args:
options(warn = -1)
args <- commandArgs(trailingOnly = TRUE)
setID <- args[1]
ig_grep <- args[2]
og_grep <- args[3]
indfile <- args[4]
dir_locusstats <- args[5]
infile_lstats_nucdiv <- args[6]
infile_lstats_pmiss <- args[7]
maxmiss_ind <- as.numeric(args[8])
maxmiss_mean <- as.numeric(args[9])
mindist <- as.integer(args[10])
maxvar <- as.numeric(args[11])
infile_genes <- args[12]
infile_exons <- args[13]
outfile_suffix <- args[14]

## Interactive mode:
interactive_mode <- FALSE
# interactive_mode <- TRUE
if(interactive_mode == TRUE) {
  setID <- 'grimurche.iim2'
  ig_grep <- "mgan|mmur|mgri"; og_grep <- "cmed|ccro"
  infile_lstats_pmiss <- '/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/grimurche.exonunmasked.locusstats.txt'
  infile_lstats_nucdiv <- paste0('/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/', setID, '.masked.nucdiv.txt')
  indfile <- paste0('/home/jelmer/Dropbox/sc_lemurs/proj/iim/indsel/', setID, '.txt')
  dir_locusstats <- '/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats'
  maxmiss_ind <- 0.05
  maxmiss_mean <- 0.1
  mindist <- 5000
  maxvar <- 0.05
  infile_genes <- '/home/jelmer/Dropbox/sc_lemurs/seqdata/reference/mmur/GCF_000165445.2_Mmur_3.0_genes.bed'
  infile_exons <- '/home/jelmer/Dropbox/sc_lemurs/seqdata/reference/mmur/GCF_000165445.2_Mmur_3.0_exons.bed'
  outfile_suffix <- '.unmasked'
}

## Report:
cat("\n#### iimstats_filter.R: Starting script\n")
cat("#### iimstats_filter.R: setID:", setID, "\n")
cat("#### iimstats_filter.R: ingroup grep:", ig_grep, "\n")
cat("#### iimstats_filter.R: outgroup grep:", og_grep, "\n")
cat("#### iimstats_filter.R: indfile:", indfile, "\n")
cat("#### iimstats_filter.R: dir_locusstats:", dir_locusstats, "\n")
cat("#### iimstats_filter.R: Input file - nucdiv:", infile_lstats_nucdiv, "\n")
cat("#### iimstats_filter.R: Input file - pmiss:", infile_lstats_pmiss, "\n")
cat("#### iimstats_filter.R: maxmiss_ind:", maxmiss_ind, "\n")
cat("#### iimstats_filter.R: maxmiss_mean:", maxmiss_mean, "\n")
cat("#### iimstats_filter.R: mindist:", mindist, "\n")
cat("#### iimstats_filter.R: maxvar:", maxvar, "\n")
cat("#### iimstats_filter.R: infile_genes:", infile_genes, "\n")
cat("#### iimstats_filter.R: infile_exons:", infile_exons, "\n")

## Process args:
inds.focal <- as.character(readLines(indfile))
inds.focal <- inds.focal[inds.focal != ""]
focal_grep <- paste0(inds.focal, collapse = '|')
if(is.na(outfile_suffix)) outfile_suffix <- ''

## Files and dirs, part 1:
setwd(dir_locusstats)
outdir_stats <- 'final/'
outdir_stats_smr <- 'summaries/'
outfile_lstats <- paste0(outdir_stats, '/', setID, outfile_suffix, '.iimstats.txt')
outfile_lstats_smr <- paste0(outdir_stats_smr, '/', setID, outfile_suffix, '.iimstats.smr.txt')
outfile_annot_smr <- paste0(outdir_stats_smr, '/', setID, outfile_suffix, '.iimstats.annotsmr.txt')
outfile_plot <- paste0(outdir_stats_smr, '/', setID, outfile_suffix, '.sumr.plot.png')

if(!dir.exists(outdir_stats)) dir.create(outdir_stats, recursive = TRUE)
if(!dir.exists(outdir_stats_smr)) dir.create(outdir_stats_smr, recursive = TRUE)

cat("#### iimstats_filter.R: Locusstats output file:", outfile_lstats, "\n")


################################################################################
#### PREP DF ####
################################################################################
cat("\n#### Reading and prepping locus stats file...\n")

## Locusstats with nucdiv stats from iim pipeline:
lstats_nucdiv <- read.delim(infile_lstats_nucdiv, header = TRUE, as.is = TRUE) %>%
  mutate(locusID = gsub('.fa', '', locus)) %>%
  select(-locus)
cat("#### Dimensions of nucdiv file:", dim(lstats_nucdiv), "\n")

## Locusstats with pmiss stats from stacksfa pipeline:
lstats_pmiss <- read.delim(infile_lstats_pmiss, header = TRUE, as.is = TRUE) %>%
  select(-length)
cat("#### Dimensions of of pmiss file:", dim(lstats_pmiss), "\n")

## Merge and basic processing:
lstats_raw <- merge(lstats_nucdiv, lstats_pmiss, by = 'locusID')
cat("#### Dimensions of of merged file:", dim(lstats_raw), "\n")

lstats <- lstats_raw %>%
  arrange(scaffold, start) %>%
  mutate(
    start = as.integer(start),
    length = as.integer(length),
    nvar_w1 = as.numeric(nvar_w1),
    nvar_w2 = as.numeric(nvar_w2),
    nvar_bw = as.numeric(nvar_bw),
    nvar_og = as.numeric(nvar_og)
  ) %>%
  mutate(nvar_og = round(nvar_og, 2))

## Get pmiss by group:
pmiss_cols <- colnames(lstats)[grep('pmiss', colnames(lstats))]
og_cols <- lstats[, grep(og_grep, colnames(lstats)) ]
ig_cols <- lstats[, grep(ig_grep, colnames(lstats)) ]

lstats$nmiss_og <- apply(og_cols, 1, function(x) sum(is.na(x)))
npres_og <- length(grep(og_grep, colnames(lstats))) - lstats$nmiss_og
lstats$pmiss_og <- round(rowSums(og_cols, na.rm = TRUE) / npres_og, 3)

lstats$nmiss_ig <- apply(ig_cols, 1, function(x) sum(is.na(x)))
npres_ig <- length(grep(ig_grep, colnames(lstats))) - lstats$nmiss_ig
lstats$pmiss_ig <- round(rowSums(ig_cols, na.rm = TRUE) / npres_ig, 3)

lstats$pmiss_w1 <- lstats[, paste0('pmiss_', inds.focal[1])]
lstats$pmiss_w2 <- lstats[, paste0('pmiss_', inds.focal[2])]
lstats$pmiss_bw <- round(rowSums(og_cols, na.rm = TRUE) / length(grep(focal_grep, colnames(lstats))), 3)

## If locus is "missing" (too much missing data) - change nvar to NA
lstats$nvar_w1 <- ifelse(is.na(lstats$pmiss_w1), NA, lstats$nvar_w1)
lstats$nvar_w2 <- ifelse(is.na(lstats$pmiss_w2), NA, lstats$nvar_w2)
lstats$nvar_bw <- ifelse(is.na(lstats$pmiss_w1), NA, lstats$nvar_bw)
lstats$nvar_bw <- ifelse(is.na(lstats$pmiss_w2), NA, lstats$nvar_bw)

## Get outgroup & ingroup ind IDs:
inds.og <- gsub('pmiss_', '', pmiss_cols[grep(og_grep, pmiss_cols)])
cat("\n#### Outgroup individuals:\n")
print(inds.og)

inds.ig <- gsub('pmiss_', '', pmiss_cols[grep(ig_grep, pmiss_cols)])
cat("#### Ingroup individuals:\n")
print(inds.ig)

cat("\n#### Missing data by individual:\n")
lstats %>%
  select(contains('pmiss')) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE) %>%
  round(., 3)

## Select columns:
lstats <- lstats %>%
  select(locusID, scaffold, start, end, length,
         contains('nvar'),
         pmiss_w1, pmiss_w2, pmiss_bw,
         pmiss_ig, nmiss_ig, pmiss_og, nmiss_og)

nloci_prefilter <- nrow(lstats)
cat("\n#### Nr loci in original df:", nloci_prefilter, "\n")
print(head(lstats, n = 2))


################################################################################
#### FILTER BY MISSING DATA ####
################################################################################
nrow_org <- nrow(lstats)
lstats <- lstats %>% filter(!is.na(nvar_w1) | !is.na(nvar_w2))
nloci_rm_imiss.focal <- nrow_org - nrow(lstats)
cat("\n#### Nr loci removed - w1 & w2 missing:", nloci_rm_imiss.focal,
    "(", nrow(lstats), "remaining)\n")

nrow_org <- nrow(lstats)
lstats <- lstats %>% filter(nmiss_og < length(inds.og))
nloci_rm_imiss.og <- nrow_org - nrow(lstats)
cat("#### Nr loci removed - all og inds missing:", nloci_rm_imiss.og,
    "(", nrow(lstats), "remaining)\n")

nrow_org <- nrow(lstats)
lstats <- lstats %>% filter(nmiss_ig < (length(inds.ig) * 0.5))
nloci_rm_imiss.ig <- nrow_org - nrow(lstats)
cat("#### Nr loci removed - more than half of ig inds missing:", nloci_rm_imiss.ig,
    "(", nrow(lstats), "remaining)\n")

nrow_org <- nrow(lstats)
lstats <- lstats %>% filter(pmiss_w1 < maxmiss_ind | pmiss_w2 < maxmiss_ind | pmiss_bw < maxmiss_ind)
nloci_rm_pmiss.focal <- nrow_org - nrow(lstats)
cat("#### Nr loci removed - pmiss in all focal inds >", maxmiss_ind, ":",
    nloci_rm_pmiss.focal, "(", nrow(lstats), "remaining)\n")

nrow_org <- nrow(lstats)
lstats <- lstats %>% filter(pmiss_og <= maxmiss_mean)
nloci_rm_pmiss.og <- nrow_org - nrow(lstats)
cat("#### Nr loci removed - pmiss_og >", maxmiss_mean, ":",
    nloci_rm_pmiss.og, "(", nrow(lstats), "remaining)\n")

nrow_org <- nrow(lstats)
lstats <- lstats %>% filter(pmiss_ig <= maxmiss_mean)
nloci_rm_pmiss.ig <- nrow_org - nrow(lstats)
cat("#### Nr loci removed - pmiss_ig >", maxmiss_mean, ":",
    nloci_rm_pmiss.ig, "(", nrow(lstats), "remaining)\n")


################################################################################
#### FILTER BY TOO FEW DIFFS WITH OUTGROUP ####
################################################################################
nrow_org <- nrow(lstats)
lstats <- lstats %>% filter(nvar_og >= 1)
nloci_rm_novar <- nrow_org - nrow(lstats)
cat("\n#### Nr loci removed - too few diffs with outgroup:", nloci_rm_novar,
    "(", nrow(lstats), "remaining)\n")


################################################################################
#### COMPARE WITHIN AND OUTSIDE OF GENES ####
################################################################################
genes <- read.delim(infile_genes, header = FALSE, as.is = TRUE,
                    col.names = c('chrom', 'start', 'end')) %>%
  as.tbl_interval(.)

exons <- read.delim(infile_exons, header = FALSE, as.is = TRUE,
                    col.names = c('chrom', 'start', 'end')) %>%
  as.tbl_interval(.)

lstats_bed <- lstats %>%
  select(scaffold, start, end, locusID) %>%
  rename(chrom = scaffold) %>%
  as.tbl_interval(.)

loci_genes <- bed_intersect(genes, lstats_bed) %>% pull(locusID.y)
loci_exons <- bed_intersect(exons, lstats_bed) %>% pull(locusID.y)

lstats <- lstats %>%
  mutate(annot = ifelse(locusID %in% loci_exons, 'gene_exon',
                        ifelse(locusID %in% loci_genes, 'gene_intron', 'intergenic')))

annot_n <- lstats %>% group_by(annot) %>% tally()
prop <- round(annot_n$n / nrow(lstats), 2)

annot_smr <- lstats %>%
  group_by(annot) %>%
  select(annot, contains('nvar')) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE) %>%
  cbind(., annot_n[, 'n'], prop)

ex <- annot_smr[which(annot_smr$annot == 'gene_exon'), 2:5]
ig <- annot_smr[which(annot_smr$annot == 'intergenic'), 2:5]
ex2ig <- cbind(data.frame(annot = 'ex2ig'),
               as.data.frame(round(ex / ig, 3)),
               n = NA, prop = NA)
annot_smr <- rbind(annot_smr, ex2ig) %>%
  mutate_if(is.numeric, round, digits = 3)

cat("#### nvar by annotation category:\n")
print(annot_smr)

## Write nvar-by-annot summary df:
write.table(annot_smr, outfile_annot_smr,
            sep = '\t', quote = FALSE, row.names = FALSE)


################################################################################
#### FILTER: MAX NR OF WITHIN-SP SNPS ####
################################################################################
nrow_org <- nrow(lstats)

lstats <- lstats %>%
  filter(nvar_w1 < (maxvar * length) | nvar_w2 < (maxvar * length))

nloci_rm_maxvar <- nrow_org - nrow(lstats)
cat("\n#### Nr loci removed - prop sites variable within species more than",
    maxvar, ":", nloci_rm_maxvar, "(", nrow(lstats), "remaining)\n")


################################################################################
#### FILTER: NR OF WITHIN-SP SNPS SHOULD BE SMALLER THAN WITH OUTGROUP ####
################################################################################
lstats_fake2 <- lstats %>% filter(nvar_w1 > nvar_og | nvar_w2 > nvar_og)
cat("\n#### Nr loci THAT WOULD BE removed - more within than outgroup SNPS:", nrow(lstats_fake2), "\n")
round(table(lstats_fake2$annot) / nrow(lstats_fake2), 2)

lstats_fake2 %>%
  filter((nvar_w1 - nvar_og) > 3 | (nvar_w2 - nvar_og) > 3) %>%
  select(-scaffold, -start, -end, -contains('nmiss'))


################################################################################
#### CHECK EXTREME NVAR ####
################################################################################
#quantile(lstats$nvar_og)
#lstats %>% filter(nvar_og > 40)
#lstats %>% filter(nvar_og < 0.1) %>% arrange(nvar_og)


################################################################################
#### CYCLE THROUGH LOCI FOR DIFFERENT COMPARISONS ####
################################################################################
loci_w1 <- which(is.na(lstats$nvar_w2))
loci_w2 <- which(is.na(lstats$nvar_w1))
loci_bw <- intersect(which(!is.na(lstats$nvar_w1)), which(!is.na(lstats$nvar_w2)))

if(length(loci_w1) < length(loci_bw)) {
  if(length(loci_w2) < length(loci_bw)) {
    nr_target_each <- round(sum(length(loci_w1), length(loci_w2), length(loci_bw)) / 3)
    nr_to_move <- length(loci_bw) - nr_target_each

    if(length(loci_w1) < length(loci_w2)) {
      nr_move_to_w1 <- round((1 - (length(loci_w1) / length(loci_w2))) * nr_to_move)
      nr_move_to_w2 <- round((length(loci_w1) / length(loci_w2)) * nr_to_move)
    }

    if(length(loci_w1) >= length(loci_w2)) {
      nr_move_to_w1 <- round((length(loci_w2) / length(loci_w1)) * nr_to_move)
      nr_move_to_w2 <- round((1 - (length(loci_w2) / length(loci_w1))) * nr_to_move)
    }

    move_to_w1 <- sample(x = 1:length(loci_bw), nr_move_to_w1)
    loci_w1 <- sort(c(loci_w1, loci_bw[move_to_w1]))
    loci_bw <- loci_bw[-move_to_w1]

    move_to_w2 <- sample(x = 1:length(loci_bw), nr_move_to_w2)
    loci_w2 <- sort(c(loci_w2, loci_bw[move_to_w2]))
    loci_bw <- loci_bw[-move_to_w2]
  }
}

lstats_w1 <- lstats %>% slice(loci_w1) %>% arrange(scaffold, start)
lstats_w2 <- lstats %>% slice(loci_w2) %>% arrange(scaffold, start)
lstats_bw <- lstats %>% slice(loci_bw) %>% arrange(scaffold, start)

cat("\n#### Number of w1 loci:", nrow(lstats_w1), "\n")
cat("#### Number of w2 loci:", nrow(lstats_w2), "\n")
cat("#### Number of bw loci:", nrow(lstats_bw), "\n\n")


################################################################################
#### FILTER BY PROXIMITY ####
################################################################################
filter_proxim <- function(my.lstats, comp, my.mindist = mindist) {
  #my.lstats <- lstats_w1; my.mindist <- mindist; comp = 'w1'

  my.lstats <- my.lstats %>%
    arrange(scaffold, start) %>%
    group_by(scaffold) %>%
    mutate(distToNext = lead(start) - (start + length)) %>% # Include distance-to-next locus
    ungroup()

  close.loc1.idx <- which(my.lstats$distToNext < my.mindist)
  #cat("#### Number of loci too close:", length(close.loc1.idx), "\n")
  close.loc2.idx <- close.loc1.idx + 1

  close <- cbind(my.lstats[close.loc1.idx, c("locusID", paste0("pmiss_", comp))],
                 my.lstats[close.loc2.idx, c("locusID", paste0("pmiss_", comp))])
  colnames(close) <- c('loc1', 'pmiss_bw1', 'loc2', 'pmiss_bw2')
  close$pmiss_bw1[is.na(close$pmiss_bw1)] <- 0
  close$pmiss_bw2[is.na(close$pmiss_bw2)] <- 0

  close.rm <- unique(c(close$loc1[which(close$pmiss_bw1 > close$pmiss_bw2)],
                       close$loc2[which(close$pmiss_bw1 <= close$pmiss_bw2)]))

  my.lstats_filt <- my.lstats %>% filter(! locusID %in% close.rm)

  cat("#### Nr of loci removed:", length(close.rm), '\n')
  return(my.lstats_filt)
}

nloci_w1_org <- nrow(lstats_w1)
nloci_w2_org <- nrow(lstats_w2)
nloci_bw_org <- nrow(lstats_bw)

lstats_w1 <- lstats_w1 %>%
  filter_proxim(., comp = 'w1') %>%
  filter_proxim(., comp = 'w1') %>%
  filter_proxim(., comp = 'w1')

lstats_w2 <- lstats_w2 %>%
  filter_proxim(., comp = 'w2') %>%
  filter_proxim(., comp = 'w2') %>%
  filter_proxim(., comp = 'w2')

lstats_bw <- lstats_bw %>%
  filter_proxim(., comp = 'bw') %>%
  filter_proxim(., comp = 'bw') %>%
  filter_proxim(., comp = 'bw')

nloci_rm_prox_w1 <- nloci_w1_org - nrow(lstats_w1)
nloci_rm_prox_w2 <- nloci_w2_org - nrow(lstats_w2)
nloci_rm_prox_bw <- nloci_bw_org - nrow(lstats_bw)
cat("\n#### Nr loci removed due to proximity - w1:", nloci_rm_prox_w1, '\n')
cat("#### Nr loci removed due to proximity - w2:", nloci_rm_prox_w2, '\n')
cat("#### Nr loci removed due to proximity - bw:", nloci_rm_prox_bw, '\n')


################################################################################
#### FILTER BY MISSING DATA AGAIN ####
################################################################################
nloci_w1_org <- nrow(lstats_w1)
nloci_w2_org <- nrow(lstats_w2)
nloci_bw_org <- nrow(lstats_bw)

lstats_w1 <- lstats_w1 %>% filter(pmiss_w1 < maxmiss_ind)
lstats_w2 <- lstats_w2 %>% filter(pmiss_w2 < maxmiss_ind)
lstats_bw <- lstats_bw %>% filter(pmiss_bw < maxmiss_ind)

nloci_rm_pmiss_w1 <- nloci_w1_org - nrow(lstats_w1)
nloci_rm_pmiss_w2 <- nloci_w2_org - nrow(lstats_w2)
nloci_rm_pmiss_bw <- nloci_bw_org - nrow(lstats_bw)
cat("#### Nr loci removed due to pmiss - w1:", nloci_rm_pmiss_w1, '\n')
cat("#### Nr loci removed due to pmiss - w2:", nloci_rm_pmiss_w2, '\n')
cat("#### Nr loci removed due to pmiss - bw:", nloci_rm_pmiss_bw,
    "(", nrow(lstats), "remaining)\n")


################################################################################
#### EXPLORE FINAL SET OF LOCI ####
################################################################################
nloci_w1 <- nrow(lstats_w1)
nloci_w2 <- nrow(lstats_w2)
nloci_bw <- nrow(lstats_bw)
cat("\n#### Nr loci (w1, w2, bw):", nloci_w1 , nloci_w2, nloci_bw, '\n')

lstats_comb <- rbind(lstats_w1, lstats_w2, lstats_bw) %>%
  gather(key = my.stat, value = my.val,
         length, nvar_w1, nvar_w2, nvar_bw, nvar_og,
         pmiss_w1, pmiss_w2, pmiss_bw, pmiss_og)

lstats_smr <- lstats_comb %>%
  group_by(my.stat) %>%
  summarize(my.val = round(mean(my.val, na.rm = TRUE), 3))

## Add nvar ratios:
my.colnames <- as.character(as.matrix(t(lstats_smr)[1, ]))
my.vals <- as.numeric(as.matrix(t(lstats_smr)[2, ]))
s2 <- data.frame(t(my.vals))
colnames(s2) <- my.colnames
s2$nvar_og2bw <- round(s2$nvar_og  / s2$nvar_bw, 3)
s2$nvar_og2w <- round(s2$nvar_og / ((s2$nvar_w1 + s2$nvar_w2) / 2), 3)
s2$nvar_bw2w <- round(s2$nvar_bw / ((s2$nvar_w1 + s2$nvar_w2) / 2), 3)

lstats_smr2 <- as.data.frame(t(s2)) %>%
  rownames_to_column()
colnames(lstats_smr2) <- c('my.stat', 'my.val')

nloci <- rbind(nloci_w1,
               nloci_w2,
               nloci_bw,
               nloci_prefilter,
               nloci_rm_imiss.ig,
               nloci_rm_imiss.og,
               nloci_rm_pmiss.ig,
               nloci_rm_pmiss.og,
               nloci_rm_pmiss_w1,
               nloci_rm_pmiss_w2,
               nloci_rm_pmiss_bw,
               nloci_rm_novar,
               nloci_rm_prox_w1,
               nloci_rm_prox_w2,
               nloci_rm_prox_bw) %>%
  as.data.frame() %>%
  rownames_to_column('my.stat') %>%
  rename(my.val = V1)

lstats_smr <- rbind(lstats_smr2, nloci)
colnames(lstats_smr)[2] <- setID


################################################################################
#### WRITE FINAL FILE ####
################################################################################
## Make sure all three df's have some number of rows, then cbind:
nrow_max <- max(nrow(lstats_w1), nrow(lstats_w2), nrow(lstats_bw))

if(nrow(lstats_w1) < nrow_max)
  lstats_w1 <- add_row(lstats_w1, locusID = rep(NA, nrow_max - nrow(lstats_w1)))
if(nrow(lstats_w2) < nrow_max)
  lstats_w2 <- add_row(lstats_w2, locusID = rep(NA, nrow_max - nrow(lstats_w2)))
if(nrow(lstats_bw) < nrow_max)
  lstats_bw <- add_row(lstats_bw, locusID = rep(NA, nrow_max - nrow(lstats_bw)))

lstats_final <- cbind(lstats_w1[, c('nvar_w1', 'nvar_og')],
                      lstats_w2[, c('nvar_w2', 'nvar_og')],
                      lstats_bw[, c('nvar_bw', 'nvar_og')])

## Column names:
colnames(lstats_final) <- c('within_1', 'outgroup_1',
                            'within_2', 'outgroup_2',
                            'between_3', 'outgroup_3')

## Write file:
write.table(lstats_final, outfile_lstats,
            sep = '\t', quote = FALSE, row.names = FALSE)
write.table(lstats_smr, outfile_lstats_smr,
            sep = '\t', quote = FALSE, row.names = FALSE)

## Print summary:
cat("\n\n#### iimstats_filter.R: Showing locus summary:\n")
print(lstats_smr)


################################################################################
#### PLOTS ####
################################################################################
## Locus length:
plength <- ggplot(data = filter(lstats_comb, my.stat == 'length')) +
  geom_histogram(aes(my.val)) +
  labs(x = 'Locus length (bp)') + #title = setID
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  theme_bw() +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(size = 15),
        axis.title.x = element_text(size = 18),
        plot.title = element_text(size = 20, hjust = 0.5),
        plot.margin = margin(1.5, 0.5, 0.5, 0.5, "cm"))

## Number of loci:
nloci_max <- max(nloci_w1, nloci_w2, nloci_bw)
my.breaks <- c(seq(0, nloci_max, by = 5000), nloci_max)

nloci_plotdf <- filter(nloci, my.stat %in% c('nloci_w1', 'nloci_w2', 'nloci_bw'))

ploc <- ggplot(nloci_plotdf) +
    geom_bar(aes(x = my.stat, y = my.val), stat = 'identity') +
    scale_x_discrete(labels = c('between', 'within1', 'within2')) +
    scale_y_continuous(label = comma, expand = c(0, 0),
                       breaks = my.breaks) +
    labs(y = 'Number of loci') +
    theme_bw() +
    theme(axis.text = element_text(size = 15),
          axis.title.x = element_blank(),
          axis.title.y = element_text(size = 18),
          plot.margin = margin(1.5, 0.5, 0.5, 0.5, "cm"))

## Pairwise differences:
pvar <- ggplot(data = filter(lstats_comb, grepl('var', my.stat))) +
  geom_histogram(aes(my.val, fill = my.stat)) +
  labs(x = 'Pairwise differences') +
  scale_x_continuous(expand = c(0, 0), limits = c(-1, 25)) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_fill_discrete(breaks = c('nvar_w1', 'nvar_w2', 'nvar_bw', 'dxy'),
                      labels = c('within1', 'within2', 'between', 'outgroup')) +
  theme_bw() +
  theme(legend.position = 'top',
        legend.title = element_blank(),
        legend.text = element_text(size = 10),
        legend.background = element_rect(colour = 'grey20'),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(size = 15),
        axis.title.x = element_text(size = 18),
        plot.title = element_text(size = 20, hjust = 0.5),
        plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"))

## Missing data:
pmiss <- ggplot(data = filter(lstats_comb, grepl('miss', my.stat))) +
  geom_histogram(aes(my.val, fill = my.stat)) +
  labs(x = 'Missing data (% N)', fill = 'Comparison') +
  scale_x_continuous(expand = c(0, 0), limits = c(-0.001, 0.05)) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_fill_discrete(breaks = c('miss_w1', 'miss_w2', 'miss_bw', 'miss_og'),
                      labels = c('within1', 'within2', 'between', 'outgroup')) +
  theme_bw() +
  theme(legend.position = 'top',
        legend.title = element_blank(),
        legend.text = element_text(size = 10),
        legend.background = element_rect(colour = 'grey20'),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(size = 15),
        axis.title.x = element_text(size = 18),
        plot.title = element_text(size = 20, hjust = 0.5),
        plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"))

p <- ggarrange(plength, ploc, pmiss, pvar, ncol = 2, nrow = 2)
p <- p + draw_plot_label(label = setID, x = 0.3, y = 1, size = 20)

ggsave(outfile_plot, p, width = 8, height = 8)
system(paste('xdg-open', outfile_plot))
