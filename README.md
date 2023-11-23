# lmabrasil-hg38

# Workflow

1. Entrar com o código WP na execução: `sh vep.sh WP017`
2. Fazer download do VCF.gz e VCF.gz.tbi no Google Drive
3. Limpar/Deletar arquivos anteriores dessa amostra
4. Adicionar o `chr` no arquivo VCF e cria um novo arquivo chamado `.chr.vcf.gz`
5. `bzgip` para compactar
6. `tabix -p vcf` para indexar o vcf
7. Exceutar o `LiftoverVcf` para converter hg19Tohg38
8. (docker) Anotar com ensembl-vep:release_110.1 (refseq/hg38)
9. (docker)
10. filter_vep

```bash
1. (MAX_AF <= 0.01 or not MAX_AF) and
2. (FILTER = PASS or not FILTER matches weak_evidence) and
4. (SOMATIC matches 1 or (not SOMATIC and CLIN_SIG matches pathogenic)) and
5. (not CLIN_SIG matches benign) and (not IMPACT matches LOW)
```

11. `bcftools +split-vep`: `-i 'FMT/DP>20 && FMT/AF>0.25'`
12. Output: `vep.filter.tsv`


# vep.sh - script

```bash
SAMPLE="$1"
CHAIN="hg19ToHg38.over.chain"
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

time docker run -it --rm -v /Users/renatopuga/reference/vep:/cache -v $(pwd):/data ensemblorg/ensembl-vep:release_110.1 vep \
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
--mane \
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
(SOMATIC matches 1 or (not SOMATIC and CLIN_SIG matches pathogenic)) and (not CLIN_SIG matches benign) and (not IMPACT matches LOW)"  \
--force_overwrite \
-o vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.filter.vcf

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
-i 'FMT/DP>20 && FMT/AF>0.25' -d -A tab vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.filter.vcf \
-p x  >> vep_output/liftOver_$SAMPLE\_$(basename $CHAIN .over.chain).vep.filter.tsv

```

## output - .vep.filter.tsv

Sobre a amostra **WP017**.

- Mutation: JAK2-
- karyotype: .
- Total de variantes no VCF: 7144
- Total filtradas: 22

---


| CHROM | POS       | REF                                                   | ALT        | Location                | SYMBOL   | Consequence             | Feature        | MANE_SELECT        | BIOTYPE        | HGVSc                        | HGVSp                          | EXON  | INTRON | VARIANT_CLASS       | SIFT                             | PolyPhen                 | gnomADg_AF  | MAX_AF     | IMPACT   | CLIN_SIG                       | SOMATIC     | Existing_variation                                           | FILTER                                                 | TumorID | GT      | DP   | AD         | AF                | NormalID | GT   | DP   | AD         | AF                |
| ----- | --------- | ----------------------------------------------------- | ---------- | ----------------------- | -------- | ----------------------- | -------------- | ------------------ | -------------- | ---------------------------- | ------------------------------ | ----- | ------ | ------------------- | -------------------------------- | ------------------------ | ----------- | ---------- | -------- | ------------------------------ | ----------- | ------------------------------------------------------------ | ------------------------------------------------------ | ------- | ------- | ---- | ---------- | ----------------- | -------- | ---- | ---- | ---------- | ----------------- |
| chr1  | 114716127 | C                                                     | T          | chr1:114716127          | NRAS     | missense_variant        | NM_002524.5    | ENST00000369535.5  | protein_coding | NM_002524.5:c.34G>A          | NP_002515.1:p.Gly12Ser         | 2/7   | .      | SNV                 | deleterious_low_confidence(0.02) | .                        | .           | .          | MODERATE | pathogenic&likely_pathogenic   | 0&0&0&1&1&1 | rs121913250&CM136798&CM177295&COSV54736487&COSV54736621&COSV54736940 | PASS                                                   | WP017   | 0/1     | 232  | 117,115    | 0.504             | WP018    | 0/0  | 155  | 152,3      | 0.028             |
| chr1  | 152304661 | G                                                     | C          | chr1:152304661          | FLG      | missense_variant        | NM_002016.2    | ENST00000368799.2  | protein_coding | NM_002016.2:c.10225C>G       | NP_002007.1:p.Arg3409Gly       | 3/3   | .      | SNV                 | tolerated(0.9)                   | benign(0.001)            | 0.0000804   | 0.004      | MODERATE | .                              | 0&0&1&1     | rs201356558&CM147321&COSV100911827&COSV64242759              | clustered_events;haplotype;strand_bias                 | WP017   | 0\|1    | 22   | 17,5       | 0.261             |          |      |      |            |                   |
| chr11 | 115209621 | G                                                     | A          | chr11:115209621         | CADM1    | missense_variant        | NM_001301043.2 | ENST00000331581.11 | protein_coding | NM_001301043.2:c.1031C>T     | NP_001287972.1:p.Thr344Ile     | 8/12  | .      | SNV                 | tolerated(0.26)                  | benign(0.027)            | .           | .          | MODERATE | .                              | 1           | COSV100523062                                                | PASS                                                   | WP017   | 0/1     | 44   | 19,25      | 0.694             | WP018    | 0/0  | 25   | 24,1       | 0.082             |
| chr12 | 132140028 | C                                                     | T          | chr12:132140028         | DDX51    | intron_variant          | NM_175066.4    | ENST00000397333.4  | protein_coding | NM_175066.4:c.1775+70G>A     | .                              | .     | 12/14  | SNV                 | .                                | .                        | 0.00002628  | 0.001      | MODIFIER | .                              | 0&1         | rs117634899&COSV57959025                                     | PASS                                                   | WP017   | 0/1     | 343  | 168,175    | 0.504             | WP018    | 0/0  | 168  | 167,1      | 0.013             |
| chr14 | 24119817  | G                                                     | A          | chr14:24119817          | DCAF11   | missense_variant        | NM_025230.5    | ENST00000446197.8  | protein_coding | NM_025230.5:c.1013G>A        | NP_079506.3:p.Arg338His        | 11/15 | .      | SNV                 | deleterious(0)                   | probably_damaging(0.998) | .           | .          | MODERATE | .                              | 1           | COSV58109096                                                 | PASS                                                   | WP017   | 0/1     | 54   | 39,15      | 0.307             | WP018    | 0/0  | 45   | 45,0       | 0.021             |
| chr14 | 59727407  | G                                                     | A          | chr14:59727407          | RTN1     | missense_variant        | NM_021136.3    | ENST00000267484.10 | protein_coding | NM_021136.3:c.1277C>T        | NP_066959.1:p.Ala426Val        | 3/9   | .      | SNV                 | tolerated(0.42)                  | benign(0.013)            | .           | 0.00003378 | MODERATE | .                              | 0&1         | rs775149031&COSV99957109                                     | PASS                                                   | WP017   | 0/1     | 198  | 100,98     | 0.484             | WP018    | 0/0  | 105  | 104,1      | 0.018             |
| chr15 | 24675943  | G                                                     | A          | chr15:24675943          | NPAP1    | missense_variant        | NM_018958.3    | ENST00000329468.5  | protein_coding | NM_018958.3:c.76G>A          | NP_061831.2:p.Ala26Thr         | 1/1   | .      | SNV                 | tolerated(0.41)                  | benign(0)                | 0.00001315  | 0.00002413 | MODERATE | .                              | 0&1         | rs759520625&COSV100274550                                    | PASS                                                   | WP017   | 0/1     | 247  | 119,128    | 0.519             | WP018    | 0/0  | 141  | 137,4      | 0.037             |
| chr16 | 67616834  | G                                                     | A          | chr16:67616834          | CTCF     | missense_variant        | NM_006565.4    | ENST00000264010.10 | protein_coding | NM_006565.4:c.1042G>A        | NP_006556.1:p.Glu348Lys        | 5/12  | .      | SNV                 | deleterious(0)                   | possibly_damaging(0.631) | .           | .          | MODERATE | .                              | 1           | COSV50461493                                                 | PASS                                                   | WP017   | 0/1     | 224  | 101,123    | 0.538             | WP018    | 0/0  | 68   | 66,2       | 0.044             |
| chr16 | 71389851  | G                                                     | A          | chr16:71389851          | CALB2    | missense_variant        | NM_001740.5    | ENST00000302628.9  | protein_coding | NM_001740.5:c.802G>A         | NP_001731.2:p.Glu268Lys        | 11/11 | .      | SNV                 | deleterious(0.04)                | .                        | 0.0003548   | 0.003458   | MODERATE | .                              | 0&1         | rs143855539&COSV56941045                                     | PASS                                                   | WP017   | 0/1     | 158  | 91,67      | 0.443             | WP018    | 0/0  | 87   | 85,2       | 0.037             |
| chr16 | 74452195  | A                                                     | C          | chr16:74452195          | GLG1     | 3_prime_UTR_variant     | NM_001145667.2 | ENST00000422840.7  | protein_coding | NM_001145667.2:c.*972T>G     | .                              | 26/26 | .      | SNV                 | .                                | .                        | 0.000006598 | 0.00001475 | MODIFIER | .                              | 0&1         | rs879190793&COSV99215916                                     | base_qual;normal_artifact;strand_bias                  | WP017   | 0/1     | 49   | 30,19      | 0.357             | WP018    | 0/0  | 23   | 21,2       | 0.064             |
| chr19 | 12943750  | AGCAGAGGCTTAAGGAGGAGGAAGAAGACAAGAAACGCAAAGAGGAGGAGGAG | A          | chr19:12943751-12943802 | CALR     | frameshift_variant      | NM_004343.4    | ENST00000316448.10 | protein_coding | NM_004343.4:c.1099_1150del   | NP_004334.1:p.Leu367ThrfsTer46 | 9/9   | .      | deletion            | .                                | .                        | 0.00001971  | 0.0000655  | HIGH     | pathogenic                     | .           | rs1555760738                                                 | PASS                                                   | WP017   | 0/1     | 102  | 62,40      | 0.416             | WP018    | 0/0  | 50   | 50,0       | 0.022             |
| chr19 | 35673516  | A                                                     | C          | chr19:35673516          | UPK1A    | missense_variant        | NM_007000.4    | ENST00000222275.3  | protein_coding | NM_007000.4:c.439A>C         | NP_008931.1:p.Thr147Pro        | 5/8   | .      | SNV                 | deleterious(0)                   | probably_damaging(0.998) | .           | 0.004605   | MODERATE | .                              | 0&1         | rs772813244&COSV104382444                                    | normal_artifact;position;strand_bias                   | WP017   | 0/1     | 48   | 36,12      | 0.253             | WP018    | 0/0  | 21   | 19,2       | 0.05              |
| chr19 | 45319445  | T                                                     | G          | chr19:45319445          | CKM      | intron_variant          | NM_001824.5    | ENST00000221476.4  | protein_coding | NM_001824.5:c.193+76A>C      | .                              | .     | 2/7    | SNV                 | .                                | .                        | 0.0004068   | 0.001523   | MODIFIER | .                              | 0&1         | rs901522342&COSV55534846                                     | PASS                                                   | WP017   | 0/1     | 36   | 21,15      | 0.407             |          |      |      |            |                   |
| chr2  | 137450992 | G                                                     | A          | chr2:137450992          | THSD7B   | missense_variant        | NM_001316349.2 | ENST00000409968.6  | protein_coding | NM_001316349.2:c.3107G>A     | NP_001303278.1:p.Arg1036Gln    | 15/28 | .      | SNV                 | deleterious(0)                   | probably_damaging(0.999) | 0.00005261  | 0.000478   | MODERATE | .                              | 0&1         | rs780774101&COSV55693881                                     | PASS                                                   | WP017   | 0/1     | 86   | 47,39      | 0.452             | WP018    | 0/0  | 54   | 52,2       | 0.057             |
| chr2  | 218880905 | A                                                     | C          | chr2:218880905          | WNT10A   | 5_prime_UTR_variant     | NM_025216.3    | ENST00000258411.8  | protein_coding | NM_025216.3:c.-91A>C         | .                              | 1/4   | .      | SNV                 | .                                | .                        | 0.0003093   | 0.0005245  | MODIFIER | .                              | 0&1         | rs993736779&COSV51461763                                     | base_qual;normal_artifact;strand_bias                  | WP017   | 0/1     | 63   | 43,20      | 0.265             | WP018    | 0/0  | 34   | 30,4       | 0.043             |
| chr20 | 32434638  | A                                                     | AG         | chr20:32434638-32434639 | ASXL1    | frameshift_variant      | NM_015338.6    | ENST00000375687.10 | protein_coding | NM_015338.6:c.1934dup        | NP_056153.2:p.Gly646TrpfsTer12 | 13/13 | .      | insertion           | .                                | .                        | 0.0006444   | 0.001739   | HIGH     | likely_pathogenic&pathogenic   | 0&1         | rs750318549&COSV60102510                                     | PASS                                                   | WP017   | 0/1     | 118  | 59,59      | 0.492             | WP018    | 0/0  | 62   | 60,2       | 0.045             |
| chr21 | 41901750  | C                                                     | T          | chr21:41901750          | C2CD2    | splice_acceptor_variant | NM_015500.2    | ENST00000380486.4  | protein_coding | NM_015500.2:c.1433-1G>A      | .                              | .     | 11/13  | SNV                 | .                                | .                        | .           | .          | HIGH     | .                              | 1           | COSV61599711                                                 | normal_artifact                                        | WP017   | 0/1     | 118  | 65,53      | 0.46              | WP018    | 0/0  | 84   | 80,4       | 0.052             |
| chr21 | 43094667  | T                                                     | G          | chr21:43094667          | U2AF1    | missense_variant        | NM_006758.3    | ENST00000291552.9  | protein_coding | NM_006758.3:c.470A>C         | NP_006749.1:p.Gln157Pro        | 6/8   | .      | SNV                 | deleterious_low_confidence(0)    | possibly_damaging(0.541) | 0.00007313  | 0.0001146  | MODERATE | not_provided&likely_pathogenic | 0&1&1       | rs371246226&COSV52341120&COSV52341147                        | PASS                                                   | WP017   | 0/1     | 163  | 89,74      | 0.457             | WP018    | 0/0  | 107  | 105,2      | 0.029             |
| chr3  | 75738979  | C                                                     | T,A        | chr3:75738979           | ZNF717   | missense_variant        | NM_001290208.3 | ENST00000652011.2  | protein_coding | NM_001290208.3:c.644G>T      | NP_001277137.1:p.Gly215Val     | 5/5   | .      | SNV                 | tolerated(0.16)                  | benign(0.005)            | .           | .          | MODERATE | .                              | 0&1&1       | rs113708852&COSV68858146&COSV68859883                        | clustered_events;germline;multiallelic;normal_artifact | WP017   | 0/1/2   | 628  | 329,25,274 | 0.026,0.541       | WP018    | 0/0  | 301  | 143,10,148 | 0.022,0.582       |
| chr3  | 133380804 | G                                                     | A          | chr3:133380804          | TMEM108  | missense_variant        | NM_023943.4    | ENST00000321871.11 | protein_coding | NM_023943.4:c.1093G>A        | NP_076432.1:p.Asp365Asn        | 4/6   | .      | SNV                 | tolerated(0.26)                  | benign(0.003)            | 0.000006572 | 0.001      | MODERATE | .                              | 0&1         | rs79118437&COSV58878167                                      | PASS                                                   | WP017   | 0/1     | 204  | 119,85     | 0.413             | WP018    | 0/0  | 159  | 156,3      | 0.026             |
| chr6  | 150248927 | GT                                                    | G,GTT,GTTT | chr6:150248928          | PPP1R14C | 3_prime_UTR_variant     | NM_030949.3    | ENST00000361131.5  | protein_coding | NM_030949.3:c.*109_*108insTT | .                              | 4/4   | .      | sequence_alteration | .                                | .                        | 0.0002068   | 0.0008587  | MODIFIER | .                              | 0&1         | rs369389461&COSV63175733                                     | germline;multiallelic;normal_artifact                  | WP017   | 0/1/2/3 | 115  | 43,58,10,4 | 0.457,0.083,0.035 | WP018    | 0/0  | 68   | 37,26,4,1  | 0.362,0.061,0.026 |
| chr7  | 584561    | G                                                     | A          | chr7:584561             | PRKAR1B  | missense_variant        | NM_001164760.2 | ENST00000537384.6  | protein_coding | NM_001164760.2:c.716C>T      | NP_001158232.1:p.Thr239Met     | 8/11  | .      | SNV                 | deleterious_low_confidence(0)    | possibly_damaging(0.817) | .           | .          | MODERATE | .                              | 1           | COSV64319594                                                 | PASS                                                   | WP017   | 0/1     | 118  | 62,56      | 0.474             | WP018    | 0/0  | 63   | 62,1       | 0.033             |
