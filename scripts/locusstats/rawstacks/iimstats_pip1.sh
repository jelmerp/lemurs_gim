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
FASTA_ORG=$1
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
FASTA_ED=$DIR_FASTA/$SET_ID/$SET_ID.fa
LOCUSLIST_DXY=$DIR_LOCUSSTATS/$SET_ID.locuslist_dxy.txt
LOCUSLIST_FASTA=$DIR_LOCUSSTATS/$SET_ID.locuslist_fasta.txt

## Report:
date
echo -e "\n#### iimstats_pip.sh: Starting script."
echo -e "#### iimstats_pip.sh: Set ID: $SET_ID"
echo -e "#### iimstats_pip.sh: Individual 1: $IND1"
echo -e "#### iimstats_pip.sh: Individual 2: $IND2"
echo -e "#### iimstats_pip.sh: Ingroup grep for fasta: $IG_GREP"
echo -e "#### iimstats_pip.sh: Outgroup grep for fasta: $OG_GREP"
echo -e "#### iimstats_pip.sh: Dir for locusstats: $DIR_LOCUSSTATS"
echo -e "#### iimstats_pip.sh: List with loci - dxy (to be made): $LOCUSLIST_DXY"
echo -e "#### iimstats_pip.sh: List with loci - fasta (to be made): $LOCUSLIST_FASTA"
echo -e "#### iimstats_pip.sh: Dir for output fasta - base: $DIR_FASTA"
echo -e "#### iimstats_pip.sh: First thousand: $FIRST_THOUSAND"
echo -e "#### iimstats_pip.sh: Last thousand (should be 'LAST' or a number): $LAST_THOUSAND_INIT"

echo -e "\n#### iimstats_pip.sh: Prep fasta (TRUE/FALSE): $PREPFASTA"
echo -e "\n#### iimstats_pip.sh: Split fasta (TRUE/FALSE): $SPLITFASTA"
echo -e "\n#### iimstats_pip.sh: Merge fasta (TRUE/FALSE): $MERGE_STATS"

echo -e "\n#### iimstats_pip.sh: Dxy file:"
ls -lh $DXY_FILE
echo -e "\n#### iimstats_pip.sh: Input (merged) fasta file:"
ls -lh $FASTA_ORG
printf "\n"


################################################################################
#### MERGED FASTA PREP ####
################################################################################
## Create new fasta with changed locus names:
if [ $PREPFASTA == "TRUE" ]
then
	echo -e "#### iimstats_pip.sh: Creating new fasta file with changed locus names..."
	sed 's/ //g' $FASTA_ORG | sed -E 's/.*_(Locus_[0-9]+)_Allele_([0-9])\[(.*);.*/>\1_\3_\2/' | sed 's/_//' > $FASTA_ED
	
	echo -e "\n#### iimstats_pip.sh: Creating list of loci from dxy file..."
	grep -v "#" $DXY_FILE | cut -f 1 > $LOCUSLIST_DXY
	NR_LOCI_DXY=$(cat $LOCUSLIST_DXY | wc -l)
	echo -e "#### iimstats_pip.sh: Number of loci - dxy file: $NR_LOCI_DXY \n"
		
	echo -e "#### iimstats_pip.sh: Creating list of loci from fasta file..."
	grep "Locus" $FASTA_ED | sed -E 's/>(Locus[0-9]+)_.*/\1/' | uniq > $LOCUSLIST_FASTA
	NR_LOCI_FASTA=$(cat $LOCUSLIST_FASTA | wc -l)
	echo -e "#### iimstats_pip.sh: Number of loci - fasta file: $NR_LOCI_FASTA \n"
else
	echo -e "#### iimstats_pip.sh: Skipping fasta prep..."
fi

## Create list of loci:
if [ -s $DXY_FILE ]
then
	echo "#### iimstats_pip.sh: USING DXY LOCI..."
	LOCUSLIST=$LOCUSLIST_DXY
	NR_LOCI=$NR_LOCI_DXY
else
	echo "#### iimstats_pip.sh: USING FASTA LOCI..."
	LOCUSLIST=$LOCUSLIST_FASTA
	NR_LOCI=$NR_LOCI_FASTA
fi
	
echo -e "\n#### iimstats_pip.sh: Edited fasta..."
ls -lh $FASTA_ED


################################################################################
#### GET SINGLE-LOCUS FASTA FILES ####
################################################################################
if [ $SPLITFASTA == "TRUE" ]
then
	echo -e "\n#### iimstats_pip.sh: Submitting a split-fasta job per set of 1k loci..."
	
	[[ $LAST_THOUSAND_INIT == "LAST" ]] && LAST_THOUSAND=$(($(($NR_LOCI / 1000)) + 1))
	[[ $LAST_THOUSAND_INIT != "LAST" ]] && LAST_THOUSAND=$LAST_THOUSAND_INIT
	echo -e "#### iimstats_pip.sh: Last thousand: $LAST_THOUSAND"
	
	for THOUSAND in $(seq $FIRST_THOUSAND $LAST_THOUSAND)
	do
		LAST=$(($THOUSAND * 1000))
		FIRST=$(($LAST - 999))
		[[ $THOUSAND == $LAST_THOUSAND && $LAST_THOUSAND_INIT == "LAST" ]] && LAST=$NR_LOCI
		echo -e "\n#### First: $FIRST / Last: $LAST"
	
		sbatch -p yoderlab,common,scavenger -o slurm.iimstats_pip2.$SET_ID.$THOUSAND --job-name=iimstats.$SET_ID \
		$SCR_PIP2 $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_ED $LOCUSLIST $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST $LAST $THOUSAND
	done
else
	echo -e "\n#### iimstats_pip.sh: NOT splitting fasta..."
fi


################################################################################
#### MERGE LOCUS-STATS AND FILTER LOCI ####
################################################################################
if [ $MERGE_STATS == "TRUE" ]
then
	MAXMISS=5
	MINDIST=10000
	
	echo -e "\n#### iimstats_pip.sh: Merging locusstats..."
	sbatch -p yoderlab,common,scavenger -o slurm.iimstats.filter.$SET_ID --job-name=iimstats.$SET_ID --dependency=singleton \
	$SCR_FILTER_SUBMIT $SET_ID $DIR_LOCUSSTATS $MAXMISS $MINDIST
else
	echo -e "\n#### iimstats_pip.sh: NOT merging locusstats..."
fi

## Report:
echo -e "\n#### iimstats_pip.sh: Done with script."
date
