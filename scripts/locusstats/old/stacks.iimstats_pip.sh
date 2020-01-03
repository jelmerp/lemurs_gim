#!/bin/bash
set -e
set -o pipefail
set -u

################################################################################
#### SET-UP ####
################################################################################
## Scripts and software:
STACKS_PIP=/datacommons/yoderlab/users/jelmer/scripts/geno/stacks/stacks_pip.sh
IIM_PIP=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/iim/iimstats_pip.sh

## Command-line args:
GSTACKS_ID=$1
shift
SET_ID=$1
shift
STACKSDIR=$1
shift
BAMDIR=$1
shift
BAMSUFFIX=$1
shift
POPMAP_ALL=$1
shift
POPMAP_SEL=$1
shift
TO_SKIP_STACKS=$1
shift
OUTDIR_FASTA_BASE=$1
shift
OUTDIR_FASTA_BASE=$1
shift

## Hardcoded vars:
NCORES_STACKS=8
ADD_OPS_GSTACKS=""
ADD_OPS_POPSTACKS="--min-samples-overall 1 --fasta-samples --fstats"
STOP_AT=LAST

## Report:
date
echo -e "\n#### iim_stats.sh: Starting script."
echo -e "#### iim_stats.sh: Locus: $LOCUS"
echo -e "#### iim_stats.sh: Ind 1 (species 1): $IND1"
echo -e "#### iim_stats.sh: Ind 2 (species 2): $IND2"
echo -e "#### iim_stats.sh: Ind 3 (outgroup): $IND3"
echo -e "#### iim_stats.sh: Input (merged) fasta file: $FASTA_IN"
echo -e "#### iim_stats.sh: Output dir for fasta: $OUTDIR_FASTA"
echo -e "#### iim_stats.sh: Output dir for stats: $OUTDIR_STATS"
echo -e "#### iim_stats.sh: Locus fasta file: $FASTA_LOCUS"
echo -e "#### iim_stats.sh: Output file with stats: $STATS_LOCUS"


################################################################################
#### STACKS ####
################################################################################
sbatch -p yoderlab,common,scavenger --job-name=stacks.iimstats.pip.$GSTACKS_ID.$SET_ID -o slurm.stacks.pip.$SET_ID \
$STACKS_PIP $GSTACKS_ID $SET_ID $STACKSDIR $BAMDIR $BAMSUFFIX \
	$POPMAP_ALL $POPMAP_SEL "$ADD_OPS_GSTACKS" "$ADD_OPS_POPSTACKS" $NCORES_STACKS $TO_SKIP_STACKS

	
################################################################################
#### IIMSTATS ####
################################################################################
FASTA_IN=$STACKSDIR/$GSTACKS_ID/$SET_ID/$SET_ID.samples.fa

IND1=$(cat $POPMAP_SEL | cut -f 1 | head -n 1 | tail -n 1)
IND2=$(cat $POPMAP_SEL | cut -f 1 | head -n 2 | tail -n 1)
IND2=$(cat $POPMAP_SEL | cut -f 1 | head -n 3 | tail -n 1)


## TO DO: EDIT JOBNAMES FOR DEPENDENCY
sbatch -p yoderlab,common,scavenger --job-name=stacks.iimstats.pip.$GSTACKS_ID.$SET_ID -o slurm.iimstats.pip.$SET_ID \
	$SCR_PIP $SET_ID $IND1 $IND2 $IND3 $FASTA_IN $OUTDIR_FASTA_BASE $OUTDIR_STATS_BASE $STOP_AT



################################################################################
#### HOUSEKEEPING ####
################################################################################
echo -e "\n#### iim_stats.sh: Done with script."
date