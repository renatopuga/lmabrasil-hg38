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

## Cancer Genome Interpreter (CGI) - API

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

## Visualizando os identificadores

```python
import requests
job_id ="be69dc21d218f22e5f7e"

headers = {'Authorization': 'renatopuga@gmail.com SEU_TOKEN'}
r = requests.get('https://www.cancergenomeinterpreter.org/api/v1/%s' % job_id, headers=headers)
r.json()
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

## Resultado: `alterations.tsv`

```python
pd.read_csv('/content/alterations.tsv',sep='\t',index_col=False, engine= 'python')
```


## Resultado: `biomarkers.tsv`

```python
pd.read_csv('/content/biomarkers.tsv',sep='\t',index_col=False, engine= 'python')
```

## Deletando o Job do CGI

```python
import requests
#job_id ="be69dc21d218f22e5f7e"

headers = {'Authorization': 'renatopuga@gmail.com SEU_TOKEN'}
r = requests.delete('https://www.cancergenomeinterpreter.org/api/v1/%s' % job_id, headers=headers)
r.json() 
```
