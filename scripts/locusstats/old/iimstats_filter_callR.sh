SCR_FILTER=/home/jelmer/Dropbox/sc_lemurs/proj/iim/scripts/iim/iimstats_filter.R
DIR_LOCUSSTATS='/home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats'
MAXMISS=5
MAXVAR=10
MINDIST=10000

SET_IDS=(grimurruf.iim1 grimurche.iim1 grimurche.iim2 murravche.iim1 murravche.iim2 cheiro_tsiho.cromedmic.iim1 cheiro_tsiho.cromajmic.iim1 cheiro_tsiho.majmedmic.iim1)

for SET_ID in ${SET_IDS[@]}
do
	$SCR_FILTER $SET_ID $DIR_LOCUSSTATS $MAXMISS $MAXVAR $MINDIST
done
