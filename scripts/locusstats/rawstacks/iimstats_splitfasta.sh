#!/bin/bash
set -e
set -o pipefail
set -u

## Command-line args:
IND1=$1
shift
IND2=$1
shift
LOCUSLIST=$1
shift
FASTA_IN=$1 # Fasta with all loci and individuals
shift
DIR_LOCUSFASTA_OG=$1
shift
DIR_LOCUSFASTA_W1=$1
shift
DIR_LOCUSFASTA_W2=$1
shift
DIR_LOCUSFASTA_BW=$1
shift
FIRST=$1
shift
LAST=$1
shift

## Report:
date
echo -e "#### iimstats_splitfasta.sh: Starting script."
echo -e "#### iimstats_splitfasta.sh: Indiv 1: $IND1"
echo -e "#### iimstats_splitfasta.sh: Indiv 2: $IND2"
echo -e "#### iimstats_splitfasta.sh: Locus list: $LOCUSLIST"
echo -e "#### iimstats_splitfasta.sh: Input fasta: $FASTA_IN"
echo -e "#### iimstats_splitfasta.sh: Outgroup fasta dir: $DIR_LOCUSFASTA_OG"
echo -e "#### iimstats_splitfasta.sh: Within1 fasta dir: $DIR_LOCUSFASTA_W1"
echo -e "#### iimstats_splitfasta.sh: Within2 fasta dir: $DIR_LOCUSFASTA_W2"
echo -e "#### iimstats_splitfasta.sh: Between fasta dir: $DIR_LOCUSFASTA_BW \n"
echo -e "#### iimstats_splitfasta.sh: First line: $FIRST"
echo -e "#### iimstats_splitfasta.sh: Last line: $LAST \n"

echo -e "#### iimstats_splitfasta.sh: Head of fasta:"
head $FASTA_IN
printf "\n"

## Loop:
for LINE in $(seq $FIRST $LAST)
do
	LOCUS=$(head -n $LINE $LOCUSLIST | tail -n 1)
	[[ ! $LOCUS =~ "Locus" ]] && LOCUS=Locus$LOCUS
	echo -e "#### iimstats_splitfasta.sh: Line: $LINE  Locus: $LOCUS"
	
	## Get single-locus, multi-ind fasta:
	grep -A 1 ">${LOCUS}_" $FASTA_IN | sed -E 's/Locus[0-9]+_//' > $DIR_LOCUSFASTA_OG/$LOCUS.fa
	
	## Split single-locus fasta by (sets of) individuals:
	egrep -A 1 "$IND1" $DIR_LOCUSFASTA_OG/$LOCUS.fa | grep -v "\-\-" > $DIR_LOCUSFASTA_W1/$LOCUS.fa
	egrep -A 1 "$IND2" $DIR_LOCUSFASTA_OG/$LOCUS.fa | grep -v "\-\-" > $DIR_LOCUSFASTA_W2/$LOCUS.fa
	egrep -A 1 "${IND1}_0|${IND2}_0" $DIR_LOCUSFASTA_OG/$LOCUS.fa | grep -v "\-\-" > $DIR_LOCUSFASTA_BW/$LOCUS.fa
done

## Report:
echo "#### iimstats_splitfasta.sh: Done with script."
date