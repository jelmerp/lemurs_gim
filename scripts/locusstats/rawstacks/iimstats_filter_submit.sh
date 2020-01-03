#!/bin/bash
set -e
set -o pipefail
set -u

################################################################################
#### SET-UP ####
################################################################################
## Command-line args:
module load R
SCR_FILTER=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_filter.R

## Command-line args:
SET_ID=$1
DIR_LOCUSSTATS=$2
MAXMISS=$3
MINDIST=$4

## Process:
LOCUSSTATS_ALL=$DIR_LOCUSSTATS/raw/$SET_ID.locusstats.txt

## Report:
date
echo -e "\n#### iimstats_filter_submit.sh: Starting script."
echo -e "#### iimstats_filter_submit.sh: Set ID: $SET_ID"
echo -e "#### iimstats_filter_submit.sh: Dir for locusstats: $DIR_LOCUSSTATS"
echo -e "#### iimstats_filter_submit.sh: Max % missing data: $MAXMISS"
echo -e "#### iimstats_filter_submit.sh: Min distance between loci: $MINDIST \n"
echo -e "#### iimstats_filter_submit.sh: Merged locusstats file: $LOCUSSTATS_ALL \n"


################################################################################
#### MERGE LOCUSSTATS ####
################################################################################
cat $DIR_LOCUSSTATS/split/$SET_ID*locusstats.txt > $LOCUSSTATS_ALL

echo -e "#### iimstats_filter_submit.sh: Listing merged locusstats file:\n"
ls -lh $LOCUSSTATS_ALL
echo -e "#### iimstats_filter_submit.sh: Number of lines in merged locusstats file:\n"
wc -l $LOCUSSTATS_ALL


################################################################################
#### FILTER LOCUSSTATS ####
################################################################################
echo -e "\n#### iimstats_filter_submit.sh: Submitting R script..."
Rscript $SCR_FILTER $SET_ID $DIR_LOCUSSTATS $MAXMISS $MINDIST


## Report:
date
echo -e "\n#### iimstats_filter_submit.sh: Done with script."