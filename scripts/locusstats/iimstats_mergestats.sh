#!/bin/bash
set -e
set -o pipefail
set -u

## Command-line args:
SET_ID=$1
shift
DIR_LOCUSSTATS=$1
shift
LOCUSSTATS_ALL=$1
shift

## Report:
date
echo -e "#### iimstats_mergestats.sh: Starting script."
echo -e "#### iimstats_mergestats.sh: SetID: $SET_ID"
echo -e "#### iimstats_mergestats.sh: Locusstats dir: $DIR_LOCUSSTATS"
echo -e "#### iimstats_mergestats.sh: Concatenated locusstats: $LOCUSSTATS_ALL \n"

## Merge stats files:
echo -e "#### iimstats_mergestats.sh: Concatenating locus-stats files..."
cat $DIR_LOCUSSTATS/split/$SET_ID*nucdiv.txt > $LOCUSSTATS_ALL
	
## Report:
echo -e "\n#### iimstats_mergestats.sh: Listing merged locus-stats file:"
ls -lh $LOCUSSTATS_ALL

echo -e "\n#### iimstats_mergestats.sh: Number of lines in merged locus-stats file:"
cat $LOCUSSTATS_ALL | wc -l

echo -e "\n#### iimstats_mergestats.sh: Done with script."
date