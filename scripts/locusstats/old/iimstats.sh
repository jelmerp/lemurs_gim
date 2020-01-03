#!/bin/bash
set -e
set -o pipefail
set -u

################################################################################
#### SET-UP ####
################################################################################
## Software:
AMAS=/datacommons/yoderlab/programs/AMAS/amas/AMAS.py
FAIDX=/datacommons/yoderlab/programs/miniconda2/bin/faidx

## Command-line args:
LOCUS=$1
IND1=$2
IND2=$3
IND3=$4
FASTA_IN=$5 # Fasta with all loci and individuals
OUTDIR_FASTA=$6
OUTDIR_STATS=$7

#LOCUS=Locus_2
#IND1=mmur083
#IND2=mrav004
#IND3=cmed001
#FASTA_IN=/work/jwp37/proj/iim/seqdata/fasta/murrav.iim1//fasta_merged_tmp.fa
#OUTDIR_FASTA=/work/jwp37/proj/iim/seqdata/fasta/murrav.iim1/
#OUTDIR_STATS=/datacommons/yoderlab/users/jelmer/proj/iim/locusstats/murrav.iim1//byLocus/

## Make output dirs if necessary:
[[ ! -d $OUTDIR_FASTA ]] && mkdir -p $OUTDIR_FASTA
[[ ! -d $OUTDIR_STATS ]] && mkdir -p $OUTDIR_STATS

## Output fasta's:
FASTA_LOCUS=$OUTDIR_FASTA/$LOCUS.fa
FA1=$OUTDIR_FASTA/$LOCUS.within1.fa
FA2=$OUTDIR_FASTA/$LOCUS.within2.fa
FA3=$OUTDIR_FASTA/$LOCUS.between.fa
FA4=$OUTDIR_FASTA/$LOCUS.outgroup.fa

## Output stats files:
STATS1=$OUTDIR_STATS/$LOCUS.tmp.within1.txt
STATS2=$OUTDIR_STATS/$LOCUS.tmp.within2.txt
STATS3=$OUTDIR_STATS/$LOCUS.tmp.between.txt
STATS4=$OUTDIR_STATS/$LOCUS.tmp.outgroup.txt
STATS_LOCUS=$OUTDIR_STATS/$LOCUS.stats.txt

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
#### SUBSET FASTAS USING FAIDX ####
################################################################################
echo -e "\\n#### iim_stats.sh: Subsetting fasta files...\n"
$FAIDX --regex "_${LOCUS}_" $FASTA_IN > $FASTA_LOCUS # All indivs for focal locus
$FAIDX --regex "${IND1}" $FASTA_LOCUS > $FA1 # Within-species 1
$FAIDX --regex "${IND2}" $FASTA_LOCUS > $FA2 # Within-species 2
$FAIDX --regex "_Allele_0.*${IND1}|_Allele_0.*${IND2}" $FASTA_LOCUS > $FA3 # Between species
$FAIDX --regex "_Allele_0.*${IND1}|_Allele_0.*${IND3}" $FASTA_LOCUS > $FA4 # Outgroup


################################################################################
#### GET FASTA'S ####
################################################################################
echo -e "\\n#### iim_stats.sh: Getting sumstats from fasta files...\n"
$AMAS summary -f fasta -d dna -i $FA1 -o $STATS1
$AMAS summary -f fasta -d dna -i $FA2 -o $STATS2
$AMAS summary -f fasta -d dna -i $FA3 -o $STATS3
$AMAS summary -f fasta -d dna -i $FA4 -o $STATS4


################################################################################
#### EXTRACT STATS ####
################################################################################
echo -e "\\n#### iim_stats.sh: Putting sumstats in output file...\n"

## Get scaffold and start position for each locus:
SCAFFOLD=$(head -n 1 $FASTA_LOCUS | sed -E 's/.*;(.*),[0-9].*/\1/')
START=$(head -n 1 $FASTA_LOCUS | sed -E 's/.*,(.*),[+-].*/\1/')

## Number of sites:
NSITES=$(cut -f 3 $STATS1 | head -n 2 | tail -n 1)

## Number of variable sites:
NVAR1=$(cut -f 7 $STATS1 | head -n 2 | tail -n 1)
NVAR2=$(cut -f 7 $STATS2 | head -n 2 | tail -n 1)
NVAR3=$(cut -f 7 $STATS3 | head -n 2 | tail -n 1)
NVAR4=$(cut -f 7 $STATS4 | head -n 2 | tail -n 1)

## Percentage missing:
PMISS1=$(cut -f 6 $STATS1 | head -n 2 | tail -n 1)
PMISS2=$(cut -f 6 $STATS2 | head -n 2 | tail -n 1)
PMISS3=$(cut -f 6 $STATS3 | head -n 2 | tail -n 1)
PMISS4=$(cut -f 6 $STATS4 | head -n 2 | tail -n 1)

## Put stats in single line:
echo $LOCUS $SCAFFOLD $START $NSITES $NVAR1 $NVAR2 $NVAR3 $NVAR4 $PMISS1 $PMISS2 $PMISS3 $PMISS4 > $STATS_LOCUS


################################################################################
#### HOUSEKEEPING ####
################################################################################
echo -e "\\n#### iim_stats.sh: Showing locus-stats-file...\n"
head $STATS_LOCUS

echo -e "\n#### iim_stats.sh: Removing temporary files..."
rm -f $OUTDIR_STATS/$LOCUS*tmp*txt
rm -f $OUTDIR_FASTA/$LOCUS*fa
rm -f $OUTDIR_FASTA/$LOCUS*fai

echo -e "\n#### iim_stats.sh: Done with script."
date


################################################################################
################################################################################
## Testing
#echo -e "\n#### iim_stats.sh: Head of locus fasta:" ; head -n 2 $FASTA_LOCUS
#echo -e "\n#### iim_stats.sh: Head of locus fasta - 1:"; head -n 2 $FA1
#echo -e "\n#### iim_stats.sh: Head of locus fasta - 2:"; head -n 2 $FA2
#echo -e "\n#### iim_stats.sh: Head of locus fasta - 3:"; head -n 2 $FA3
#echo -e "\n#### iim_stats.sh: Head of locus fasta - 4:"; head -n 2 $FA4
