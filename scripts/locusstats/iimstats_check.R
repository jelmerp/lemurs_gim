## Looking at the "grimurche2 unmasked" data, there are 39 loci where the number
## of within- or between-species differences exceeds the distance with the outgroup,
## in some cases substantially so.
## The most extreme case in the within-species 1 comparisons is locus 1355,
## with 9 within-species differences compared to an outgroup distance of only 1.82.
## Similarly, among the between-species comparisons, locus 671 has 6 between-species
## differences compared to an outgroup distance of only 1.35.

## Set-up:
library(tidyverse)
setwd('Dropbox/sc_lemurs/proj/iim/locusstats/')

infile_lstats <- 'final/grimurche.iim2.unmasked.iimstats.txt'

##
lstats_tmp <- read.delim(infile_lstats, header = TRUE, as.is = TRUE)
lstats_tmp[1355, ] #L102191
lstats_tmp[671, ] #L102191
