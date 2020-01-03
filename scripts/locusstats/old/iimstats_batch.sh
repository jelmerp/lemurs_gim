#!/bin/bash
set -e
set -o pipefail
set -u

## Software and scripts:
SCR_IIMSTATS=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/iim/iimstats.sh

## Command-line args:
LOCUSLIST=$1
IND1=$2
IND2=$3
IND3=$4
FASTA_IN=$5 # Fasta with all loci and individuals
OUTDIR_FASTA=$6
OUTDIR_STATS=$7
FIRST=$8
LAST=$9

## Report:
echo "#### iimstats_batch.sh: Starting script."
echo "#### iimstats_batch.sh: First line: $FIRST"
echo "#### iimstats_batch.sh: Last line: $LAST"

## Loop:
for LINE in $(seq $FIRST $LAST)
do
	LOCUS=$(head -n $LINE $LOCUSLIST | tail -n 1)
	
	echo -e "\n\n###############################################################"
	echo -e "#### iimstats_batch.sh: Locus: $LOCUS \n"
	$SCR_IIMSTATS $LOCUS $IND1 $IND2 $IND3 $FASTA_IN $OUTDIR_FASTA $OUTDIR_STATS
done

## Report:
echo "#### iimstats_batch.sh: Done with script."