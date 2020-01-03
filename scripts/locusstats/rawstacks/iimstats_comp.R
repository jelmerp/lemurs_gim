## Set-up:
setwd('/home/jelmer/Dropbox/sc_lemurs/')
library(tidyverse)

## Files:
indir_smr <- 'proj/iim/locusstats/summaries/'
outfile_smr <- 'proj/iim/locusstats/summaries/combined_summaries.txt'

## Collect summary files in one df:
smr_files <- list.files(indir_smr, pattern = 'smr.txt', full.names = TRUE)
smrs <- do.call(cbind, lapply(smr_files, read.delim))
to.rm <- grep('my.stat', colnames(smrs))
to.rm <- to.rm[2:length(to.rm)]
smrs <- smrs[, -to.rm]

## Write table:
write.table(smrs, outfile_smr,
            sep = '\t', quote = FALSE, row.names = FALSE)
