#!/bin/bash
set -e
set -o pipefail
set -u

## Command-line args:
STATSDIR_LOCUS=$1
OUTFILE_FINALSTATS=$2

## Report:
echo -e "\n#### iimstats_collect: Starting with script."
date
echo "#### iimstats_collect: Node name: $SLURMD_NODENAME"
printf "\n"
echo "#### iimstats_collect: Dir with per-locus stats: $STATSDIR_LOCUS"
echo "#### iimstats_collect: Output file with final stats: $OUTFILE_FINALSTATS"

## Concatenate:
echo -e "\n#### iimstats_collect: Concatenating stats..."
find $STATSDIR_LOCUS -type f -name "*stats.txt" -print0 | xargs -0 cat > $OUTFILE_FINALSTATS

## Remove per-locus files:
[[ -s $OUTFILE_FINALSTATS ]] && echo "#### iimstats_collect: Removing by-locus files..." && rm -r $STATSDIR_LOCUS

## Report:
echo -e "\n#### iimstats_collect: File with final locus-stats:"
ls -lh $OUTFILE_FINALSTATS

echo -e "\n\n#### iimstats_collect.sh: Done with script."
date