# diretorio
cd lmabrasil-hg38/

## variaveis de ambiente
SAMPLE="$1"
CHAIN="hg19ToHg38.over.chain"

## vep

#rm -rf vep_output/*.filter*
mkdir -p vep_output
chmod 777 vep_output

#---------------------------------------------------#
# Aqui tinha a etapa do VEP                         #
# Ver: https://github.com/renatopuga/lmabrasil-hg38 #
#---------------------------------------------------#

## filter_vep
udocker --allow-root run --rm  -v `pwd`:`pwd` -w `pwd` ensemblorg/ensembl-vep filter_vep \
-i vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.vcf \
-filter "(MAX_AF <= 0.01 or not MAX_AF) and \
(FILTER = PASS or not FILTER matches strand_bias,weak_evidence) and \
(SOMATIC matches 1 or (not SOMATIC and CLIN_SIG matches pathogenic)) and (not CLIN_SIG matches benign) and \
(not IMPACT matches LOW) and \
(Symbol in hpo/Myelofibrosis.txt)"  \
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
-i 'FMT/DP>20 && FMT/AF>0.1' -d -A tab vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.filter.vcf \
-p x  >> vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.filter.tsv
