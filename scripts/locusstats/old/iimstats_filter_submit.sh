#!/bin/bash
set -e
set -o pipefail
set -u

## Software and scripts:
module load R
SCR_FILTER=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_filter.R

## Command-line args:
SET_ID=$1
DIR_LOCUSSTATS=$2
MAXMISS=$3
MINDIST=$4

## Report:
date
echo -e "\n#### iimstats_filter_submit.sh: Starting script."
echo -e "#### iimstats_filter_submit.sh: Set ID: $SET_ID"
echo -e "#### iimstats_filter_submit.sh: Dir for locusstats: $DIR_LOCUSSTATS"
echo -e "#### iimstats_filter_submit.sh: Max % missing data: $MAXMISS \n"
echo -e "#### iimstats_filter_submit.sh: Min distance between loci: $MINDIST \n"

## Submit R script:
echo -e "\n#### iimstats_filter_submit.sh: Submitting R script..."
Rscript $SCR_STATS $SET_ID $IND1 $IND2 $DIR_LOCUSFASTA $DIR_LOCUSSTATS $DXY_FILE

## Report:
date
echo -e "\n#### iimstats_filter_submit.sh: Done with script."