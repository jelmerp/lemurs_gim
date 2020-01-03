#!/bin/bash
set -e
set -o pipefail
set -u

################################################################################
#### SET-UP ####
################################################################################
## Software and scripts:
SCR_SUBMIT=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/iim/iimstats_batch.sh
SCR_COLLECT=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/iim/iimstats_collect.sh

## Command-line args:
SET_ID=$1
IND1=$2
IND2=$3
IND3=$4
FASTA_IN_ORG=$5
OUTDIR_FASTA_BASE=$6
OUTDIR_STATS_BASE=$7
STOP_AT=$8

## Process args:
OUTDIR_FASTA=$OUTDIR_FASTA_BASE/$SET_ID/
OUTDIR_STATS_LOCUS=$OUTDIR_STATS_BASE/$SET_ID.byLocus/

OUTFILE_LOCUSLIST=$OUTDIR_STATS_LOCUS/$SET_ID.locuslist.txt
OUTFILE_FINALSTATS=$OUTDIR_STATS_BASE/raw/$SET_ID.locusstats.txt

[[ ! -d $OUTDIR_STATS_BASE/raw/ ]] && mkdir -p $OUTDIR_STATS_BASE/raw/
[[ ! -d $OUTDIR_STATS_LOCUS ]] && mkdir -p $OUTDIR_STATS_LOCUS
[[ ! -d $OUTDIR_FASTA ]] && mkdir -p $OUTDIR_FASTA

## Report:
date
echo -e "\n#### iimstats_pip.sh: Starting script."
echo -e "#### iimstats_pip.sh: Set ID: $SET_ID"
echo -e "#### iimstats_pip.sh: Ind 1 (species 1): $IND1"
echo -e "#### iimstats_pip.sh: Ind 2 (species 2): $IND2"
echo -e "#### iimstats_pip.sh: Ind 3 (outgroup): $IND3"
echo -e "#### iimstats_pip.sh: Input (merged) fasta file: $FASTA_IN_ORG"
echo -e "#### iimstats_pip.sh: Stop at locus (should be 'LAST' or a number): $STOP_AT"
echo -e "\n#### iimstats_pip.sh: Output dir for fasta: $OUTDIR_FASTA"
echo -e "#### iimstats_pip.sh: Output dir for by-locus stats: $OUTDIR_STATS_LOCUS"
echo -e "\n#### iimstats_pip.sh: Final stats file: $OUTFILE_FINALSTATS"


################################################################################
#### EDIT FASTA AND GET LIST OF LOCI ####
################################################################################
## Create new fasta with changed locus names:
echo -e "\n#### iimstats_pip.sh: Creating new fasta file with changed locus names..."
FASTA_IN_ED=$OUTDIR_FASTA/fasta_merged_tmp.fa
cat $FASTA_IN_ORG | sed 's/ //g' > $FASTA_IN_ED	

## Create list of loci:
echo -e "\n#### iimstats_pip.sh: Creating list of loci..."
cat $FASTA_IN_ED | grep "Locus" | sed -E 's/.*_(Locus_[0-9]+)_.*/\1/' | uniq > $OUTFILE_LOCUSLIST
NR_LOCI=$(cat $OUTFILE_LOCUSLIST | wc -l)
echo "#### Number of loci: $NR_LOCI"


################################################################################
#### LOOP THROUGH LOCI ####
################################################################################
echo -e "\n#### iimstats_pip.sh: Submitting a job per set of 100 loci..."

if [ $STOP_AT == "LAST" ]
then
	LAST100=$(($(($NR_LOCI / 100)) + 1))
else
	LAST100=$(( $STOP_AT / 100 ))
fi

echo -e "\n#### iimstats_pip.sh: LAST100: $LAST100"

for HUNDRED in $(seq 1 $LAST100)
do
	LAST=$(($HUNDRED * 100))
	FIRST=$(($LAST - 99))
	[[ $HUNDRED == $LAST100 && $STOP_AT == LAST ]] && LAST=$NR_LOCI
	echo -e "\n#### First: $FIRST / Last: $LAST"
	
	sbatch -p yoderlab,common,scavenger -o slurm.iimstats_$SET_ID.$FIRST --job-name=iimstats.$SET_ID \
	$SCR_SUBMIT $OUTFILE_LOCUSLIST $IND1 $IND2 $IND3 $FASTA_IN_ED $OUTDIR_FASTA $OUTDIR_STATS_LOCUS $FIRST $LAST
done


################################################################################
#### CREATE FINAL STATS FILE ####
################################################################################
echo -e "\n#### iimstats_pip.sh: Creating final stats file..."

sbatch -p yoderlab,common,scavenger -o slurm.iimstats.collect.$SET_ID \
	--job-name=iimstats.$SET_ID --dependency=singleton \
	$SCR_COLLECT $OUTDIR_STATS_LOCUS $OUTFILE_FINALSTATS


################################################################################
#### HOUSEKEEPING ####
################################################################################
## Report:
echo -e "\n#### iimstats_pip.sh: Done with script."
date