## TO DO: REMOVE HIGH_DEPTH LOCI? SEE VCF2FULLFA2
## TO DO: REMOVE FIRST FEW BASES? SEEMS TO BE THE CUTSITE
## TO DO: REMOVE BASES FROM NEG-STRAND LOCI IN OTHER DIRECTION

################################################################################
GSTACKS_ID=hzproj
POPSTACKS_ID=grimurche.og
SET_ID_FULL=$GSTACKS_ID.$POPSTACKS_ID
INDFILE=/datacommons/yoderlab/users/jelmer/proj/iim/indsel/stacks_popmap/$POPSTACKS_ID.txt

SCR_STACKSFAPIP=/datacommons/yoderlab/users/jelmer/scripts/geno/stacks/stacksfa_pip.sh
BASEDIR=/datacommons/yoderlab/users/jelmer/proj/sisp/seqdata/stacks/$SET_ID/$SUBSET_ID/
REF=/datacommons/yoderlab/users/jelmer/seqdata/reference/mmur/GCF_000165445.2_Mmur_3.0_genomic_stitched.fasta
SCAF_FILE=/datacommons/yoderlab/users/jelmer/seqdata/reference/mmur/scaffoldLength_NC.txt
BAMDIR=/datacommons/yoderlab/data/radseq/bam/map2mmur/final_merged/
BAMSUFFIX=".sort.MQ30.dedup"
CALLABLE_COMMAND="--minDepth 3"
MAXMISS_IND=10
MAXMISS_MEAN=5
MINDIST=10000
FASTA_RAW=$BASEDIR/fasta/$SET_ID.$SUBSET_ID.samples.fa
VCF_RAW=$BASEDIR/vcf/$SET_ID.$SUBSET_ID.snps.vcf
VCF_FILT=$BASEDIR/vcf/$SET_ID.$SUBSET_ID.skipMiss.mac1.vcf
SKIP_INDPART="-Z" #"-CVWM"  C: CALLABLELOCI / V: VCF-MASK / W: WGFASTA / M: MASKFASTA / E: EXTRACT_LOCUSFASTA / S: LOCUSSTATS
SKIP_JOINTPART="-Z" #F: FILTER_LOCI / E: EXTRACT_LOCI / M: MERGE_FASTA / S: SPLIT_FASTA
SKIP_PIP="" # I: INDPART / J: JOINTPART 

$SCR_STACKSFAPIP $SET_ID_FULL $INDFILE $BASEDIR $FASTA_RAW $VCF_RAW $VCF_FILT \
	$REF $SCAF_FILE $BAMDIR $BAMSUFFIX "$CALLABLE_COMMAND" $MAXMISS_IND $MAXMISS_MEAN $MINDIST \
	$SKIP_INDPART $SKIP_JOINTPART $SKIP_PIP

	
################################################################################
# rsync -avr --no-perms /home/jelmer/Dropbox/sc_lemurs/scripts/ jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/scripts/
# rsync -avr --no-perms /home/jelmer/Dropbox/sc_lemurs/radseq/metadata/ jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/radseq/metadata/

# rsync -avr --no-perms jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/*mber* /home/jelmer/Dropbox/sc_lemurs/proj/sisp/geno/

# rsync -avr --no-perms jwp37@dcc-slogin-02.oit.duke.edu:/datacommons/yoderlab/users/jelmer/proj/sisp/seqdata/stacks/berrufmyo/3s1//loci/ /home/jelmer/Dropbox/sc_lemurs/proj/sisp/geno/

