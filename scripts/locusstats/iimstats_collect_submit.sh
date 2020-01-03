#!/bin/sh

################################################################################
#### SET-UP ####
################################################################################
## Command-line args:
SCR_STATS=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_collect.R
module load R

## Command-line args:
OUTFILE_LOCUSSTATS=$1
IG_GREP=$2
OG_GREP=$3
DIR_LOCUSFASTA_OG=$4
DIR_LOCUSFASTA_W1=$5
DIR_LOCUSFASTA_W2=$6
DIR_LOCUSFASTA_BW=$7
DXY_FILE=$8

## Report:
date
echo -e "\n#### iimstats_collect_submit.sh: Starting script."
echo -e "#### iimstats_collect_submit.sh: Output file with locus stats: $OUTFILE_LOCUSSTATS"
echo -e "#### iimstats_collect_submit.sh: Ingroup grep: $IG_GREP"
echo -e "#### iimstats_collect_submit.sh: Outgroup grep: $OG_GREP"
echo -e "#### iimstats_collect_submit.sh: Dir for og fasta: $DIR_LOCUSFASTA_OG"
echo -e "#### iimstats_collect_submit.sh: Dir for w1 fasta: $DIR_LOCUSFASTA_W2"
echo -e "#### iimstats_collect_submit.sh: Dir for w2 fasta: $DIR_LOCUSFASTA_W2"
echo -e "#### iimstats_collect_submit.sh: Dir for bw fasta: $DIR_LOCUSFASTA_BW"
echo -e "#### iimstats_collect_submit.sh: dxy file: $DXY_FILE \n"


################################################################################
#### REMOVE EMPTY FASTA FILES ####
################################################################################
echo -e "#### iimstats_collect_submit.sh: Finding empty fasta files..."
EMPTY_OG=$(find $DIR_LOCUSFASTA_OG -size -10c | wc -l)
EMPTY_W1=$(find $DIR_LOCUSFASTA_W1 -size -10c | wc -l)
EMPTY_W2=$(find $DIR_LOCUSFASTA_W2 -size -10c | wc -l)
EMPTY_BW=$(find $DIR_LOCUSFASTA_BW -size -10c | wc -l)
echo -e "#### iimstats_collect_submit.sh: Nr empty og fasta files: $EMPTY_OG"
echo -e "#### iimstats_collect_submit.sh: Nr empty w1 fasta files: $EMPTY_W1"
echo -e "#### iimstats_collect_submit.sh: Nr empty w2 fasta files: $EMPTY_W2"
echo -e "#### iimstats_collect_submit.sh: Nr empty bw fasta files: $EMPTY_BW"

echo -e "#### iimstats_collect_submit.sh: Removing empty files..."
[[ $EMPTY_OG != 0 ]] && echo "rm og..." && find $DIR_LOCUSFASTA_OG -size -10c -print0 | xargs -0 rm
[[ $EMPTY_W1 != 0 ]] && echo "rm w1..." && find $DIR_LOCUSFASTA_W1 -size -10c -print0 | xargs -0 rm
[[ $EMPTY_W2 != 0 ]] && echo "rm w2..." && find $DIR_LOCUSFASTA_W2 -size -10c -print0 | xargs -0 rm
[[ $EMPTY_BW != 0 ]] && echo "rm bw..." && find $DIR_LOCUSFASTA_BW -size -10c -print0 | xargs -0 rm


################################################################################
#### BASIC INFO ON FASTA FILES ####
################################################################################
echo -e "\n#### iimstats_collect_submit.sh: Getting basic info on fasta files..."
N_OG=$(ls -1 $DIR_LOCUSFASTA_OG | wc -l)
N_W1=$(ls -1 $DIR_LOCUSFASTA_W1 | wc -l)
N_W2=$(ls -1 $DIR_LOCUSFASTA_W2 | wc -l)
N_BW=$(ls -1 $DIR_LOCUSFASTA_BW | wc -l)
echo -e "#### iimstats_collect_submit.sh: Nr og fasta files: $N_OG"
echo -e "#### iimstats_collect_submit.sh: Nr w1 fasta files: $N_W1"
echo -e "#### iimstats_collect_submit.sh: Nr w2 fasta files: $N_W2"
echo -e "#### iimstats_collect_submit.sh: Nr bw fasta files: $N_BW"

FA_OG=$(ls -1 $DIR_LOCUSFASTA_OG/L*1*1* | head -n 1)
FA_W1=$(ls -1 $DIR_LOCUSFASTA_W1/L*1*1* | head -n 1)
FA_W2=$(ls -1 $DIR_LOCUSFASTA_W2/L*1*1* | head -n 1)
FA_BW=$(ls -1 $DIR_LOCUSFASTA_BW/L*1*1* | head -n 1)

echo -e "\n#### iimstats_collect_submit.sh: Inds in outgroup fasta:"
grep ">" $FA_OG
echo -e "\n#### iimstats_collect_submit.sh: Inds in within1 fasta:"
grep ">" $FA_W1
echo -e "\n#### iimstats_collect_submit.sh: Inds in within2 fasta:"
grep ">" $FA_W2
echo -e "\n#### iimstats_collect_submit.sh: Inds in between fasta:"
grep ">" $FA_BW


################################################################################
#### SUBMIT R SCRIPT ####
################################################################################
echo -e "\n#### iimstats_collect_submit.sh: Submitting R script..."
Rscript $SCR_STATS $OUTFILE_LOCUSSTATS $IG_GREP $OG_GREP \
	$DIR_LOCUSFASTA_OG $DIR_LOCUSFASTA_W1 $DIR_LOCUSFASTA_W2 $DIR_LOCUSFASTA_BW $DXY_FILE

## Report:
date
echo -e "\n#### iimstats_collect_submit.sh: Done with script."