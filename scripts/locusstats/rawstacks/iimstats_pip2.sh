#!/bin/bash
set -e
set -o pipefail
set -u

################################################################################
#### SET-UP ####
################################################################################
## Software and scripts:
SCR_SPLIT=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_splitfasta.sh
SCR_STATS_SUBMIT=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_collect_submit.sh

## Command-line args:
SET_ID=$1
shift
IND1=$1
shift
IND2=$1
shift
IG_GREP=$1
shift
OG_GREP=$1
shift
FASTA_ED=$1
shift
LOCUSLIST=$1
shift
DIR_FASTA=$1
shift
DIR_LOCUSSTATS=$1
shift
DXY_FILE=$1
shift
FIRST=$1
shift
LAST=$1
shift
THOUSAND=$1
shift

SPLIT_FASTA='TRUE'
while getopts 'S' flag; do
  case "${flag}" in
    S) SPLIT_FASTA='FALSE' ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

## Process args:
LOCUSSTATS_RAW=$DIR_LOCUSSTATS/split/$SET_ID.$THOUSAND.locusstats.txt

DIR_LOCUSFASTA_OG=$DIR_FASTA/$SET_ID/og/$THOUSAND/
DIR_LOCUSFASTA_W1=$DIR_FASTA/$SET_ID/w1/$THOUSAND/
DIR_LOCUSFASTA_W2=$DIR_FASTA/$SET_ID/w2/$THOUSAND/
DIR_LOCUSFASTA_BW=$DIR_FASTA/$SET_ID/bw/$THOUSAND/
		
[[ ! -d $DIR_LOCUSFASTA_OG ]] && mkdir -p $DIR_LOCUSFASTA_OG
[[ ! -d $DIR_LOCUSFASTA_W1 ]] && mkdir -p $DIR_LOCUSFASTA_W1
[[ ! -d $DIR_LOCUSFASTA_W2 ]] && mkdir -p $DIR_LOCUSFASTA_W2
[[ ! -d $DIR_LOCUSFASTA_BW ]] && mkdir -p $DIR_LOCUSFASTA_BW
[[ ! -d $DIR_LOCUSSTATS/split ]] && mkdir -p $DIR_LOCUSSTATS/split

## Report:
date
echo -e "\n#### iimstats_pip2.sh: Starting script."
echo -e "#### iimstats_pip2.sh: Set ID: $SET_ID"
echo -e "#### iimstats_pip2.sh: Individual 1: $IND1"
echo -e "#### iimstats_pip2.sh: Individual 2: $IND2"
echo -e "#### iimstats_pip2.sh: Ingroup grep for fasta: $IG_GREP"
echo -e "#### iimstats_pip2.sh: Outgroup grep for fasta: $OG_GREP"
echo -e "#### iimstats_pip2.sh: List with loci: $LOCUSLIST"
echo -e "#### iimstats_pip2.sh: Dir for output fasta - base: $DIR_FASTA"
echo -e "#### iimstats_pip2.sh: Dir for output fasta - og : $DIR_LOCUSFASTA_OG"
echo -e "#### iimstats_pip2.sh: Dir for output fasta - w1: $DIR_LOCUSFASTA_W1"
echo -e "#### iimstats_pip2.sh: Dir for output fasta - w2: $DIR_LOCUSFASTA_W2"
echo -e "#### iimstats_pip2.sh: Dir for output fasta - bw: $DIR_LOCUSFASTA_BW"
echo -e "#### iimstats_pip2.sh: Dir for locusstats: $DIR_LOCUSSTATS"
echo -e "#### iimstats_pip2.sh: First: $FIRST"
echo -e "#### iimstats_pip2.sh: Last: $LAST"
echo -e "#### iimstats_pip2.sh: Thousand: $THOUSAND"
echo -e "\n#### iimstats_pip2.sh: Dxy file:"
ls -lh $DXY_FILE
echo -e "\n#### iimstats_pip2.sh: Input (merged) fasta file:"
ls -lh $FASTA_ED
printf "\n"


################################################################################
#### SPLIT FASTA ####
################################################################################
echo -e "\n#### iimstats_pip2.sh: Splitting fasta files..."
$SCR_SPLIT $IND1 $IND2 $LOCUSLIST $FASTA_ED $DIR_LOCUSFASTA_OG $DIR_LOCUSFASTA_W1 $DIR_LOCUSFASTA_W2 $DIR_LOCUSFASTA_BW $FIRST $LAST


################################################################################
#### GET LOCUS-STATS ####
################################################################################
echo -e "\n#### iimstats_pip2.sh: Getting stats on fasta loci..."
$SCR_STATS_SUBMIT $LOCUSSTATS_RAW $IG_GREP $OG_GREP $DIR_LOCUSFASTA_OG $DIR_LOCUSFASTA_W1 $DIR_LOCUSFASTA_W2 $DIR_LOCUSFASTA_BW $DXY_FILE


## Report:
echo -e "\n#### iimstats_pip2.sh: Done with script."
date
