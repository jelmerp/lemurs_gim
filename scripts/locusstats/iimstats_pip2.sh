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
FASTA_IN=$1
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
NUCDIVSTATS_SPLIT=$DIR_LOCUSSTATS/split/$SET_ID.$THOUSAND.nucdiv.txt

DIR_LOCUSFASTA_W1=$DIR_FASTA/$SET_ID/w1/$THOUSAND/
DIR_LOCUSFASTA_W2=$DIR_FASTA/$SET_ID/w2/$THOUSAND/
DIR_LOCUSFASTA_BW=$DIR_FASTA/$SET_ID/bw/$THOUSAND/
DIR_LOCUSFASTA_OG=$DIR_FASTA/$SET_ID/og/$THOUSAND/

[[ ! -d $DIR_LOCUSFASTA_W1 ]] && mkdir -p $DIR_LOCUSFASTA_W1
[[ ! -d $DIR_LOCUSFASTA_W2 ]] && mkdir -p $DIR_LOCUSFASTA_W2
[[ ! -d $DIR_LOCUSFASTA_BW ]] && mkdir -p $DIR_LOCUSFASTA_BW
[[ ! -d $DIR_LOCUSFASTA_OG ]] && mkdir -p $DIR_LOCUSFASTA_OG
[[ ! -d $DIR_LOCUSSTATS/split ]] && mkdir -p $DIR_LOCUSSTATS/split

rm -f $DIR_LOCUSFASTA_W1/*
rm -f $DIR_LOCUSFASTA_W2/*
rm -f $DIR_LOCUSFASTA_BW/*
rm -f $DIR_LOCUSFASTA_OG/*

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
echo -e "#### iimstats_pip2.sh: Dxy file: $DXY_FILE"
echo -e "#### iimstats_pip2.sh: First: $FIRST"
echo -e "#### iimstats_pip2.sh: Last: $LAST"
echo -e "#### iimstats_pip2.sh: Thousand: $THOUSAND"
[[ -s $DXY_FILE ]] && echo -e "\n#### iimstats_pip2.sh: Dxy file:" && ls -lh $DXY_FILE

echo -e "\n#### iimstats_pip2.sh: Input (merged) fasta file:"
ls -lh $FASTA_IN
printf "\n"


################################################################################
#### SPLIT FASTA ####
################################################################################
if [ $SPLIT_FASTA == 'TRUE' ]
then
	echo -e "\n#### iimstats_pip2.sh: Splitting fasta files..."
	$SCR_SPLIT $IND1 $IND2 $LOCUSLIST $FASTA_IN $DIR_LOCUSFASTA_OG $DIR_LOCUSFASTA_W1 $DIR_LOCUSFASTA_W2 $DIR_LOCUSFASTA_BW $FIRST $LAST
else
	echo -e "\n#### iimstats_pip2.sh: SKIPPING split fasta..."
fi


################################################################################
#### GET LOCUS-STATS ####
################################################################################
echo -e "\n#### iimstats_pip2.sh: Getting stats on fasta loci..."
$SCR_STATS_SUBMIT $NUCDIVSTATS_SPLIT $IG_GREP $OG_GREP $DIR_LOCUSFASTA_OG $DIR_LOCUSFASTA_W1 $DIR_LOCUSFASTA_W2 $DIR_LOCUSFASTA_BW $DXY_FILE


################################################################################
#### FILTER LOCUS-STATS ####
################################################################################
### TO DO


## Report:
echo -e "\n#### iimstats_pip2.sh: Done with script."
date
