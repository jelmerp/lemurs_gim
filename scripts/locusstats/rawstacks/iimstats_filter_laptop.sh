DIR_LOCUSSTATS=/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats
MAXMISS=5
MINDIST=10000
DXY_LOCUS=include
SETS=( $(ls /home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/*txt) ) 

SETS=( $(ls /home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/grimur*txt) )

for SET in ${SETS[@]}
do
	#SET=/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/cromajmic.iim1.locusstats.txt
	SET_ID=$(basename $SET .locusstats.txt)
	[[ $DXY_LOCUS == "include" ]] && OUTFILE_SUFFIX=".dxy"
	[[ $DXY_LOCUS == "exclude" ]] && OUTFILE_SUFFIX=".nodxy"
	echo -e "\n\n\n#### Set ID: $SET_ID"
	echo "#### dxy loci: $DXY_LOCUS"
	Rscript /home/jelmer/Dropbox/sc_lemurs/proj/iim/scripts/locusstats/iimstats_filter.R $SET_ID $DIR_LOCUSSTATS $MAXMISS $MINDIST $DXY_LOCUS $OUTFILE_SUFFIX
done


#DXY_LOCI=( include exclude )
#for DXY_LOCUS in ${DXY_LOCI[@]}
#do
	#SET_ID=grimurruf.iim1; DXY_LOCUS=include
#done