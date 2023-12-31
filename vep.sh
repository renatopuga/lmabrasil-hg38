SAMPLE="$1"
HPO="$2"
CHAIN="hg19ToHg38.over.chain"
VEPCACHE="/Users/renatopuga/reference/vep"
GENOME="hg38.fa"
ASSEMBLY="GRCh38"
export BCFTOOLS_PLUGINS=~/opt/bcftools/plugins


## adicionar no VCF do projeto LMA o chr
rm -vf $SAMPLE.filtered.chr.vcf.gz $SAMPLE.filtered.chr.vcf.gz.tbi

zgrep "\#" $SAMPLE.filtered.vcf.gz > $SAMPLE.filtered.chr.vcf
zgrep -v "\#" $SAMPLE.filtered.vcf.gz | awk '{print("chr"$0)}' >> $SAMPLE.filtered.chr.vcf

bgzip $SAMPLE.filtered.chr.vcf
tabix -p vcf $SAMPLE.filtered.chr.vcf.gz


# gatk LiftoverVcf
~/opt/gatk-4.2.6.1/gatk LiftoverVcf \
-I $SAMPLE.filtered.chr.vcf.gz \
-O liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vcf.gz \
--CHAIN $CHAIN \
--REJECT liftOver_Reject_$SAMPLE\_$(basename $CHAIN .over.chain).vcf \
-R $GENOME


## vep
mkdir -p vep_output
chmod 777 vep_output

time docker run -it --rm -v $VEPCACHE:/cache -v $(pwd):/data ensemblorg/ensembl-vep:release_110.1 vep \
-i /data/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vcf.gz  \
-o /data/vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.vcf \
--assembly $ASSEMBLY  \
--refseq \
--fork 8 \
--buffer_size 200 \
--force_overwrite \
--dir_cache /cache \
--offline \
--cache \
--no_intergenic \
--distance 0 \
--pick \
--individual $SAMPLE \
--vcf \
--symbol \
--biotype \
--hgvs \
--mane_select \
--numbers \
--af_gnomadg \
--max_af \
--variant_class \
--sift b \
--variant_class \
--polyphen b \
--check_existing \
--fields "Location,SYMBOL,Consequence,Feature,MANE_SELECT,BIOTYPE,HGVSc,HGVSp,EXON,INTRON,VARIANT_CLASS,SIFT,PolyPhen,gnomADg_AF,MAX_AF,IMPACT,CLIN_SIG,SOMATIC,Existing_variation" \
--fasta /data/$GENOME


## filter_vep
docker run --rm -it -v `pwd`:`pwd` -w `pwd` ensemblorg/ensembl-vep filter_vep \
-i vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.vcf \
-filter "(MAX_AF <= 0.01 or not MAX_AF) and \
(FILTER = PASS or not FILTER matches strand_bias,weak_evidence) and \
(SOMATIC matches 1 or (not SOMATIC and CLIN_SIG matches pathogenic)) and (not CLIN_SIG matches benign) and \
(not IMPACT matches LOW) and \
(Symbol in hpo/$HPO)"  \
--force_overwrite \
-o vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.filter.vcf

## bcftools +split-vep

# 1. criar o cabeçalho
bcftools +split-vep -l vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.filter.vcf | \
cut -f2  | \
tr '\n\r' '\t' | \
awk '{print("CHROM\tPOS\tREF\tALT\t"$0"FILTER\tTumorID\tGT\tDP\tAD\tAF\tNormalID\tNGT\tNDP\tNAD\tNAF")}' > vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.filter.tsv

# 2. adicionar as variantes
bcftools +split-vep \
-f '%CHROM\t%POS\t%REF\t%ALT\t%CSQ\t%FILTER\t[%SAMPLE\t%GT\t%DP\t%AD\t%AF\t]\n' \
-i 'FMT/DP>20 && FMT/AF>0.1' -d -A tab vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .o

## bcftools +split-vep

~/opt/bcftools/bcftools +split-vep -l vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.filter.vcf | \
cut -f2  | \
tr '\n\r' '\t' | \
awk '{print("CHROM\tPOS\tREF\tALT\t"$0"FILTER\tTumorID\tGT\tDP\tAD\tAF\tNormalID\tGT\tDP\tAD\tAF")}' > vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.filter.tsv

#~/opt/bcftools/bcftools +split-vep -f '%CHROM\t%POS\t%REF\t%ALT\t%CSQ\t%FILTER\t[%GT\t%DP\t%AD\t%AF\t]\n' \
#-d -A tab vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.filter.vcf \
#-p x >> vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.tsv

~/opt/bcftools/bcftools +split-vep \
-f '%CHROM\t%POS\t%REF\t%ALT\t%CSQ\t%FILTER\t[%SAMPLE\t%GT\t%DP\t%AD\t%AF\t]\n' \
-i 'FMT/DP>=20 && FMT/AF>=0.1' -d -A tab vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.filter.vcf \
-p x  >> vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.filter.tsv
