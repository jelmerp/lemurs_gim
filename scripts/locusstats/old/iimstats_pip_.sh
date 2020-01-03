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
STOP_AT=$1
shift

SPLIT_FASTA='TRUE'
SKIP_FASTA_RENAME='FALSE'
while getopts 'SR' flag; do
  case "${flag}" in
    S) SPLIT_FASTA='FALSE' ;;
    R) SKIP_FASTA_RENAME='TRUE' ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

## Process args:
FASTA_ED=$DIR_FASTA/$SET_ID/$SET_ID.fa

LOCUSLIST=$DIR_LOCUSSTATS/$SET_ID.locuslist.txt
LOCUSLIST_FASTA=$DIR_LOCUSSTATS/$SET_ID.locuslist_fasta.txt
LOCUSSTATS_RAW=$DIR_LOCUSSTATS/raw/$SET_ID.locusstats.txt

DIR_LOCUSFASTA_OG=$DIR_FASTA/$SET_ID/og/
DIR_LOCUSFASTA_W1=$DIR_FASTA/$SET_ID/w1/
DIR_LOCUSFASTA_W2=$DIR_FASTA/$SET_ID/w2/
DIR_LOCUSFASTA_BW=$DIR_FASTA/$SET_ID/bw/

[[ ! -d $DIR_LOCUSSTATS/$SET_ID/raw ]] && mkdir -p $DIR_LOCUSSTATS/raw
[[ ! -d $DIR_LOCUSFASTA_OG ]] && mkdir -p $DIR_LOCUSFASTA_OG
[[ ! -d $DIR_LOCUSFASTA_W1 ]] && mkdir -p $DIR_LOCUSFASTA_W1
[[ ! -d $DIR_LOCUSFASTA_W2 ]] && mkdir -p $DIR_LOCUSFASTA_W2
[[ ! -d $DIR_LOCUSFASTA_BW ]] && mkdir -p $DIR_LOCUSFASTA_BW

## Report:
date
echo -e "\n#### iimstats_pip.sh: Starting script."
echo -e "#### iimstats_pip.sh: Set ID: $SET_ID"
echo -e "#### iimstats_pip.sh: Individual 1: $IND1"
echo -e "#### iimstats_pip.sh: Individual 2: $IND2"
echo -e "#### iimstats_pip.sh: Ingroup grep for fasta: $IG_GREP"
echo -e "#### iimstats_pip.sh: Outgroup grep for fasta: $OG_GREP"
echo -e "#### iimstats_pip.sh: Dir for locusstats: $DIR_LOCUSSTATS"
echo -e "#### iimstats_pip.sh: List with loci (to be made): $LOCUSLIST"
echo -e "#### iimstats_pip.sh: Dir for output fasta - base: $DIR_FASTA"
echo -e "#### iimstats_pip.sh: Dir for output fasta - og : $DIR_LOCUSFASTA_OG"
echo -e "#### iimstats_pip.sh: Dir for output fasta - w1: $DIR_LOCUSFASTA_W1"
echo -e "#### iimstats_pip.sh: Dir for output fasta - w2: $DIR_LOCUSFASTA_W2"
echo -e "#### iimstats_pip.sh: Dir for output fasta - bw: $DIR_LOCUSFASTA_BW"
echo -e "#### iimstats_pip.sh: Stop at locus (should be 'LAST' or a number): $STOP_AT"
echo -e "#### iimstats_pip.sh: Skip renaming fasta (TRUE/FALSE): $SKIP_FASTA_RENAME"
echo -e "\n#### iimstats_pip.sh: Dxy file:"
ls -lh $DXY_FILE
echo -e "\n#### iimstats_pip.sh: Input (merged) fasta file:"
ls -lh $FASTA_ORG
printf "\n"


################################################################################
#### GET SINGLE-LOCUS FASTA FILES ####
################################################################################
if [ $SPLIT_FASTA == TRUE ]
then

	## Create new fasta with changed locus names:
	echo -e "#### iimstats_pip.sh: Creating new fasta file with changed locus names..."
	[[ $SKIP_FASTA_RENAME == "FALSE" ]] && sed 's/ //g' $FASTA_ORG | sed -E 's/.*_(Locus_[0-9]+)_Allele_([0-9])\[(.*);.*/>\1_\3_\2/' | sed 's/_//' > $FASTA_ED
	
	echo -e "#### iimstats_pip.sh: Edited fasta..."
	ls -lh $FASTA_ED
	
	## Create list of loci:
	echo -e "\n#### iimstats_pip.sh: Creating list of loci from dxy file..."
	grep -v "#" $DXY_FILE | cut -f 1 > $LOCUSLIST_DXY
	NR_LOCI=$(cat $LOCUSLIST_DXY | wc -l)
	echo -e "#### iimstats_pip.sh: Number of loci - dxy file: $NR_LOCI \n"
	
	echo -e "\n#### iimstats_pip.sh: Creating list of loci from fasta file..."
	grep "Locus" $FASTA_ED | sed -E 's/>(Locus[0-9]+)_.*/\1/' | uniq > $LOCUSLIST_FASTA
	NR_LOCI_FASTA=$(cat $LOCUSLIST_FASTA | wc -l)
	echo -e "#### iimstats_pip.sh: Number of loci - fasta file: $NR_LOCI_FASTA \n"
	
	## Submit splitting jobs:
	echo -e "\n#### iimstats_pip.sh: Submitting a split-fasta job per set of 1k loci..."
	
	[[ $STOP_AT == "LAST" ]] && LAST1K=$(($(($NR_LOCI / 1000)) + 1))
	[[ $STOP_AT != "LAST" ]] && LAST1K=$(( $STOP_AT / 1000 ))
	echo -e "\n#### iimstats_pip.sh: LAST1K: $LAST1K"
	
	for THOUSAND in $(seq 1 $LAST1K)
	do
		LAST=$(($THOUSAND * 1000))
		FIRST=$(($LAST - 999))
		[[ $THOUSAND == $LAST1K && $STOP_AT == "LAST" ]] && LAST=$NR_LOCI
		echo -e "\n#### First: $FIRST / Last: $LAST"

		[[ $STOP_AT == "LAST" ]] && sbatch -p yoderlab,common,scavenger -o slurm.iimstats_$SET_ID.$FIRST --job-name=iimstats.$SET_ID \
			$SCR_SPLIT $IND1 $IND2 $LOCUSLIST $FASTA_ED $DIR_LOCUSFASTA_OG $DIR_LOCUSFASTA_W1 $DIR_LOCUSFASTA_W2 $DIR_LOCUSFASTA_BW $FIRST $LAST
		[[ $STOP_AT != "LAST" ]] && $SCR_SPLIT $IND1 $IND2 $LOCUSLIST $FASTA_ED $DIR_LOCUSFASTA_OG $DIR_LOCUSFASTA_W1 $DIR_LOCUSFASTA_W2 $DIR_LOCUSFASTA_BW $FIRST $LAST
	done
else
	echo -e "\n#### iimstats_pip.sh: SKIPPING fasta-splitting step... \n"
fi


################################################################################
#### GET LOCUS-STATS ####
################################################################################
echo -e "\n#### iimstats_pip.sh: Getting stats on fasta loci..."

[[ $STOP_AT == "LAST" ]] && sbatch -p yoderlab,common,scavenger --mem 12G -o slurm.iimstats.collect.$SET_ID --job-name=iimstats.$SET_ID --dependency=singleton \
	$SCR_STATS_SUBMIT $LOCUSSTATS_RAW $IG_GREP $OG_GREP $DIR_LOCUSFASTA_OG $DIR_LOCUSFASTA_W1 $DIR_LOCUSFASTA_W2 $DIR_LOCUSFASTA_BW $DXY_FILE

[[ $STOP_AT != "LAST" ]] && $SCR_STATS_SUBMIT $LOCUSSTATS_RAW $IG_GREP $OG_GREP $DIR_LOCUSFASTA_OG $DIR_LOCUSFASTA_W1 $DIR_LOCUSFASTA_W2 $DIR_LOCUSFASTA_BW $DXY_FILE


################################################################################
#### FILTER LOCI ####
################################################################################
echo -e "\n#### iimstats_pip.sh: Filtering loci..."

MAXMISS=5
MINDIST=10000

[[ $STOP_AT == "LAST" ]] && sbatch -p yoderlab,common,scavenger -o slurm.iimstats.filter.$SET_ID --job-name=iimstats.$SET_ID --dependency=singleton \
	$SCR_FILTER_SUBMIT $SET_ID $DIR_LOCUSSTATS $MAXMISS $MINDIST
	
[[ $STOP_AT != "LAST" ]] && $SCR_FILTER_SUBMIT $SET_ID $DIR_LOCUSSTATS $MAXMISS $MINDIST


################################################################################
#### HOUSEKEEPING ####
################################################################################
## Report:
echo -e "\n#### iimstats_pip.sh: Done with script."
date


################################################################################
#grep "Locus" $FASTA_ED | sed -E 's/>(Locus[0-9]+)_.*/\1/' | uniq > $LOCUSLIST
