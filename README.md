# lmabrasil-hg38

Versão Reduzida no Google Colab: 
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1eYSW4WI1RwxG9lIS8ohhWVWQqxJYXihD?usp=sharing)

# Workflow

# Filtrar variantes somáticas - Workflow
---

1. Clonar repositório `renatopuga/lmabrasil-hg38`
2. Instalar `bcftools +split-vep`
3. Instalar `udocker`
4. Filtrar o VCF com `filter_vep`:

  ```
  -filter "(MAX_AF <= 0.01 or not MAX_AF) and
  (FILTER = PASS or not FILTER matches strand_bias,weak_evidence) and
  (SOMATIC matches 1 or (not SOMATIC and CLIN_SIG matches pathogenic)) and
  (not CLIN_SIG matches benign) and \
  (not IMPACT matches LOW) and \
  (Symbol in hpo/$HPO)
  ```

5. Filtrar Cobertura Total e Frequência Alélica da variante com: `bcftools +split-vep`:
  - `DP>=20 AND AF>=0.1`
6. Resultado: `*.vep.filter.tsv`

### The Human Phenotype Ontology (HPO)

1. Myelofibrosis: https://hpo.jax.org/app/browse/term/HP:0011974
2. Abnormal mast cell morphology: https://hpo.jax.org/app/browse/term/HP:0100494

### Clonal Hematopoiesis drivers
1. Clonal Hematopoiesis drivers (65 genes): https://www.intogen.org/ch


# vep.sh - script


* Rodar script VEP completo (vep annot + vep_filter)
```bash
sh vep.sh WP017 Myelofibrosis.txt
```

* Rodar script VEP no Google Colab (vep_filter)
```bash
sh vep-gc.sh WP017 Myelofibrosis.txt
```

## output - .vep.filter.tsv

Sobre a amostra **WP017**.

- Class: Myelofibrosis
- Information: JAK2-
- Total de variantes no VCF: 7144
- Total de variantes pós filtro: 2

---


| CHROM |      POS |                                               REF | ALT |                Location | SYMBOL |        Consequence |     Feature |        MANE_SELECT |        BIOTYPE |                      HGVSc |                          HGVSp |  EXON | INTRON | VARIANT_CLASS |            SIFT | PolyPhen | gnomADg_AF |   MAX_AF |   IMPACT |               CLIN_SIG | SOMATIC |       Existing_variation |                                          FILTER | TumorID |   GT |  DP |     AD |    AF | NormalID |  NGT | NDP |  NAD |   NAF |
|------:|---------:|--------------------------------------------------:|----:|------------------------:|-------:|-------------------:|------------:|-------------------:|---------------:|---------------------------:|-------------------------------:|------:|-------:|--------------:|----------------:|---------:|-----------:|---------:|---------:|-----------------------:|--------:|-------------------------:|------------------------------------------------:|--------:|-----:|----:|-------:|------:|---------:|-----:|----:|-----:|------:|
| chr17 |  7669662 |                                                 T |   G |           chr17:7669662 |   TP53 |   missense_variant | NM_000546.6 |  ENST00000269305.9 | protein_coding |      NM_000546.6:c.1129A>C |        NP_000537.3:p.Thr377Pro | 11/11 |      . |           SNV | tolerated(0.42) |        . |   0.000053 | 0.000496 | MODERATE | uncertain_significance |     0&1 | rs774269719&COSV52716766 | base_qual;haplotype;normal_artifact;strand_bias |   WP017 | 0\|1 | 119 | 101,18 | 0.112 |    WP018 | 0\|0 |  60 | 55,5 | 0.049 |
| chr19 | 12943750 | GCAGAGGCTTAAGGAGGAGGAAGAAGACAAGAAACGCAAAGAGGAGGAGGAG |   A | chr19:12943751-12943802 |   CALR | frameshift_variant | NM_004343.4 | ENST00000316448.10 | protein_coding | NM_004343.4:c.1099_1150del | NP_004334.1:p.Leu367ThrfsTer46 |   9/9 |      . |      deletion |               . |        . |   0.000020 | 0.000066 |     HIGH |             pathogenic |       . |             rs1555760738 |                                            PASS |   WP017 |  0/1 | 102 |  62,40 | 0.416 |    WP018 |  0/0 |  50 | 50,0 | 0.022 |


##  Cancer Genome Interpreter

- https://www.cancergenomeinterpreter.org/analysis

![image](https://github.com/renatopuga/lmabrasil-hg38/assets/8321336/26881170-c4b9-47ac-bc26-9f817709c6f5)

---

**CGI - Resultado Resumido**

| chr 	| pos 	| alt 	| STRAND 	| CGI-Gene 	| ALT_TYPE 	| CGI-Oncogenic Prediction 	|
|---	|---	|---	|---	|---	|---	|---	|
| chr17 	| 7669662 	| G 	| + 	| TP53 	| snp 	| passenger (oncodriveMUT) 	|
| chr19 	| 12943750 	| A 	| + 	| CALR 	| indel 	| driver (oncodriveMUT) 	|

---

**CGI - resultado Completo**

| CHROMOSOME 	| POSITION 	| REF 	| ALT 	| chr 	| pos 	| ref 	| alt 	| ALT_TYPE 	| STRAND 	| CGI-Sample ID 	| CGI-Gene 	| CGI-Protein Change 	| CGI-Oncogenic Summary 	| CGI-Oncogenic Prediction 	| CGI-External oncogenic annotation 	| CGI-Mutation 	| CGI-Consequence 	| CGI-Transcript 	| CGI-STRAND 	| CGI-Type 	| CGI-HGVS 	| CGI-HGVSc 	| CGI-HGVSp 	|
|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|---	|
| 17 	| 7669662 	| T 	| G 	| chr17 	| 7669662 	| T 	| G 	| snp 	| + 	| input_gtf 	| TP53 	| T377P 	| non-oncogenic 	| passenger (oncodriveMUT) 	|  	| chr17:7669662 T>G 	| missense_variant 	| ENST00000269305 	| + 	| SNV 	| ENST00000269305:c.1129A>C;p.(Thr377Pro);p.(T377P) 	| ENST00000269305.9:c.1129A>C 	| ENSP00000269305.4:p.Thr377Pro 	|
| 19 	| 12943751 	| GCAGAGGCTTAAGGAGGAGGAAGAAGACAAGAAACGCAAAGAGGAGGAGGAG 	| - 	| chr19 	| 12943750 	| AGCAGAGGCTTAAGGAGGAGGAAGAAGACAAGAAACGCAAAGAGGAGGAGGAG 	| A 	| indel 	| + 	| input_gtf 	| CALR 	| EQRLKEEEEDKKRKEEEE364-381X 	| oncogenic (predicted and annotated) 	| driver (oncodriveMUT) 	| clinvar:97006 	| chr19:12943751-12943751 GCAGAGGCTTAAGGAGGAGGAAGAAGACAAGAAACGCAAAGAGGAGGAGGAG>- 	| frameshift_variant 	| ENST00000316448 	| + 	| DEL 	| ENST00000316448:c.1099_1150del;p.(Leu367ThrfsTer46);p.(L367Tfs*46) 	| ENST00000316448.10:c.1099_1150del 	| ENSP00000320866.4:p.Leu367ThrfsTer46 	|


## Usando CGI via API Rest no Google Colab

**Cancer Genome Interpreter (CGI) - API**

Utilizando o resultado da amostras WP048, vamos utilizar a análise do CGI através da API Rest que eles disponibilizam. Para mais informações sobre a API Rest do CGI acesse: https://www.cancergenomeinterpreter.org/rest_api

Requisitos para acessar a API:

1. Conta de usuário no CGI
2. Gerar um token para utilizar no código que chama a API (exemplo abaixo)

## Gerando Token no seu usuário CGI



Gerando o arquivo `df_WP048-cgi.txt` com as colunas: **CHR, POS, REF e ALT**. Esse arquivo será utilizando junto com a API.

> **Nota:** Os nomes das colunas, para esse formato que estamos utilizando de input, deve ser exatamente CHR, POS, REF e ALT.




```bash
%%bash
cut -f1-4 /content/lmabrasil-hg38/vep_output/liftOver_WP048_hg19ToHg38.vep.filter.tsv | sed -e "s/CHROM/CHR/g"  > df_WP048-cgi.txt
head df_WP048-cgi.txt
```

## Enviando um Job - job_id: be69dc21d218f22e5f7e

> **IMPORTANTE:** No código, onde estiver escrito: **SEU_TOKEN**, é para colar o seu código Token. Linha de código: 

`headers = {'Authorization': 'renatopuga@gmail.com SEU_TOKEN'}`

> **IMPORTANTE 2:** O jobid `cb99f036442f7b74f195` é válido, eu gerei usando o meu Token.

```python
import requests
headers = {'Authorization': 'renatopuga@gmail.com SEU_TOKEN'}
payload = {'cancer_type': 'HEMATO', 'title': 'Somatic MF', 'reference': 'hg38'}
r = requests.post('https://www.cancergenomeinterpreter.org/api/v1',
                headers=headers,
                files={
                        'mutations': open('/content/df_WP048-cgi.txt', 'rb')
                        },
                data=payload)
r.json()
```
```
be69dc21d218f22e5f7e
```

## Visualizando os identificadores

```python
import requests
job_id ="be69dc21d218f22e5f7e"

headers = {'Authorization': 'renatopuga@gmail.com SEU_TOKEN'}
r = requests.get('https://www.cancergenomeinterpreter.org/api/v1/%s' % job_id, headers=headers)
r.json()
```
```
{'status': 'Done',
 'metadata': {'id': 'be69dc21d218f22e5f7e',
  'user': 'renatopuga@gmail.com',
  'title': 'Somatic MF',
  'cancertype': 'HEMATO',
  'reference': 'hg38',
  'dataset': 'input.tsv',
  'date': '2024-01-05 15:01:08'}}
```

## Acessando informações do Job

```python
import requests
job_id ="be69dc21d218f22e5f7e"

headers = {'Authorization': 'renatopuga@gmail.com SEU_TOKEN'}
payload={'action':'logs'}
r = requests.get('https://www.cancergenomeinterpreter.org/api/v1/%s' % job_id, headers=headers, params=payload)
r.json()
```
```
{'status': 'Done',
 'logs': ['# cgi analyze input.tsv -c HEMATO -g hg38',
  '2024-01-05 16:01:13,170 INFO     Parsing input01.tsv\n',
  '2024-01-05 16:01:17,258 INFO     Running VEP\n',
  '2024-01-05 16:01:18,446 INFO     Check cancer genes and consensus roles\n',
  '2024-01-05 16:01:18,535 INFO     Annotate BoostDM mutations\n',
  '2024-01-05 16:01:18,572 INFO     Annotate OncodriveMUT mutations\n',
  '2024-01-05 16:01:21,180 INFO     Annotate validated oncogenic mutations\n',
  '2024-01-05 16:01:21,375 INFO     Check oncogenic classification\n',
  '2024-01-05 16:01:21,442 INFO     Matching biomarkers\n',
  '2024-01-05 16:01:21,535 INFO     Prescription finished\n',
  '2024-01-05 16:01:21,548 INFO     Aggregate metrics\n',
  '2024-01-05 16:01:24,808 INFO     Compress output files\n',
  '2024-01-05 16:01:24,846 INFO     Analysis done\n']}
```

## Download dos Resultados (file.zip)

```python
import requests
job_id ="be69dc21d218f22e5f7e"

headers = {'Authorization': 'renatopuga@gmail.com SEU_TOKEN'}
payload={'action':'download'}
r = requests.get('https://www.cancergenomeinterpreter.org/api/v1/%s' % job_id, headers=headers, params=payload)
with open('file.zip', 'wb') as fd:
    fd.write(r._content)
```

### Descompactando o arquivo `file.zip`

```bash
!unzip file.zip
```
```
Archive:  file.zip
  inflating: alterations.tsv         
  inflating: biomarkers.tsv          
  inflating: input01.tsv             
  inflating: summary.txt
```

## Resultado: `alterations.tsv`

```python
pd.read_csv('/content/alterations.tsv',sep='\t',index_col=False, engine= 'python')
```
| Input ID 	| CHROMOSOME 	| POSITION 	| REF 	| ALT 	| CHR 	| POS 	| ALT_TYPE 	| STRAND 	| CGI-Sample ID 	| CGI-Gene 	| CGI-Protein Change 	| CGI-Oncogenic Summary 	| CGI-Oncogenic Prediction 	| CGI-External oncogenic annotation 	| CGI-Mutation 	| CGI-Consequence 	| CGI-Transcript 	| CGI-STRAND 	| CGI-Type 	| CGI-HGVS 	| CGI-HGVSc 	| CGI-HGVSp 	|  	|
|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---	|
| 0 	| input01_1 	| 1 	| 114716123 	| C 	| T 	| chr1 	| 114716123 	| snp 	| + 	| input01 	| NRAS 	| G13D 	| oncogenic (predicted and annotated) 	| driver (boostDM: non-tissue-specific model) 	| cgi,oncokb 	| chr1:114716123 C>T 	| missense_variant 	| ENST00000369535 	| + 	| SNV 	| ENST00000369535:c.38G>A;p.(Gly13Asp);p.(G13D) 	| ENST00000369535.5:c.38G>A 	| ENSP00000358548.4:p.Gly13Asp 	|
| 1 	| input01_2 	| 9 	| 5073770 	| G 	| T 	| chr9 	| 5073770 	| snp 	| + 	| input01 	| JAK2 	| V617F 	| oncogenic (annotated) 	| passenger (oncodriveMUT) 	| cgi,oncokb 	| chr9:5073770 G>T 	| missense_variant 	| ENST00000381652 	| + 	| SNV 	| ENST00000381652:c.1849G>T;p.(Val617Phe);p.(V617F) 	| ENST00000381652.4:c.1849G>T 	| ENSP00000371067.4:p.Val617Phe 	|


## Resultado: `biomarkers.tsv`

```python
pd.read_csv('/content/biomarkers.tsv',sep='\t',index_col=False, engine= 'python')
```

| Sample ID 	| Alterations 	| Biomarker 	| Drugs 	| Diseases 	| Response 	| Evidence 	| Match 	| Source 	| BioM 	| Resist. 	| Tumor type 	|  	|
|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---:	|---	|
| 0 	| input01 	| KRAS wildtype 	| KRAS wildtype 	| Panitumumab (EGFR mAb inhibitor) 	| Colorectal adenocarcinoma 	| Responsive 	| A 	| NO 	| PMID: 31268481 	| complete 	| 621.0 	| COREAD 	|
| 1 	| input01 	| KRAS wildtype 	| KRAS wildtype 	| Cetuximab (EGFR mAb inhibitor) 	| Colorectal adenocarcinoma 	| Responsive 	| A 	| NO 	| PMID: 19339720 	| complete 	| 246.0 	| COREAD 	|
| 2 	| input01 	| JAK2 (V617F) 	| JAK2 oncogenic mutation 	| PD1 inhibitors 	| Cutaneous melanoma 	| Resistant 	| C 	| NO 	| PMID:27433843 	| complete 	| NaN 	| CM 	|
| 3 	| input01 	| NRAS (G13D) 	| NRAS (12,13,59,61,117,146) 	| Cetuximab (EGFR mAb inhibitor) 	| Colorectal adenocarcinoma 	| Resistant 	| A 	| NO 	| PMID:24024839;PMID:20619739;PMID:23325582 	| complete 	| NaN 	| COREAD 	|
| 4 	| input01 	| NRAS (G13D) 	| NRAS (Q61) 	| BRAF inhibitors 	| Cutaneous melanoma 	| Resistant 	| C 	| NO 	| PMID:23569304;PMID:24265153 	| only alteration type 	| NaN 	| CM 	|
| 5 	| input01 	| JAK2 (V617F) 	| JAK2 (V617F) 	| JAK inhibitor (alone or in combination)s 	| Acute myeloid leukemia 	| Responsive 	| D 	| YES 	| PMID:22829971 	| complete 	| NaN 	| AML 	|
| 6 	| input01 	| JAK2 (V617F) 	| JAK2 amplification 	| JAK inhibitors 	| Breast adenocarcinoma 	| Responsive 	| D 	| NO 	| PMID:27075627 	| only gene 	| NaN 	| BRCA 	|
| 7 	| input01 	| NRAS (G13D) 	| NRAS (12,13,59,61,117,146) 	| Panitumumab (EGFR mAb inhibitor) 	| Colorectal adenocarcinoma 	| Resistant 	| A 	| NO 	| FDA guidelines 	| complete 	| NaN 	| COREAD 	|
| 8 	| input01 	| JAK2 (V617F) 	| JAK2-BRAF fusion 	| Ruxolitinib (JAK inhibitor) 	| Acute lymphoblastic leukemia 	| Responsive 	| D 	| YES 	| PMID:22875628;PMID:22899477 	| only gene 	| NaN 	| ALL 	|
| 9 	| input01 	| JAK2 (V617F) 	| JAK2 (V617F) 	| Ruxolitinib (JAK inhibitor) 	| Acute myeloid leukemia 	| Responsive 	| C 	| YES 	| PMID:22422826 	| complete 	| NaN 	| AML 	|
| 10 	| input01 	| JAK2 (V617F) 	| JAK2 (V617F) 	| Ruxolitinib (JAK inhibitor) 	| Myelofibrosis 	| Responsive 	| A 	| YES 	| FDA 	| complete 	| NaN 	| MY 	|
| 11 	| input01 	| KIT wildtype 	| KIT wildtype 	| Dasatinib (BCR-ABL inhibitor 2nd gen) 	| Gastrointestinal stromal 	| Responsive 	| D 	| NO 	| PMID:16397263 	| complete 	| NaN 	| GIST 	|
| 12 	| input01 	| KIT wildtype 	| KIT wildtype 	| Sorafenib (Pan-TK inhibitor) 	| Gastrointestinal stromal 	| Responsive 	| C 	| NO 	| ASCO 2011 (abstr 10009) 	| complete 	| NaN 	| GIST 	|
| 13 	| input01 	| KIT wildtype 	| KIT wildtype 	| Sunitinib (Pan-TK inhibitor) 	| Gastrointestinal stromal 	| Responsive 	| B 	| NO 	| PMID:18955458 	| complete 	| NaN 	| GIST 	|
| 14 	| input01 	| KIT wildtype 	| KIT wildtype 	| Imatinib (BCR-ABL inhibitor 1st gen&KIT inhibitor) 	| Gastrointestinal stromal 	| Resistant 	| B 	| NO 	| PMID:18955458 	| complete 	| NaN 	| GIST 	|
| 15 	| input01 	| PDGFRA wildtype 	| PDGFRA wildtype 	| Imatinib (BCR-ABL inhibitor 1st gen&KIT inhibitor) 	| Gastrointestinal stromal 	| Resistant 	| B 	| NO 	| PMID:14645423;PMID:18955458 	| complete 	| NaN 	| GIST 	|
| 16 	| input01 	| NRAS (G13D) 	| NRAS oncogenic mutation 	| CDK4/6 inhibitor + MEK inhibitors 	| Cutaneous melanoma 	| Responsive 	| C 	| NO 	| PMID:26658964;NCT01781572;NCT02065063;NCT02022982;ASCO 2014 (abstr 9009) 	| complete 	| NaN 	| CM 	|
| 17 	| input01 	| NRAS (G13D) 	| NRAS (G12C) 	| ERK inhibitors 	| Any cancer type 	| Responsive 	| D 	| YES 	| PMID:23614898 	| only alteration type 	| NaN 	| CANCER 	|
| 18 	| input01 	| NRAS (G13D) 	| NRAS oncogenic mutation 	| ERK inhibitors 	| Cutaneous melanoma 	| Responsive 	| C 	| NO 	| ASCO 2017 (abstr 2508) 	| complete 	| NaN 	| CM 	|
| 19 	| input01 	| NRAS (G13D) 	| NRAS oncogenic mutation 	| HSP90 inhibitors 	| Cutaneous melanoma 	| Responsive 	| D 	| NO 	| PMID:23538902 	| complete 	| NaN 	| CM 	|
| 20 	| input01 	| NRAS (G13D) 	| NRAS oncogenic mutation 	| MEK inhibitor +/- PI3K pathway inhibitors 	| Colorectal adenocarcinoma 	| Responsive 	| D 	| NO 	| PMID:23274911;PMID:22392911 	| complete 	| NaN 	| COREAD 	|
| 21 	| input01 	| NRAS (G13D) 	| NRAS oncogenic mutation 	| MEK inhibitors 	| Acute myeloid leukemia, Lung adenocarcinoma, Acute lymphoblastic leukemia 	| Responsive 	| D 	| YES 	| PMID:22507781;PMID:23515407;PMID:18701506 	| complete 	| NaN 	| AML, LUAD, ALL 	|
| 22 	| input01 	| NRAS (G13D) 	| NRAS (Q61) 	| MEK inhibitors 	| Cutaneous melanoma 	| Responsive 	| B 	| NO 	| PMID:23414587,ASCO 2016 (abstr 9500) 	| only alteration type 	| NaN 	| CM 	|
| 23 	| input01 	| NRAS (G13D) 	| NRAS oncogenic mutation 	| Pan-RAF inhibitors 	| Cutaneous melanoma 	| Responsive 	| C 	| NO 	| ESMO 2015 (abstract 300);AACR 2017 (abstr CT002) 	| complete 	| NaN 	| CM 	|
| 24 	| input01 	| NRAS (G13D) 	| NRAS oncogenic mutation 	| PI3K pathway inhibitor + MEK inhibitors 	| Myeloma 	| Responsive 	| D 	| YES 	| PMID:22985491 	| complete 	| NaN 	| MYMA 	|
| 25 	| input01 	| NRAS (G13D) 	| NRAS oncogenic mutation 	| Sorafenib + MEK inhibitor (Pan-TK inhibitor + MEK inhibitor) 	| Hepatic carcinoma 	| Responsive 	| C 	| NO 	| PMID:25294897 	| complete 	| NaN 	| HC 	|
| 26 	| input01 	| PDGFRA wildtype 	| PDGFRA wildtype 	| Dasatinib (BCR-ABL inhibitor 2nd gen) 	| Gastrointestinal stromal 	| Responsive 	| D 	| NO 	| PMID:16397263 	| complete 	| NaN 	| GIST 	|
| 27 	| input01 	| PDGFRA wildtype 	| PDGFRA wildtype 	| Sorafenib (Pan-TK inhibitor) 	| Gastrointestinal stromal 	| Responsive 	| C 	| NO 	| ASCO 2011 (abstr 10009) 	| complete 	| NaN 	| GIST 	|
| 28 	| input01 	| PDGFRA wildtype 	| PDGFRA wildtype 	| Sunitinib (Pan-TK inhibitor) 	| Gastrointestinal stromal 	| Responsive 	| B 	| NO 	| PMID:18955458 	| complete 	| NaN 	| GIST 	|
| 29 	| input01 	| TP53 wildtype 	| TP53 wildtype 	| HDM2 inhibitors 	| Acute myeloid leukemia 	| Responsive 	| C 	| YES 	| AACR 2017 (abstr CT152) 	| complete 	| NaN 	| AML 	|
| 30 	| input01 	| NRAS (G13D) 	| NRAS oncogenic mutation 	| Vemurafenib (BRAF inhibitor) 	| Cutaneous melanoma 	| Resistant 	| D 	| NO 	| PMID:20179705 	| complete 	| NaN 	| CM 	|
| 31 	| input01 	| NRAS (G13D) 	| NRAS (Q61K,T50I,G13D,G60E,G12C,G12V,T58I,.,Q61H,G12R,G12D,Q61L,G13V,Q61R) 	| Panitumumab + Cetuximab 	| Colorectal adenocarcinoma 	| Resistant 	| A 	| NO 	| oncokb: oncokb=https://www.oncokb.org/gene/NRAS 	| complete 	| NaN 	| COREAD 	|
| 32 	| input01 	| NRAS (G13D) 	| NRAS (Q61K,T50I,G13D,G60E,G12C,G12V,T58I,.,Q61H,G12R,G12D,Q61L,G13V,Q61R) 	| Binimetinib + Binimetinib + Ribociclib 	| Cutaneous melanoma 	| Responsive 	| C 	| NO 	| oncokb: oncokb=https://www.oncokb.org/gene/NRAS 	| complete 	| NaN 	| CM 	|
| 33 	| input01 	| JAK2 (V617F) 	| JAK2-PCM1 fusion 	| Ruxolitinib 	| Eosinophilic chronic leukemia 	| Responsive 	| C 	| YES 	| oncokb: oncokb=https://www.oncokb.org/gene/JAK2 	| only gene 	| NaN 	| ECL 	|
| 34 	| input01 	| NRAS (G13D) 	| NRAS (Q61K,T50I,G13D,G60E,G12C,G12V,T58I,.,Q61H,G12R,G12D,Q61L,G13V,Q61R) 	| Selumetinib 	| Thyroid carcinoma 	| Responsive 	| C 	| NO 	| oncokb: oncokb=https://www.oncokb.org/gene/NRAS 	| complete 	| NaN 	| THCA 	|
| 35 	| input01 	| BRAF wildtype 	| BRAF WILD TYPE 	| MEK Inhibitor RO4987655 	| Cutaneous melanoma 	| Resistant 	| B 	| NO 	| https://civicdb.org/links/molecular_profiles/422 	| complete 	| NaN 	| CM 	|
| 36 	| input01 	| EGFR wildtype 	| EGFR Wildtype 	| Gefitinib 	| Non-small cell lung 	| Resistant 	| B 	| NO 	| https://civicdb.org/links/molecular_profiles/2050 	| complete 	| NaN 	| NSCLC 	|
| 37 	| input01 	| JAK2 (V617F) 	| JAK2 Splice Site (c.1641+2T>G) 	| Pembrolizumab 	| Cutaneous melanoma 	| Resistant 	| C 	| NO 	| https://civicdb.org/links/molecular_profiles/1589 	| only alteration type 	| NaN 	| CM 	|
| 38 	| input01 	| KIT wildtype 	| KIT WILDTYPE 	| Regorafenib 	| Gastrointestinal stromal 	| Response 	| B 	| NO 	| https://civicdb.org/links/molecular_profiles/2520 	| complete 	| NaN 	| GIST 	|
| 39 	| input01 	| NRAS (G13D) 	| NRAS G13D 	| Tanespimycin 	| Cutaneous melanoma 	| Response 	| C 	| NO 	| https://civicdb.org/links/molecular_profiles/93 	| complete 	| NaN 	| CM 	|
| 40 	| input01 	| NRAS (G13D) 	| NRAS Mutation 	| MEK Inhibitor RO4987655 	| Cutaneous melanoma 	| Resistant 	| C 	| NO 	| https://civicdb.org/links/molecular_profiles/208 	| complete 	| NaN 	| CM 	|
| 41 	| input01 	| NRAS (G13D) 	| NRAS Mutation 	| Dabrafenib,Vemurafenib 	| Cutaneous melanoma 	| Resistant 	| B 	| NO 	| https://civicdb.org/links/molecular_profiles/208 	| complete 	| NaN 	| CM 	|
| 42 	| input01 	| NRAS (G13D) 	| NRAS Mutation 	| Trametinib 	| Cutaneous melanoma 	| Response 	| B 	| NO 	| https://civicdb.org/links/molecular_profiles/208 	| complete 	| NaN 	| CM 	|
| 43 	| input01 	| NRAS (G13D) 	| NRAS Mutation 	| Trametinib,Omipalisib 	| Cutaneous melanoma 	| Response 	| D 	| NO 	| https://civicdb.org/links/molecular_profiles/208 	| complete 	| NaN 	| CM 	|
| 44 	| input01 	| NRAS (G13D) 	| NRAS Mutation 	| Binimetinib 	| Cutaneous melanoma 	| Response 	| D 	| NO 	| https://civicdb.org/links/molecular_profiles/208 	| complete 	| NaN 	| CM 	|
| 45 	| input01 	| NRAS (G13D) 	| NRAS Q61 	| Vemurafenib 	| Cutaneous melanoma 	| Resistant 	| B 	| NO 	| https://civicdb.org/links/molecular_profiles/94 	| only alteration type 	| NaN 	| CM 	|
| 46 	| input01 	| NRAS (G13D) 	| NRAS Q61K 	| Binimetinib,Everolimus 	| Neuroblastoma 	| Response 	| D 	| NO 	| https://civicdb.org/links/molecular_profiles/423 	| only alteration type 	| NaN 	| NB 	|
| 47 	| input01 	| NRAS (G13D) 	| NRAS Q61K 	| Trametinib,Selumetinib 	| Non-small cell lung 	| Response 	| D 	| NO 	| https://civicdb.org/links/molecular_profiles/423 	| only alteration type 	| NaN 	| NSCLC 	|
| 48 	| input01 	| NRAS (G13D) 	| NRAS Q61L 	| Temozolomide 	| Cutaneous melanoma 	| Response 	| C 	| NO 	| https://civicdb.org/links/molecular_profiles/95 	| only alteration type 	| NaN 	| CM 	|
| 49 	| input01 	| NRAS (G13D) 	| NRAS Q61R 	| Temozolomide 	| Cutaneous melanoma 	| Response 	| C 	| NO 	| https://civicdb.org/links/molecular_profiles/96 	| only alteration type 	| NaN 	| CM 	|
| 50 	| input01 	| TP53 wildtype 	| TP53 Wildtype 	| Adjuvant Chemotherapy 	| Non-small cell lung 	| Response 	| B 	| NO 	| https://civicdb.org/links/molecular_profiles/365 	| complete 	| NaN 	| NSCLC 	|

## Deletando o Job do CGI

```python
import requests
#job_id ="be69dc21d218f22e5f7e"

headers = {'Authorization': 'renatopuga@gmail.com SEU_TOKEN'}
r = requests.delete('https://www.cancergenomeinterpreter.org/api/v1/%s' % job_id, headers=headers)
r.json() 
```
