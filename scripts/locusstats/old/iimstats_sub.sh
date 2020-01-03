################################################################################
#### BERMYORUF ####
################################################################################
SET_ID=bermyoruf.iimtest
IND1=mber013
IND2=mmyo006
IG_GREP="mber|mmyo"
OG_GREP="mruf"
FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/sisp/seqdata/stacks/berrufmyo/3s1//fasta/berrufmyo.3s1.merged.filteredloci
DIR_FASTA=/work/jwp37/proj/iim/seqdata/fasta
DIR_LOCUSSTATS=/datacommons/yoderlab/users/jelmer/proj/iim/locusstats2
DXY_FILE=notany
FIRST_THOUSAND=1
LAST_THOUSAND=3
SCR_PIP=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_pip1.sh

#sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip1.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP

## Collect nucdiv stats:
LOCUSSTATS_ALL=$DIR_LOCUSSTATS/$SET_ID.nucdiv.txt
cat $DIR_LOCUSSTATS/split/$SET_ID*nucdiv.txt > $LOCUSSTATS_ALL


################################################################################
#### GRIMURRUF ####
################################################################################
SCR_PIP=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_pip1.sh
DIR_FASTA=/work/jwp37/proj/iim/seqdata/fasta
DIR_LOCUSSTATS=/datacommons/yoderlab/users/jelmer/proj/iim/locusstats
FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/hybridzone/seqdata/stacks/hzproj/grimurruf.og/hzproj.grimurruf.og.samples.fa
DXY_FILE=/datacommons/yoderlab/users/jelmer/proj/hybridzone/seqdata/stacks/hzproj/grimurruf.og/fst/hzproj.grimurruf.og.phistats_ingroup-outgroup.tsv
IG_GREP="mgri|mmur|mgan"
OG_GREP="mruf"
FIRST_THOUSAND=1
LAST_THOUSAND=LAST
SKIP="-SP"
#FIRST_THOUSAND=74; LAST_THOUSAND=74; SKIP="-PM"

## iim1:
SET_ID=grimurruf.iim1
IND1=mgri088
IND2=mmur052
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip1.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP

## iim2:
SET_ID=grimurruf.iim2
IND1=mgri051
IND2=mmur009
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip1.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP
	

################################################################################
#### GRIMURCHE ####
################################################################################
SCR_PIP=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_pip1.sh
DIR_FASTA=/work/jwp37/proj/iim/seqdata/fasta
DIR_LOCUSSTATS=/datacommons/yoderlab/users/jelmer/proj/iim/locusstats
FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/hybridzone/seqdata/stacks/hzproj/grimurche.og/hzproj.grimurche.og.samples.fa
DXY_FILE=/datacommons/yoderlab/users/jelmer/proj/hybridzone/seqdata/stacks/hzproj/grimurche.og/fst/hzproj.grimurche.og.phistats_ingroup-outgroup.tsv
IG_GREP="mgri|mmur|mgan"
OG_GREP="cmed|ccro"
FIRST_THOUSAND=1
LAST_THOUSAND=LAST
SKIP="" #"-SP"

## iim1:
SET_ID=grimurche.iim1
IND1=mgri088
IND2=mmur052
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP

## iim2:
SET_ID=grimurche.iim2
IND1=mgri051
IND2=mmur009
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP


################################################################################
#### CROMAJMIC ####
################################################################################
SCR_PIP=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_pip1.sh
DIR_FASTA=/work/jwp37/proj/iim/seqdata/fasta
DIR_LOCUSSTATS=/datacommons/yoderlab/users/jelmer/proj/iim/locusstats
FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/iim/seqdata/stacks/cromajmic/cromajmic.og/cromajmic.cromajmic.og.samples.fa
DXY_FILE=/datacommons/yoderlab/users/jelmer/proj/iim/seqdata/stacks/cromajmic/cromajmic.og/fst/cromajmic.cromajmic.og.phistats_ingroup-outgroup.tsv
IG_GREP="ccro|cmaj"
OG_GREP="mgri|mmur"
FIRST_THOUSAND=1
LAST_THOUSAND=LAST
SKIP="" #-SP
#FIRST_THOUSAND=1; LAST_THOUSAND=1; SKIP="-PM"

## iim1:
SET_ID=cromajmic.iim1
IND1=ccro022
IND2=cmaj009
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP

## iim2:
SET_ID=cromajmic.iim2
IND1=ccro021
IND2=cmaj010
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP


################################################################################
#### MAJMEDMIC ####
################################################################################
SCR_PIP=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_pip1.sh
DIR_FASTA=/work/jwp37/proj/iim/seqdata/fasta
DIR_LOCUSSTATS=/datacommons/yoderlab/users/jelmer/proj/iim/locusstats
FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/iim/seqdata/stacks/majmedmic/majmedmic.og/majmedmic.majmedmic.og.samples.fa
DXY_FILE=/datacommons/yoderlab/users/jelmer/proj/iim/seqdata/stacks/majmedmic/majmedmic.og/fst/majmedmic.majmedmic.og.phistats_ingroup-outgroup.tsv
IG_GREP="cmaj|cmed"
OG_GREP="mgri|mmur"
FIRST_THOUSAND=1
LAST_THOUSAND=LAST
SKIP="" #-SP

## iim1:
SET_ID=majmedmic.iim1
IND1=cmaj009
IND2=cmed010
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP

## iim2:
SET_ID=majmedmic.iim2
IND1=cmaj010
IND2=cmed001
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP


################################################################################
#### CROMEDMIC ####
################################################################################
SCR_PIP=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_pip1.sh
DIR_FASTA=/work/jwp37/proj/iim/seqdata/fasta
DIR_LOCUSSTATS=/datacommons/yoderlab/users/jelmer/proj/iim/locusstats
FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/iim/seqdata/stacks/cromedmic/cromedmic.og/cromedmic.cromedmic.og.samples.fa
DXY_FILE=/datacommons/yoderlab/users/jelmer/proj/iim/seqdata/stacks/cromedmic/cromedmic.og/fst/cromedmic.cromedmic.og.phistats_ingroup-outgroup.tsv
IG_GREP="ccro|cmed"
OG_GREP="mgri|mmur"
FIRST_THOUSAND=1
LAST_THOUSAND=LAST
SKIP="" #-SP

## iim1:
SET_ID=cromedmic.iim1
IND1=ccro022
IND2=cmed010
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP

## iim2:
SET_ID=cromedmic.iim2
IND1=ccro021
IND2=cmed001
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP


################################################################################
#### MURRAVCHE ####
################################################################################
SCR_PIP=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_pip1.sh
DIR_FASTA=/work/jwp37/proj/iim/seqdata/fasta
DIR_LOCUSSTATS=/datacommons/yoderlab/users/jelmer/proj/iim/locusstats
FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/iim/seqdata/stacks/murravche/murravche.og/murravche.murravche.og.samples.fa
DXY_FILE=/datacommons/yoderlab/users/jelmer/proj/iim/seqdata/stacks/murravche/murravche.og/fst/murravche.murravche.og.phistats_ingroup-outgroup.tsv
IG_GREP="mmur|mrav"
OG_GREP="cmed|ccro"
FIRST_THOUSAND=1
LAST_THOUSAND=LAST
SKIP="" #-SP

## iim1:
SET_ID=murravche.iim1
IND1=mmur083
IND2=mrav004
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP

## iim2:
SET_ID=murravche.iim2
IND1=mmur079
IND2=mrav003
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP


################################################################################
################################################################################
# rsync -avr --no-perms /home/jelmer/Dropbox/sc_lemurs/proj/iim/scripts/ jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/proj/iim/scripts/
# rsync -avr --no-perms jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/proj/iim/locusstats/raw/*txt /home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/

################################################################################
#grep -Po '(?<=^>)[A-Za-z]*_[0-9]*(?=.*)' test.fa |  uniq | parallel 'grep -A 1 {} test.fa > {}.fa'
