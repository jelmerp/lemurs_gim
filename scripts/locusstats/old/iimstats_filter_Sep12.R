## (TO DO: Filter by HWE? ... from Stacks stats - probably not)
## TO DO: Filter by phasing? How to know which were successfully phased?

################################################################################
##### SET-UP #####
################################################################################
## Files and dirs, part 1:
setwd('/home/jelmer/Dropbox/sc_lemurs/')
indir_stats <- 'proj/iim/locusstats/raw/'
outdir_stats <- 'proj/iim/locusstats/final'
outdir_stats_smr <- 'proj/iim/locusstats/summaries/'
if(!dir.exists(outdir_stats)) dir.create(outdir_stats, recursive = TRUE)
if(!dir.exists(outdir_stats_smr)) dir.create(outdir_stats_smr, recursive = TRUE)

## Set ID:
#setID <- 'murravche.iim1'
setID <- 'grimurruf.iim1'
#setID <- 'grimurche.iim1'

## Other setings:
maxmiss <- 5 # Max missing data (Ns) in %
maxvar <- 10
mindist <- 10000 # In bp
scaffolds.rm <- c('Super_Scaffold0', 'NC_028718.1', 'NC_033692.1')

## Files and dirs, part 2:
infile_stats <- paste0(indir_stats, setID, '.locusstats.txt')
outfile_lstats <- paste0(outdir_stats, '/', setID, '.iimstats.txt')
outfile_lstats_smr <- paste0(outdir_stats_smr, '/', setID, '.iimstats.smr.txt')
outfile_plot <- paste0(outdir_stats_smr, '/', setID, 'sumr.plot.png')

## Packages:
library(tidyverse)


################################################################################
##### PREP DF #####
################################################################################
lstats_raw <- read.delim(infile_stats, sep = " ", header = FALSE, as.is = TRUE)

colnames(lstats_raw) <- c('locus', 'scaffold', 'start', 'length',
                          'var_w1', 'var_w2', 'var_bw', 'var_og',
                          'miss_w1', 'miss_w2', 'miss_bw', 'miss_og')

lstats <- lstats_raw %>%
  filter(!is.na(start)) %>%
  mutate(start = as.integer(start), length = as.integer(length)) %>%
  arrange(scaffold, start)

cat("\n#### Nr loci in original df:", nrow(lstats), '\n')


################################################################################
##### FILTER BY MISSING DATA #####
################################################################################
nrow_org <- nrow(lstats)
lstats <- lstats %>%
  filter(miss_w1 < maxmiss, miss_w2 < maxmiss,
         miss_bw < maxmiss, miss_og < maxmiss)
cat("\n#### Nr loci removed - missing data:", nrow_org - nrow(lstats), '\n')


################################################################################
##### FILTER BY MAX NR OF WITHIN-SP SNPS #####
################################################################################
nrow_org2 <- nrow(lstats)
lstats <- lstats %>%
  filter(var_w1 < maxvar, var_w2 < maxvar)
cat("\n#### Nr loci removed - too many SNPS:", nrow_org2 - nrow(lstats), '\n')


################################################################################
##### FILTER BY SCAFFOLD #####
################################################################################
nrow_org3 <- nrow(lstats)
lstats <- lstats %>%
  filter(! scaffold %in% scaffolds.rm)
cat("\n#### Nr loci removed - scaffold ID:", nrow_org3 - nrow(lstats), '\n')


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
filter_proxim <- function(my.lstats, my.mindist = mindist) {
  #my.lstats <- lstats_w1; my.mindist <- mindist

  my.lstats <- my.lstats %>%
    arrange(scaffold, start) %>%
    group_by(scaffold) %>%
    mutate(distToNext = lead(start) - (start + length)) %>% # Include distance-to-next locus
    ungroup()

  close.loc1.idx <- which(my.lstats$distToNext < my.mindist)
  close.loc2.idx <- close.loc1.idx + 1

  close <- cbind(my.lstats[close.loc1.idx, c("locus", "miss_bw")],
                 my.lstats[close.loc2.idx, c("locus", "miss_bw")])
  colnames(close) <- c('loc1', 'miss_bw1', 'loc2', 'miss_bw2')

  close.rm <- unique(c(close$loc1[which(close$miss_bw1 > close$miss_bw2)],
                       close$loc2[which(close$miss_bw1 <= close$miss_bw2)]))

  my.lstats_filt <- my.lstats %>% filter(! locus %in% close.rm)

  cat("\n#### Nr loci input:", nrow(my.lstats), '\n')
  cat("#### Nr loci output:", nrow(my.lstats_filt), '\n')
  cat("#### Nr loci removed due to close proximity:", length(close.rm), '\n')

  return(my.lstats_filt)
}

lstats_w1 <- lstats_w1 %>%
  filter_proxim() %>%
  filter_proxim() %>%
  filter_proxim()

lstats_w2 <- lstats_w2 %>%
  filter_proxim() %>%
  filter_proxim() %>%
  filter_proxim()

lstats_bw <- lstats_bw %>%
  filter_proxim() %>%
  filter_proxim() %>%
  filter_proxim()


################################################################################
##### EXPLORE FINAL SET OF LOCI #####
################################################################################
cat("\n#### Nr loci (w1, w2, bw):",
    nrow(lstats_w1), nrow(lstats_w2), nrow(lstats_bw), '\n')

lstats_comb <- rbind(lstats_w1, lstats_w2, lstats_bw) %>%
  select(-distToNext) %>%
  gather(key = my.stat, value = my.val,
         length, var_w1, var_w2, var_bw, var_og,
         miss_w1, miss_w2, miss_bw, miss_og)

lstats_smr <- lstats_comb %>%
  group_by(my.stat) %>%
  summarize(my.val = round(mean(my.val, na.rm = TRUE), 3))

my.stat <- c('n_w1', 'n_w2', 'n_bw')
my.val <- c(nrow(lstats_w1), nrow(lstats_w2), nrow(lstats_bw))
nloci <- data.frame(my.stat, my.val)
(lstats_smr <- rbind(lstats_smr, nloci))


################################################################################
##### PLOTS #####
################################################################################
library(grid)
library(gridExtra)
library(ggpubr)
library(cowplot)
library(scales) # For comma in 1000s

## Locus length:
(plength <- ggplot(data = filter(lstats_comb, my.stat == 'length')) +
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
        plot.margin = margin(1.5, 0.5, 0.5, 0.5, "cm")))

## Number of loci:
nloci_max <- max(nloci$my.val)
my.breaks <- c(seq(0, nloci_max, by = 5000), nloci_max)

(ploc <- ggplot(nloci) +
    geom_bar(aes(x = my.stat, y = my.val), stat = 'identity') +
    scale_x_discrete(labels = c('between', 'within1', 'within2')) +
    scale_y_continuous(label = comma, expand = c(0, 0),
                       breaks = my.breaks) +
    labs(y = 'Number of loci') +
    theme_bw() +
    theme(axis.text = element_text(size = 15),
          axis.title.x = element_blank(),
          axis.title.y = element_text(size = 18),
          plot.margin = margin(1.5, 0.5, 0.5, 0.5, "cm")))

## Pairwise differences:
(pvar <- ggplot(data = filter(lstats_comb, grepl('var', my.stat))) +
  geom_histogram(aes(my.val, fill = my.stat)) +
  labs(x = 'Pairwise differences') +
  scale_x_continuous(expand = c(0, 0), limits = c(-1, 35)) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_fill_discrete(breaks = c('var_w1', 'var_w2', 'var_bw', 'var_og'),
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
        plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm")))

## Missing data:
(pmiss <- ggplot(data = filter(lstats_comb, grepl('miss', my.stat))) +
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
        plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm")))

p <- ggarrange(plength, ploc, pmiss, pvar, ncol = 2, nrow = 2)
p <- p + draw_plot_label(label = setID, x = 0.3, y = 1, size = 20)
ggsave(outfile_plot, p, width = 8, height = 8)
system(paste('xdg-open', outfile_plot))


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

lstats_final <- cbind(lstats_w1[, c('var_w1', 'var_og')],
                      lstats_w2[, c('var_w2', 'var_og')],
                      lstats_bw[, c('var_bw', 'var_og')])

## Column names:
colnames(lstats_final) <- c('within_1', 'outgroup_1',
                            'within_2', 'outgroup_2',
                            'between_3', 'outgroup_3')

## Write file:
write.table(lstats_final, outfile_lstats,
            sep = '\t', quote = FALSE, row.names = FALSE)
write.table(lstats_smr, outfile_lstats_smr,
            sep = '\t', quote = FALSE, row.names = FALSE)
