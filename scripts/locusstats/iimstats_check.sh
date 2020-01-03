cd /datacommons/yoderlab/users/jelmer/
## Inds in vcf: mgan007 mgan008 mgan014 mgri044 mgri045 mgri051 mgri088 mgri093 mgri104 mmur001 mmur006 mmur009 mmur052 mmur056 mmur066 cmed001 ccro003
## Focal inds: mgri051 mmur009

################################################################################
#### SET-UP ####
################################################################################
## Input files:
VCF=/datacommons/yoderlab/users/jelmer/proj/hybridzone/geno/stacks/hzproj/grimurche.og/vcf/hzproj.grimurche.og.skipMiss.mac1.vcf
FASTA_IN=proj/hybridzone/geno/stacks/hzproj/grimurche.og/exonunmasked/fasta/hzproj.grimurche.og.exonunmasked.exonunmasked.filtered.fasta
LOCUSSTATS=/datacommons/yoderlab/users/jelmer/proj/hybridzone/geno/stacks/hzproj/grimurche.og/exonunmasked/loci/hzproj.grimurche.og.exonunmasked.exonunmasked.locusstats_filtered.txt

## Locus:
LOCUS=L102191
#LOCUS=L206082
IND1=ccro003
IND2=cmed001
IND3=mgri051
IND4=mmur009

## Output files:
OUTDIR=proj/iim/analyses/qc
LOCID=$OUTDIR/$LOCUS


################################################################################
#### CREATE LOCUS-FASTA AND LOCUS-BED ####
################################################################################
grep -A 1 $LOCUS $FASTA_IN | grep -ve -- > $LOCID.fa
grep $LOCUS $LOCUSSTATS | cut -f 2,3,4 > $LOCID.bed


################################################################################
#### CHECK VCF FILES ####
################################################################################
## Filtered Stacks vcf:
grep "^#" $VCF > $LOCID.vcf
bedtools intersect -wa -a $VCF -b $LOCID.bed >> $LOCID.vcf
vcftools --vcf $LOCID.vcf --indv $IND1 --recode --stdout | grep -v "#"
vcftools --vcf $LOCID.vcf --indv $IND1 --indv $IND2 --indv $IND3 --indv $IND4 --mac 1 --recode --stdout | grep -v "#"

## Raw stacks vcf:
VCF_RAW=/datacommons/yoderlab/users/jelmer/proj/hybridzone/geno/stacks/hzproj/grimurche.og/vcf/hzproj.grimurche.og.snps.vcf
grep "^#" $VCF_RAW > $LOCID.raw.vcf
bedtools intersect -wa -a $VCF_RAW -b $LOCID.bed >> $LOCID.raw.vcf
vcftools --vcf $LOCID.raw.vcf --indv $IND1 --recode --stdout | grep -v "#"

## Raw GATK vcf:
VCF_RAW_GATK=/datacommons/yoderlab/data/radseq/vcf/map2mmur.gatk.joint/intermed/grimurche.og.rawSNPs.ABHet.vcf.gz
zgrep "^#" $VCF_RAW_GATK > $LOCID.raw.gatk.vcf
bedtools intersect -wa -a $VCF_RAW_GATK -b $LOCID.bed >> $LOCID.raw.gatk.vcf
vcftools --vcf $LOCID.raw.gatk.vcf --indv $IND1 --indv $IND2 --indv $IND3 --indv $IND4 --mac 1 --recode --stdout | grep -v "#"
vcftools --vcf $LOCID.raw.gatk.vcf --indv $IND1 --recode --stdout | grep -v "#"

vcftools --vcf $LOCID.vcf --indv $IND3 --recode --stdout | grep -v "#" | grep "0/1"
vcftools --vcf $LOCID.raw.gatk.vcf --indv $IND3 --recode --stdout | grep -v "#" | grep "0/1"

vcftools --vcf $LOCID.vcf --indv $IND1 --recode --stdout | grep -v "#" | grep "1/1"
vcftools --vcf $LOCID.raw.gatk.vcf --indv $IND1 --recode --stdout | grep -v "#" | grep "1/1"

## Filtered GATK vcf:
# /datacommons/yoderlab/data/radseq/vcf/map2mmur.gatk.joint//final//grimurche.og.mac1.FS7.vcf.gz


################################################################################
#### CHECK OTHER FILES ####
################################################################################
## Check raw fasta:
FASTA_ORG=/datacommons/yoderlab/users/jelmer/proj/hybridzone/geno/stacks/hzproj/grimurche.og/fasta/hzproj.grimurche.og.samples.fa
grep -A 1 "CLocus_206082_" $FASTA_ORG > $LOCID.orgstacks.fa

## Check bamfile:
#samtools view $IND.$LOCUS.bam
BAM=/datacommons/yoderlab/data/radseq/bam/map2mmur/final_merged/$IND.sort.MQ30.dedup.bam
bedtools intersect -wa -a $BAM -b $LOCID.bed > $OUTDIR/$IND.$LOCUS.bam
bedtools genomecov -bg -ibam $OUTDIR/$IND.$LOCUS.bam




################################################################################
################################################################################
## Create callable Loci:
JAVA=/datacommons/yoderlab/programs/java_1.8.0/jre1.8.0_144/bin/java
GATK=/datacommons/yoderlab/programs/gatk-3.8-0/GenomeAnalysisTK.jar
REF=/datacommons/yoderlab/users/jelmer/seqdata/reference/mmur/GCF_000165445.2_Mmur_3.0_genomic_stitched.fasta
BAM=/datacommons/yoderlab/data/radseq/bam/map2mmur/final_merged/ccro003.sort.MQ30.dedup.bam
BED_CALLABLE=proj/hybridzone/geno/stacks/hzproj/grimurche.og/bed/ccro003.callable.bed
CALLABLE_SMR=proj/hybridzone/geno/stacks/hzproj/grimurche.og/bed/ccro003.callable_summary.txt
$JAVA -Xmx4G -jar $GATK -T CallableLoci -R $REF -I $BAM --minDepth 3 -summary $CALLABLE_SMR -o $BED_CALLABLE_RAW

## Check callable loci:
BED_CALLABLE=proj/hybridzone/geno/stacks/hzproj/grimurche.og/bed/ccro003.callable.bed
bedtools intersect -wa -a $BED_CALLABLE -b $LOCUS_BED

## Check gvcf:
GVCF=/datacommons/yoderlab/data/radseq/vcf/map2mmur.gatk.ind/gvcf/$IND1.rawvariants.g.vcf
grep "^#" $GVCF > $LOCID.$IND1.gvcf
bedtools intersect -wa -a $GVCF -b $LOCID.bed >> $LOCID.$IND1.gvcf
less $LOCID.$IND1.gvcf
