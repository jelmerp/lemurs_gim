################################################################################
##### SET-UP #####
################################################################################
setwd('/home/jelmer/Dropbox/sc_lemurs/')
library(tidyverse)

## Input files:
infile_inds <- 'radseq/metadata/lookup_IDshort.txt'
infile_bamsize <- ''

## Output files:
outdir_popmap <- 'proj/iim/indsel/stacks_popmap/'
if(!dir.exists(outdir_popmap)) dir.create(outdir_popmap, recursive = TRUE)

## Metadata:
inds <- read.delim(infile_inds, header = TRUE, as.is = TRUE) %>%
  select(ID, species.short, site)


################################################################################
##### GRI-MUR #####
################################################################################
grimur <- readLines('proj/hybridzone/metadata/indsel/gphocs/hz.mur3gri2c.indsel.txt')

## With rufus outgroup, gstacks:
grimurruf <- inds %>%
  filter(ID %in% c(grimur, 'mruf008')) %>%
  select(ID, species.short)
outfile_grimurruf.gstacks <- paste0(outdir_popmap, 'grimurruf.txt')
write.table(grimurruf, outfile_grimurruf.gstacks,
            sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)

## With rufus outgroup - popstacks selection 1:
grimurruf_popstacks <- grimurruf %>%
  filter(ID %in% c('mgri088', 'mmur052', 'mruf008'))
outfile_grimurruf.popstacks <- paste0(outdir_popmap, 'grimurruf.iim1.txt')
write.table(grimurruf_popstacks, outfile_grimurruf.popstacks,
            sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)

## With cheiro outgroup, gstacks:
grimurche <- inds %>%
  filter(ID %in% c(grimur, 'cmed001')) %>%
  select(ID, species.short)
outfile_grimurche.gstacks <- paste0(outdir_popmap, 'grimurche.txt')
write.table(grimurche, outfile_grimurche.gstacks,
            sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)

## With cheiro outgroup - popstacks selection 1:
grimurche_popstacks1 <- grimurche %>%
  filter(ID %in% c('mgri088', 'mmur052', 'cmed001'))
outfile_grimurche.popstacks <- paste0(outdir_popmap, 'grimurche.iim1.txt')
write.table(grimurche_popstacks1, outfile_grimurche.popstacks,
            sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)

## With cheiro outgroup - popstacks selection 1:
grimurche_popstacks2 <- grimurche %>%
  filter(ID %in% c('mgri051', 'mmur009', 'cmed001'))
outfile_grimurche.popstacks <- paste0(outdir_popmap, 'grimurche.iim2.txt')
write.table(grimurche_popstacks2, outfile_grimurche.popstacks,
            sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)


################################################################################
##### MUR-RAV #####
################################################################################
## Gstacks:
mursel <- c('mmur079', 'mmur083', 'mmur084')
murrav <- inds %>%
  filter(species.short == 'mrav' | ID %in% c(mursel, 'cmed001'))
murrav_gstacks <- murrav %>% select(ID, species.short)

outfile_murrav.gstacks <- paste0(outdir_popmap, 'murravche.txt')
write.table(murrav_gstacks, outfile_murrav.gstacks,
            sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)

## Popstacks - selection 1:
murrav_popstacks1 <- murrav_gstacks %>%
  filter(ID %in% c('mmur083', 'mrav004', 'cmed001'))

outfile_murrav.popstacks1 <- paste0(outdir_popmap, 'murravche.iim1.txt')
write.table(murrav_popstacks1, outfile_murrav.popstacks1,
            sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)

## Popstacks - selection 2:
murrav_popstacks2 <- murrav_gstacks %>%
  filter(ID %in% c('mmur079', 'mrav003', 'cmed001'))

outfile_murrav.popstacks2 <- paste0(outdir_popmap, 'murravche.iim2.txt')
write.table(murrav_popstacks2, outfile_murrav.popstacks2,
            sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)


################################################################################
##### CHEIRO #####
################################################################################
## Indsel and popmap for gstacks:
mursel <- c('mgri043', 'mgri044', 'mgri045', 'mmur009', 'mmur083')

ichei <- inds %>%
  filter(species.short == 'cmed' | site == 'Tsihomanaomby' | ID %in% mursel) %>%
  filter(species.short != 'mspt')
(cheiro_gstacks <- ichei %>% select(ID, species.short))

outfile_cheiro.gstacks <- paste0(outdir_popmap, 'cheiro_tsiho.txt')
write.table(cheiro_gstacks, outfile_cheiro.gstacks,
            sep = '\t', quote = FALSE, row.names = FALSE, col.names = FALSE)

outfile_ichei <- 'proj/iim/indsel/cheiro_all.txt'
writeLines(ichei$ID, outfile_ichei)

## cmaj-ccro


