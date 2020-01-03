# rsync -av --no-perms jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/proj/iim/locusstats/*txt /home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/

## General options:
SCR_PIP=/datacommons/yoderlab/users/jelmer/proj/iim/scripts/locusstats/iimstats_pip1.sh
DIR_FASTA=/work/jwp37/proj/iim/seqdata/fasta
DIR_LOCUSSTATS=/datacommons/yoderlab/users/jelmer/proj/iim/locusstats
DXY_FILE=notany
FIRST_THOUSAND=1
LAST_THOUSAND=LAST
SKIP=""

################################################################################
#### GRIMURCHE - EXONS UNMASKED ####
################################################################################
SET_ID_SHORT=grimurche
LSTATS_IN=/datacommons/yoderlab/users/jelmer/proj/hybridzone/geno/stacks/hzproj/grimurche.og/exonunmasked/loci/hzproj.grimurche.og.exonunmasked.exonunmasked.locusstats_filtered.txt
cp $LSTATS_IN $DIR_LOCUSSTATS/$SET_ID_SHORT.exonunmasked.locusstats.txt

FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/hybridzone/geno/stacks/hzproj/grimurche.og/exonunmasked/fasta/hzproj.grimurche.og.exonunmasked.exonunmasked.filtered.fasta
IG_GREP="mgri|mmur|mgan"
OG_GREP="cmed|ccro"

## iim1:
SET_ID=$SET_ID_SHORT.iim1.unmasked
IND1=mgri088
IND2=mmur052
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP

## iim2:
SET_ID=$SET_ID_SHORT.iim2.unmasked
IND1=mgri051
IND2=mmur009
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP


################################################################################
#### GRIMURCHE - EXONS MASKED ####
################################################################################
SET_ID_SHORT=grimurche
LSTATS_IN=/datacommons/yoderlab/users/jelmer/proj/hybridzone/geno/stacks/hzproj/grimurche.og/exonmasked/loci/hzproj.grimurche.og.exonmasked.exonmasked.locusstats_filtered.txt
cp $LSTATS_IN $DIR_LOCUSSTATS/$SET_ID_SHORT.exonmasked.locusstats.txt

FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/hybridzone/geno/stacks/hzproj/grimurche.og/exonmasked/fasta/hzproj.grimurche.og.exonmasked.exonmasked.filtered.fasta
IG_GREP="mgri|mmur|mgan"
OG_GREP="cmed|ccro"

## iim1:
SET_ID=$SET_ID_SHORT.iim1.masked
IND1=mgri088
IND2=mmur052
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP

## iim2:
SET_ID=$SET_ID_SHORT.iim2.masked
IND1=mgri051
IND2=mmur009
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP


################################################################################
#### CROMAJMIC ####
################################################################################
SET_ID_SHORT=cromajmic
LSTATS_IN=/datacommons/yoderlab/users/jelmer/proj/iim/geno/stacks/cromajmic/cromajmic.og/loci/cromajmic.cromajmic.og.lq25.locusstats_filtered.txt
cp $LSTATS_IN $DIR_LOCUSSTATS/$SET_ID_SHORT.locusstats.txt

FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/iim/geno/stacks/cromajmic/cromajmic.og/fasta/cromajmic.cromajmic.og.lq25.filtered.fasta
IG_GREP="ccro|cmaj"
OG_GREP="mgri|mmur"

## iim1:
SET_ID=$SET_ID_SHORT.iim1
IND1=ccro022
IND2=cmaj009
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP

## iim2:
SET_ID=$SET_ID_SHORT.iim2
IND1=ccro021
IND2=cmaj010
sbatch -p yoderlab,common,scavenger --job-name=iimstats -o slurm.iimstats.pip.$SET_ID \
$SCR_PIP $SET_ID $IND1 $IND2 $IG_GREP $OG_GREP $FASTA_IN $DIR_FASTA $DIR_LOCUSSTATS $DXY_FILE $FIRST_THOUSAND $LAST_THOUSAND $SKIP


################################################################################
#### MAJMEDMIC ####
################################################################################
FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/iim/geno/stacks/majmedmic/majmedmic.og/fasta/majmedmic.majmedmic.og.merged.filteredloci.fasta
IG_GREP="cmaj|cmed"
OG_GREP="mgri|mmur"

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
FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/iim/geno/stacks/cromedmic/cromedmic.og/cromedmic.cromedmic.og.merged.filteredloci.fasta
IG_GREP="ccro|cmed"
OG_GREP="mgri|mmur"

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
FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/iim/geno/stacks/murravche/murravche.og/fasta/murravche.murravche.og.merged.filteredloci.fasta
IG_GREP="mmur|mrav"
OG_GREP="cmed|ccro"

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

# rsync -avr --no-perms jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/proj/iim/locusstats/*txt /home/jelmer/Dropbox/sc_lemurs/proj/iim/locusstats/raw/

################################################################################
# grep -Po '(?<=^>)[A-Za-z]*_[0-9]*(?=.*)' test.fa |  uniq | parallel 'grep -A 1 {} test.fa > {}.fa' # Split by locus


################################################################################
#### GRIMURRUF ####
################################################################################
FASTA_IN=/datacommons/yoderlab/users/jelmer/proj/hybridzone/geno/stacks/hzproj/grimurruf.og/fasta/hzproj.grimurruf.og.samples.fa
IG_GREP="mgri|mmur|mgan"
OG_GREP="mruf"

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

