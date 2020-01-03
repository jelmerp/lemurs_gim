SCR_FILTER=/home/jelmer/Dropbox/sc_lemurs/proj/iim/scripts/locusstats/iimstats_filter.R
DIR_LOCUSSTATS=/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats
MAXMISS_IND="0.05"
MAXMISS_MEAN="0.1"
MINDIST=5000
MAXVAR="0.05"
INFILE_GENES=/home/jelmer/Dropbox/sc_lemurs/seqdata/reference/mmur/GCF_000165445.2_Mmur_3.0_genes.bed
INFILE_EXONS=/home/jelmer/Dropbox/sc_lemurs/seqdata/reference/mmur/GCF_000165445.2_Mmur_3.0_exons.bed

## Masked:
SET_ID=grimurche.iim1
OUTFILE_SUFFIX='.masked'
IG_GREP="mgan|mmur|mgri"
OG_GREP="cmed|ccro"
INDFILE=/home/jelmer/Dropbox/sc_lemurs/proj/iim/indsel/$SET_ID.txt
INFILE_LSTATS_NUCDIV=/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/$SET_ID.masked.nucdiv.txt
INFILE_LSTATS_PMISS=/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/grimurche.exonmasked.locusstats.txt
Rscript $SCR_FILTER $SET_ID $IG_GREP $OG_GREP $INDFILE $DIR_LOCUSSTATS $INFILE_LSTATS_NUCDIV $INFILE_LSTATS_PMISS \
	$MAXMISS_IND $MAXMISS_MEAN $MINDIST $MAXVAR $INFILE_GENES $INFILE_EXONS $OUTFILE_SUFFIX

SET_ID=grimurche.iim2
OUTFILE_SUFFIX='.masked'
IG_GREP="mgan|mmur|mgri"
OG_GREP="cmed|ccro"
INFILE_LSTATS_NUCDIV=/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/$SET_ID.masked.nucdiv.txt
INFILE_LSTATS_PMISS=/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/grimurche.exonmasked.locusstats.txt
Rscript $SCR_FILTER $SET_ID $IG_GREP $OG_GREP $INDFILE $DIR_LOCUSSTATS $INFILE_LSTATS_NUCDIV $INFILE_LSTATS_PMISS \
	$MAXMISS_IND $MAXMISS_MEAN $MINDIST $MAXVAR $INFILE_GENES $INFILE_EXONS $OUTFILE_SUFFIX

## Unmasked:
SET_ID=grimurche.iim1
OUTFILE_SUFFIX='.unmasked'
IG_GREP="mgan|mmur|mgri"
OG_GREP="cmed|ccro"
INFILE_LSTATS_NUCDIV=/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/$SET_ID.unmasked.nucdiv.txt
INFILE_LSTATS_PMISS=/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/grimurche.exonunmasked.locusstats.txt
Rscript $SCR_FILTER $SET_ID $IG_GREP $OG_GREP $INDFILE $DIR_LOCUSSTATS $INFILE_LSTATS_NUCDIV $INFILE_LSTATS_PMISS \
	$MAXMISS_IND $MAXMISS_MEAN $MINDIST $MAXVAR $INFILE_GENES $INFILE_EXONS $OUTFILE_SUFFIX
	
SET_ID=grimurche.iim2
OUTFILE_SUFFIX='.unmasked'
IG_GREP="mgan|mmur|mgri"
OG_GREP="cmed|ccro"
INFILE_LSTATS_NUCDIV=/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/$SET_ID.unmasked.nucdiv.txt
INFILE_LSTATS_PMISS=/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/grimurche.exonunmasked.locusstats.txt
Rscript $SCR_FILTER $SET_ID $IG_GREP $OG_GREP $INDFILE $DIR_LOCUSSTATS $INFILE_LSTATS_NUCDIV $INFILE_LSTATS_PMISS \
	$MAXMISS_IND $MAXMISS_MEAN $MINDIST $MAXVAR $INFILE_GENES $INFILE_EXONS $OUTFILE_SUFFIX



################################################################################
################################################################################
#SETS=( $(ls /home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/*txt) ) 
#for SET in ${SETS[@]}
#do
#	#SET=/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/cromajmic.iim1.locusstats.txt
#	SET_ID=$(basename $SET .nucdiv.txt)
#	INFILE_LSTATS_NUCDIV=/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/$SET_ID.nucdiv.txt
#	INFILE_LSTATS_PMISS=xx
#	echo -e "\n\n\n#### Set ID: $SET_ID"
#	
#	Rscript /home/jelmer/Dropbox/sc_lemurs/proj/iim/scripts/locusstats/iimstats_filter.R \
#		$SET_ID $INDFILE $DIR_LOCUSSTATS $INFILE_LSTATS_NUCDIV $INFILE_LSTATS_NUCDIV \
#		$MAXMISS_IND $MAXMISS_MEAN $MINDIST $MAXVAR $INFILE_GENES $INFILE_EXONS $OUTFILE_SUFFIX
#done
