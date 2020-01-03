## (TO DO: Filter by HWE? ... from Stacks stats - probably not)
## TO DO: Filter by phasing? How to know which were successfully phased?

################################################################################
##### SET-UP #####
################################################################################
setID <- 'grimurruf.iim2'
dir_locusstats <- '/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats'
maxmiss <- 5
mindist <- 10000

## Other setings:
scaffolds.rm <- c('Super_Scaffold0', 'NC_028718.1', 'NC_033692.1')

## Files and dirs, part 1:
setwd(dir_locusstats)
indir_stats <- 'raw/'
outdir_stats <- 'final/'
outdir_stats_smr <- 'summaries/'
infile_lstats <- paste0(indir_stats, setID, '.locusstats.txt')
outfile_lstats <- paste0(outdir_stats, '/', setID, '.iimstats.txt')
outfile_lstats_smr <- paste0(outdir_stats_smr, '/', setID, '.iimstats.smr.txt')
outfile_plot <- paste0(outdir_stats_smr, '/', setID, 'sumr.plot.png')

if(!dir.exists(outdir_stats)) dir.create(outdir_stats, recursive = TRUE)
if(!dir.exists(outdir_stats_smr)) dir.create(outdir_stats_smr, recursive = TRUE)

## Packages:
suppressMessages(library(tidyverse))
suppressMessages(library(grid))
suppressMessages(library(gridExtra))
suppressMessages(library(ggpubr))
suppressMessages(library(cowplot))
suppressMessages(library(scales)) # For comma in 1000s

## Report:
cat("\n#### iimstats_filter.R: Starting script\n")
cat("#### iimstats_filter.R: setID:", setID, "\n")
cat("#### iimstats_filter.R: dir_locusstats:", dir_locusstats, "\n")
cat("#### iimstats_filter.R: maxmiss:", maxmiss, "\n")
cat("#### iimstats_filter.R: mindist:", mindist, "\n\n")
cat("#### iimstats_filter.R: Locusstats input file:", infile_lstats, "\n")
cat("#### iimstats_filter.R: Locusstats output file:", outfile_lstats, "\n")
#cat("#### iimstats_filter.R: maxvar:", maxvar, "\n")

################################################################################
##### PREP DF #####
################################################################################
cat("#### Reading and prepping locus stats file...\n")
lstats_raw <- read.delim(infile_lstats, header = TRUE, as.is = TRUE)
cat("#### Dimensions:", dim(lstats_raw), "\n")

lstats_raw <- lstats_raw %>%
  mutate(
    start = as.integer(start),
    length = as.integer(length),
    nvar_w1 = as.numeric(nvar_w1),
    nvar_w2 = as.numeric(nvar_w2),
    nvar_bw = as.numeric(nvar_bw),
    nvar_og = as.numeric(nvar_og),
    dxy = as.numeric(dxy),
    pmiss_w1 = as.numeric(pmiss_w1),
    pmiss_w2 = as.numeric(pmiss_w2),
    pmiss_bw = as.numeric(pmiss_bw),
    pmiss_og = as.numeric(pmiss_og)
  )

lstats_raw <- lstats_raw %>%
  filter(!is.na(length)) %>%
  mutate(nvar_og = round(nvar_og, 2),
         dxy = round(dxy * length * (1 - (pmiss_og/100)), 2)) %>%
  arrange(scaffold, start)
print(head(lstats))

lstats <- lstats_raw %>%
  filter(!is.na(start))
#lstats <- lstats_raw %>%
#  filter(is.na(start))

nloci_prefilter <- nrow(lstats)
cat("#### Nr loci in original df:", nloci_prefilter, "\n")


################################################################################
##### FILTER BY MISSING DATA #####
################################################################################
nrow_org <- nrow(lstats)

#length(which(lstats$pmiss_w1 > maxmiss))
#length(which(lstats$pmiss_w2 > maxmiss))
#length(which(lstats$pmiss_bw >= maxmiss))
#length(which(lstats$pmiss_og > (maxmiss * 2)))

lstats <- lstats %>% filter(pmiss_w1 < maxmiss | is.na(pmiss_w1),
                            pmiss_w2 < maxmiss | is.na(pmiss_w2),
                            pmiss_bw < maxmiss | is.na(pmiss_bw),
                            pmiss_og < (2 * maxmiss) | is.na(pmiss_og))

nloci_rm_miss <- nrow_org - nrow(lstats)
cat("#### Nr loci removed - missing data:", nloci_rm_miss, "\n")


################################################################################
##### FILTER BY 0 DIFFS WITH OUTGROUP #####
################################################################################
nrow_org <- nrow(lstats)
lstats <- lstats %>% filter(nvar_og > 0)
nloci_rm_novar <- nrow_org - nrow(lstats)
cat("#### Nr loci removed - 0 diffs with outgroup:", nloci_rm_novar, "\n")


################################################################################
##### FILTER BY SCAFFOLD #####
################################################################################
nrow_org <- nrow(lstats)
lstats <- lstats %>% filter(! scaffold %in% scaffolds.rm)
nloci_rm_scaffold <- nrow_org - nrow(lstats)
cat("#### Nr loci removed - scaffold ID:", nloci_rm_scaffold, "\n")


################################################################################
##### CYCLE THROUGH LOCI FOR DIFFERENT COMPARISONS #####
################################################################################
w1.idx <- seq(from = 1, to = nrow(lstats), by = 3)
w2.idx <- seq(from = 2, to = nrow(lstats), by = 3)
bw.idx <- seq(from = 3, to = nrow(lstats), by = 3)

lstats_w1 <- lstats %>% slice(w1.idx)
lstats_w2 <- lstats %>% slice(w2.idx)
lstats_bw <- lstats %>% slice(bw.idx)


################################################################################
##### FILTER BY PROXIMITY #####
################################################################################
filter_proxim <- function(my.lstats, comp, my.mindist = mindist) {
  #my.lstats <- lstats_w1; my.mindist <- mindist; comp = 'w1'

  my.lstats <- my.lstats %>%
    arrange(scaffold, start) %>%
    group_by(scaffold) %>%
    mutate(distToNext = lead(start) - (start + length)) %>% # Include distance-to-next locus
    ungroup()

  close.loc1.idx <- which(my.lstats$distToNext < my.mindist)
  cat("#### Number of loci too close:", length(close.loc1.idx), "\n")
  close.loc2.idx <- close.loc1.idx + 1

  close <- cbind(my.lstats[close.loc1.idx, c("locus", paste0("pmiss_", comp))],
                 my.lstats[close.loc2.idx, c("locus", paste0("pmiss_", comp))])
  colnames(close) <- c('loc1', 'pmiss1', 'loc2', 'pmiss2')
  close$pmiss1[is.na(close$pmiss1)] <- 0
  close$pmiss2[is.na(close$pmiss2)] <- 0

  close.rm <- unique(c(close$loc1[which(close$pmiss1 > close$pmiss2)],
                       close$loc2[which(close$pmiss1 <= close$pmiss2)]))

  my.lstats_filt <- my.lstats %>% filter(! locus %in% close.rm)

  cat("#### Nr loci removed:", length(close.rm), '\n')

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
cat("#### Nr loci removed due to proximity - w1:", nloci_rm_prox_w1, '\n')
cat("#### Nr loci removed due to proximity - w2:", nloci_rm_prox_w2, '\n')
cat("#### Nr loci removed due to proximity - bw:", nloci_rm_prox_bw, '\n')


################################################################################
##### EXPLORE FINAL SET OF LOCI #####
################################################################################
nloci_w1 <- nrow(lstats_w1)
nloci_w2 <- nrow(lstats_w2)
nloci_bw <- nrow(lstats_bw)
cat("\n#### Nr loci (w1, w2, bw):", nloci_w1 , nloci_w2, nloci_bw, '\n')

lstats_comb <- rbind(lstats_w1, lstats_w2, lstats_bw) %>%
  select(-distToNext) %>%
  gather(key = my.stat, value = my.val,
         length, nvar_w1, nvar_w2, nvar_bw, nvar_og, dxy,
         pmiss_w1, pmiss_w2, pmiss_bw, pmiss_og)

lstats_smr <- lstats_comb %>%
  group_by(my.stat) %>%
  summarize(my.val = round(mean(my.val, na.rm = TRUE), 3))

nloci <- rbind(nloci_w1,
               nloci_w2,
               nloci_bw,
               nloci_prefilter,
               nloci_rm_miss,
               #nloci_rm_noDxy, #nloci_rm_nsnp1, #nloci_rm_nsnp2,
               nloci_rm_novar,
               nloci_rm_scaffold,
               nloci_rm_prox_w1,
               nloci_rm_prox_w2,
               nloci_rm_prox_bw) %>%
  as.data.frame() %>%
  rownames_to_column('my.stat') %>%
  rename(my.val = V1)

lstats_smr <- rbind(lstats_smr, nloci)
colnames(lstats_smr)[2] <- setID


################################################################################
##### WRITE FINAL FILE #####
################################################################################
## Make sure all three df's have some number of rows, then cbind:
nrow_max <- max(nrow(lstats_w1), nrow(lstats_w2), nrow(lstats_bw))

if(nrow(lstats_w1) < nrow_max)
  lstats_w1 <- add_row(lstats_w1, locus = rep(NA, nrow_max - nrow(lstats_w1)))
if(nrow(lstats_w2) < nrow_max)
  lstats_w2 <- add_row(lstats_w2, locus = rep(NA, nrow_max - nrow(lstats_w2)))
if(nrow(lstats_bw) < nrow_max)
  lstats_bw <- add_row(lstats_bw, locus = rep(NA, nrow_max - nrow(lstats_bw)))

lstats_final <- cbind(lstats_w1[, c('nvar_w1', 'dxy')],
                      lstats_w2[, c('nvar_w2', 'dxy')],
                      lstats_bw[, c('nvar_bw', 'dxy')])

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
lstats_smr %>% print(n = 50)


################################################################################
##### PLOTS #####
################################################################################
#ss <- filter(lstats_comb, my.stat %in% c('dxy', 'nvar_og'))
#ggplot(data = lstats) +
#  geom_point(aes(x = nvar_og, y = dxy))

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
  scale_x_continuous(expand = c(0, 0), limits = c(-1, 35)) +
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
  scale_x_continuous(expand = c(0, 0), limits = c(-0.1, 5)) +
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
#system(paste('rm', outfile_plot))
ggsave(outfile_plot, p, width = 8, height = 8)
system(paste('xdg-open', outfile_plot))


################################################################################
##### FILTER: MAX NR OF WITHIN-SP SNPS #####
################################################################################
#nrow_org2 <- nrow(lstats)
#lstats <- lstats %>% filter(nvar_w1 < maxvar, nvar_w2 < maxvar)
#nloci_rm_nsnp1 <- nrow_org2 - nrow(lstats)
#cat("#### Nr loci removed - too many SNPS:", nloci_rm_nsnp1, "\n")


################################################################################
##### FILTER: NR OF WITHIN-SP SNPS SHOULD BE SMALLER THAN WITH OUTGROUP #####
################################################################################
# nrow_org3 <- nrow(lstats)
# lstats <- lstats %>% filter(nvar_w1 <= dxy, nvar_w2 <= dxy)
# nloci_rm_nsnp2 <- nrow_org3 - nrow(lstats)
# nloci_rm_nsnp2 <- NA
# cat("#### Nr loci removed - more within than outgroup SNPS:", nloci_rm_nsnp2, "\n")
