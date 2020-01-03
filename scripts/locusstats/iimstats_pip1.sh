#!/bin/bash
set -e
set -o pipefail
set -u

################################################################################
#### SET-UP ####
################################################################################
## Software and scripts:
SCR_PIP2=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_pip2.sh
SCR_FILTER_SUBMIT=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_filter_submit.sh
SCR_MERGESTATS=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_mergestats.sh

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
DIR_FASTA=$1
shift
DIR_LOCUSSTATS=$1
shift
DXY_FILE=$1
shift
FIRST_THOUSAND=$1 # Integer, group of thousand to start with
shift
LAST_THOUSAND_INIT=$1 # Integer or "LAST" to go until end
shift

SPLITFASTA='TRUE'
PREPFASTA='TRUE'
MERGE_STATS='TRUE'

while getopts 'MPS' flag; do
  case "${flag}" in
    S) SPLITFASTA='FALSE' ;;
    P) PREPFASTA='FALSE' ;;
    M) MERGE_STATS='FALSE' ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

## Process args:
LOCUSLIST=$DIR_LOCUSSTATS/$SET_ID.locuslist.txt
LOCUSSTATS_ALL=$DIR_LOCUSSTATS/$SET_ID.nucdiv.txt

## Report:
date
echo -e "#### iimstats_pip1.sh: Starting script."
echo -e "#### iimstats_pip1.sh: Set ID: $SET_ID"
echo -e "#### iimstats_pip1.sh: Individual 1: $IND1"
echo -e "#### iimstats_pip1.sh: Individual 2: $IND2"
echo -e "#### iimstats_pip1.sh: Ingroup grep for fasta: $IG_GREP"
echo -e "#### iimstats_pip1.sh: Outgroup grep for fasta: $OG_GREP"
echo -e "#### iimstats_pip1.sh: Input fasta: $FASTA_IN"
echo -e "#### iimstats_pip1.sh: Dir for locusstats: $DIR_LOCUSSTATS"
echo -e "#### iimstats_pip1.sh: Dir for output fasta - base: $DIR_FASTA"
echo -e "#### iimstats_pip1.sh: First thousand: $FIRST_THOUSAND"
echo -e "#### iimstats_pip1.sh: Last thousand (should be 'LAST' or a number): $LAST_THOUSAND_INIT"
printf "\n"
echo -e "#### iimstats_pip1.sh: List with loci (to be made): $LOCUSLIST"
echo -e "#### iimstats_pip1.sh: Final locusstats output file: $LOCUSSTATS_ALL"
printf "\n"
echo -e "#### iimstats_pip1.sh: Prep fasta (TRUE/FALSE): $PREPFASTA"
echo -e "#### iimstats_pip1.sh: Split fasta (TRUE/FALSE): $SPLITFASTA"
echo -e "#### iimstats_pip1.sh: Merge fasta (TRUE/FALSE): $MERGE_STATS"

if [ $DXY_FILE != "notany" ]
then
	echo -e "\n#### iimstats_pip1.sh: Dxy file:"
	ls -lh $DXY_FILE
fi

echo -e "\n#### iimstats_pip1.sh: Input (merged) fasta file:"
ls -lh $FASTA_IN

echo -e "\n#### iimstats_pip1.sh: Creating locuslist..."
grep ">L" $FASTA_IN | sed -E 's/>(L[0-9]+)_.*/\1/' | sort | uniq > $LOCUSLIST
NR_LOCI=$(cat $LOCUSLIST | wc -l)
echo -e "\n#### iimstats_pip1.sh: Number of loci: $NR_LOCI"


################################################################################
#### SPLIT FASTA INTO SINGLE-LOCUS FILES & GET NUCDIV PER LOCUS ####
################################################################################
if [ $SPLITFASTA == "TRUE" ]
then
	echo -e "\n#### iimstats_pip1.sh: Submitting a job split-fasta & get nucdiv per set of 1k loci..."
	
	rm -f $DIR_LOCUSSTATS/split/* # Remove any old locusstats
	
	[[ $LAST_THOUSAND_INIT == "LAST" ]] && LAST_THOUSAND=$(($(($NR_LOCI / 1000)) + 1))
	[[ $LAST_THOUSAND_INIT != "LAST" ]] && LAST_THOUSAND=$LAST_THOUSAND_INIT
	echo -e "#### iimstats_pip1.sh: Last thousand: $LAST_THOUSAND"
	
	for THOUSAND in $(seq $FIRST_THOUSAND $LAST_THOUSAND)
	do
		#THOUSAND=1
		LAST=$(($THOUSAND * 1000))
		FIRST=$(($LAST - 999))
		[[ $THOUSAND == $LAST_THOUSAND && $LAST_THOUSAND_INIT == "LAST" ]] && LAST=$NR_LOCI
		echo -e "\n#### First: $FIRST / Last: $LAST"
	
		sbatch -p yoderlab,common,scavenger -o slurm.iimstats_pip2.$SET_ID.$THOUSAND --job-name=iimstats.$SET_ID \
		$SCR_PIP2 $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $LOCUSLIST $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST $LAST $THOUSAND
	done
else
	echo -e "\n#### iimstats_pip1.sh: NOT splitting fasta & getting nucdiv..."
fi


################################################################################
#### MERGE LOCUS-STATS ####
################################################################################
if [ $MERGE_STATS == "TRUE" ]
then
	echo -e "\n#### iimstats_pip1.sh: Submitting job to merge stats:"
	
	sbatch -p yoderlab,common,scavenger -o slurm.iimstats.merge.$SET_ID \
		--dependency=singleton --job-name=iimstats.$SET_ID \
		$SCR_MERGESTATS $SET_ID $DIR_LOCUSSTATS $LOCUSSTATS_ALL
else
	echo -e "\n#### iimstats_pip1.sh: NOT merging locus-stats..."
fi


## Report:
echo -e "\n#### iimstats_pip1.sh: Done with script."
date
