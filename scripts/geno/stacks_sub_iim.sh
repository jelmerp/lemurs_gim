### TO DO - STACKS: ADD 3RD OUTGROUP? -- mzaz004
### TO DO - CHECK HWE
### TO DO - LENGTH IS ONE BASE TOO LONG - FIX

################################################################################
################################################################################
## General options:
SCR_PIP=/datacommons/yoderlab/users/jelmer/scripts/geno/stacks/stacks_pip.sh
BAMSUFFIX=".sort.MQ30.dedup.bam"
ADD_OPS_GSTACKS=""
ADD_OPS_POPSTACKS="--min-samples-overall 0.75 --fasta-samples"
CALLABLE_COMMAND="--minDepth 3"
MAXMISS_IND=10
MAXMISS_MEAN=10
MINDIST=0
MINLENGTH=100
LENGTH_QUANTILE=25
MAXINDMISS=50
NCORES=8
TO_SKIP=""


################################################################################
#### GRI-MUR ####
################################################################################
GSTACKS_ID=hzproj
POPSTACKS_ID=grimurche.og
POPMAP_GSTACKS=/datacommons/yoderlab/users/jelmer/proj/iim/indsel/stacks_popmap/$GSTACKS_ID.txt
POPMAP_POPSTACKS=/datacommons/yoderlab/users/jelmer/proj/iim/indsel/stacks_popmap/$POPSTACKS_ID.txt
STACKSDIR_BASE=/datacommons/yoderlab/users/jelmer/proj/hybridzone/geno/stacks/
REF=/datacommons/yoderlab/users/jelmer/seqdata/reference/mmur/GCF_000165445.2_Mmur_3.0_genomic_stitched.fasta
SCAF_FILE=/datacommons/yoderlab/users/jelmer/seqdata/reference/mmur/scaffoldLength_NC.txt
BAMDIR=/datacommons/yoderlab/data/radseq/bam/map2mmur/final_merged/
TO_SKIP="-GPV"

## With exons masked:
BED_EXONS=/datacommons/yoderlab/users/jelmer/seqdata/reference/mmur/GCF_000165445.2_Mmur_3.0_exons.bed
FASTA_ID=exonmasked
$SCR_PIP $GSTACKS_ID $POPSTACKS_ID $FASTA_ID $STACKSDIR_BASE $BAMDIR $BAMSUFFIX \
	$POPMAP_GSTACKS $POPMAP_POPSTACKS "$ADD_OPS_GSTACKS" "$ADD_OPS_POPSTACKS" $BED_EXONS \
	$REF $SCAF_FILE "$CALLABLE_COMMAND" $MAXMISS_IND $MAXMISS_MEAN $MINDIST $MINLENGTH $LENGTH_QUANTILE $MAXINDMISS $NCORES $TO_SKIP

## Exons not masked:
BED_EXONS=notany
FASTA_ID=exonunmasked
$SCR_PIP $GSTACKS_ID $POPSTACKS_ID $FASTA_ID $STACKSDIR_BASE $BAMDIR $BAMSUFFIX \
	$POPMAP_GSTACKS $POPMAP_POPSTACKS "$ADD_OPS_GSTACKS" "$ADD_OPS_POPSTACKS" $BED_EXONS \
	$REF $SCAF_FILE "$CALLABLE_COMMAND" $MAXMISS_IND $MAXMISS_MEAN $MINDIST $MINLENGTH $LENGTH_QUANTILE $MAXINDMISS $NCORES $TO_SKIP


################################################################################
#### MUR-RAV ####
################################################################################
GSTACKS_ID=murravche
POPSTACKS_ID=murravche.og
POPMAP_GSTACKS=/datacommons/yoderlab/users/jelmer/proj/iim/indsel/stacks_popmap/$GSTACKS_ID.txt
POPMAP_POPSTACKS=/datacommons/yoderlab/users/jelmer/proj/iim/indsel/stacks_popmap/$POPSTACKS_ID.txt
STACKSDIR_BASE=/datacommons/yoderlab/users/jelmer/proj/iim/geno/stacks/
REF=/datacommons/yoderlab/users/jelmer/seqdata/reference/mmur/GCF_000165445.2_Mmur_3.0_genomic_stitched.fasta
SCAF_FILE=/datacommons/yoderlab/users/jelmer/seqdata/reference/mmur/scaffoldLength_NC.txt
BAMDIR=/datacommons/yoderlab/data/radseq/bam/map2mmur/final_merged/
TO_SKIP="-G"
$SCR_PIP $GSTACKS_ID $POPSTACKS_ID $FASTA_ID $STACKSDIR_BASE $BAMDIR $BAMSUFFIX \
	$POPMAP_GSTACKS $POPMAP_POPSTACKS "$ADD_OPS_GSTACKS" "$ADD_OPS_POPSTACKS" \
	$REF $SCAF_FILE "$CALLABLE_COMMAND" $MAXMISS_IND $MAXMISS_MEAN $MINDIST $MINLENGTH $LENGTH_QUANTILE $MAXINDMISS $NCORES $TO_SKIP

	
################################################################################
#### CRO-MAJ ####
################################################################################
GSTACKS_ID=cromajmic
POPSTACKS_ID=cromajmic.og
FASTA_ID=lq25
POPMAP_GSTACKS=/datacommons/yoderlab/users/jelmer/proj/iim/indsel/stacks_popmap/$GSTACKS_ID.txt
POPMAP_POPSTACKS=/datacommons/yoderlab/users/jelmer/proj/iim/indsel/stacks_popmap/$POPSTACKS_ID.txt
STACKSDIR_BASE=/datacommons/yoderlab/users/jelmer/proj/iim/geno/stacks/
REF=/datacommons/yoderlab/users/rwilliams/dovetail/cmedius_dt_april17_stitched.fasta
SCAF_FILE=/datacommons/yoderlab/users/rwilliams/dovetail/cmedius_dt_april17_stitched.scaffoldLength.txt
BAMDIR=/datacommons/yoderlab/data/radseq/bam/map2cmed/final_merged/
TO_SKIP="-GPV"
sbatch -p yoderlab,common,scavenger --job-name=stacks.$GSTACKS_ID.$POPSTACKS_ID -o slurm.stacks.pip.$GSTACKS_ID.$POPSTACKS_ID \
$SCR_PIP $GSTACKS_ID $POPSTACKS_ID $FASTA_ID $STACKSDIR_BASE $BAMDIR $BAMSUFFIX \
	$POPMAP_GSTACKS $POPMAP_POPSTACKS "$ADD_OPS_GSTACKS" "$ADD_OPS_POPSTACKS" \
	$REF $SCAF_FILE "$CALLABLE_COMMAND" $MAXMISS_IND $MAXMISS_MEAN $MINDIST $MINLENGTH $LENGTH_QUANTILE $MAXINDMISS $NCORES $TO_SKIP


################################################################################
#### MAJ-MED ####
################################################################################
GSTACKS_ID=majmedmic
POPSTACKS_ID=majmedmic.og
POPMAP_GSTACKS=/datacommons/yoderlab/users/jelmer/proj/iim/indsel/stacks_popmap/$GSTACKS_ID.txt
POPMAP_POPSTACKS=/datacommons/yoderlab/users/jelmer/proj/iim/indsel/stacks_popmap/$POPSTACKS_ID.txt
STACKSDIR_BASE=/datacommons/yoderlab/users/jelmer/proj/iim/geno/stacks/
TO_SKIP="-G"
sbatch -p yoderlab,common,scavenger --job-name=stacks.$GSTACKS_ID.$POPSTACKS_ID -o slurm.stacks.pip.$GSTACKS_ID.$POPSTACKS_ID \
$SCR_PIP $GSTACKS_ID $POPSTACKS_ID $FASTA_ID $STACKSDIR_BASE $BAMDIR $BAMSUFFIX \
	$POPMAP_GSTACKS $POPMAP_POPSTACKS "$ADD_OPS_GSTACKS" "$ADD_OPS_POPSTACKS" \
	$REF $SCAF_FILE "$CALLABLE_COMMAND" $MAXMISS_IND $MAXMISS_MEAN $MINDIST $MINLENGTH $LENGTH_QUANTILE $MAXINDMISS $NCORES $TO_SKIP

	
################################################################################
#### CRO-MED ####
################################################################################
GSTACKS_ID=cromedmic
POPSTACKS_ID=cromedmic.og
POPMAP_GSTACKS=/datacommons/yoderlab/users/jelmer/proj/iim/indsel/stacks_popmap/$GSTACKS_ID.txt
POPMAP_POPSTACKS=/datacommons/yoderlab/users/jelmer/proj/iim/indsel/stacks_popmap/$POPSTACKS_ID.txt
STACKSDIR_BASE=/datacommons/yoderlab/users/jelmer/proj/iim/geno/stacks/
TO_SKIP="-G"
sbatch -p yoderlab,common,scavenger --job-name=stacks.$GSTACKS_ID.$POPSTACKS_ID -o slurm.stacks.pip.$GSTACKS_ID.$POPSTACKS_ID \
$SCR_PIP $GSTACKS_ID $POPSTACKS_ID $FASTA_ID $STACKSDIR_BASE $BAMDIR $BAMSUFFIX \
	$POPMAP_GSTACKS $POPMAP_POPSTACKS "$ADD_OPS_GSTACKS" "$ADD_OPS_POPSTACKS" \
	$REF $SCAF_FILE "$CALLABLE_COMMAND" $MAXMISS_IND $MAXMISS_MEAN $MINDIST $MINLENGTH $LENGTH_QUANTILE $MAXINDMISS $NCORES $TO_SKIP


################################################################################
################################################################################
# rsync -avr --no-perms /home/jelmer/Dropbox/sc_lemurs/scripts/ jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/scripts/
# rsync -avr --no-perms /home/jelmer/Dropbox/sc_lemurs/radseq/metadata/ jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/radseq/metadata/
# rsync -avr --no-perms /home/jelmer/Dropbox/sc_lemurs/proj/iim/indsel/ jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/proj/iim/indsel/


################################################################################
## grimurruf:
# TO_SKIP="-GPV"
# GSTACKS_ID=hzproj
# POPSTACKS_ID=grimurruf.og
# POPMAP_GSTACKS=/datacommons/yoderlab/users/jelmer/proj/iim/indsel/stacks_popmap/$GSTACKS_ID.txt
# POPMAP_POPSTACKS=/datacommons/yoderlab/users/jelmer/proj/iim/indsel/stacks_popmap/$POPSTACKS_ID.txt
# STACKSDIR_BASE=/datacommons/yoderlab/users/jelmer/proj/hybridzone/geno/stacks/
# $SCR_PIP $GSTACKS_ID $POPSTACKS_ID $STACKSDIR_BASE $BAMDIR $BAMSUFFIX \
#	$POPMAP_GSTACKS $POPMAP_POPSTACKS "$ADD_OPS_GSTACKS" "$ADD_OPS_POPSTACKS" \
#	$REF $SCAF_FILE "$CALLABLE_COMMAND" $MAXMISS_IND $MAXMISS_MEAN $MINDIST $MINLENGTH $MAXINDMISS $NCORES $TO_SKIP
	
################################################################################
#SCAF_FILE=/datacommons/yoderlab/users/rwilliams/dovetail/cmedius_dt_april17_stitched.scaffoldLength.txt
#echo -e "scaffold\tlength" > $SCAF_FILE
#cut -f 1,2 /datacommons/yoderlab/users/rwilliams/dovetail/cmedius_dt_april17_stitched.fasta.fai >> $SCAF_FILE

################################################################################
## Intersect with genes:
# GFF=/datacommons/yoderlab/users/jelmer/seqdata/reference/mmur/GCF_000165445.2_Mmur_3.0_genomic.gff
# grep "gene_biotype=protein_coding" $GFF | cut -f 1,4,5 > $GENES
# grep -P "\texon\t" $GFF | cut -f 1,4,5 > $EXONS
# GENES=/datacommons/yoderlab/users/jelmer/seqdata/reference/mmur/GCF_000165445.2_Mmur_3.0_genes.bed
# EXONS=/datacommons/yoderlab/users/jelmer/seqdata/reference/mmur/GCF_000165445.2_Mmur_3.0_exons.bed
# LOCI=/datacommons/yoderlab/users/jelmer/proj/sisp/geno/stacks/berrufmyo/3s1/loci/berrufmyo.3s1.filteredloci.bed
# bedtools intersect -u -a $LOCI -b $GENES > genes.intersect.bed
# bedtools intersect -u -a $LOCI -b $EXONS > exons.intersect.bed
# rsync -av --no-perms jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/seqdata/reference/mmur/*bed /home/jelmer/Dropbox/sc_lemurs/seqdata/reference/mmur/
	