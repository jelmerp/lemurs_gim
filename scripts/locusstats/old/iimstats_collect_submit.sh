#!/bin/bash
set -e
set -o pipefail
set -u

## Software and scripts:
SCR_STATS=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_collect.R
module load R

## Command-line args:
SET_ID=$1
IND1=$2
IND2=$3
DIR_LOCUSFASTA=$4
DIR_LOCUSSTATS=$5
DXY_FILE=$6

## Report:
date
echo -e "\n#### iimstats_collect_submit.sh: Starting script."
echo -e "#### iimstats_collect_submit.sh: Set ID: $SET_ID"
echo -e "#### iimstats_collect_submit.sh: Individual 1: $IND1"
echo -e "#### iimstats_collect_submit.sh: Individual 2: $IND2"
echo -e "#### iimstats_collect_submit.sh: Dir for fasta: $DIR_LOCUSFASTA"
echo -e "#### iimstats_collect_submit.sh: Dir for locusstats: $DIR_LOCUSSTATS"
echo -e "#### iimstats_collect_submit.sh: dxy file: $DXY_FILE \n"

## Submit R script:
echo -e "\n#### iimstats_collect_submit.sh: Submitting R script..."
Rscript $SCR_STATS $SET_ID $IND1 $IND2 $DIR_LOCUSFASTA $DIR_LOCUSSTATS $DXY_FILE

## Report:
date
echo -e "\n#### iimstats_collect_submit.sh: Done with script."
