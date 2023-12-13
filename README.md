# lmabrasil-hg38

Versão Reduzida no Google Colab: 
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1eYSW4WI1RwxG9lIS8ohhWVWQqxJYXihD?usp=sharing)

# Workflow

# Fitrar variantes somáticas - Workflow
---

1. Clonar repositório `renatopuga/lmabrasil-hg38`
2. Instalar `bcftools +split-vep`
3. Instlar `udocker`
4. Filtra o VCF com `filter_vep`:

  ```filter "(MAX_AF <= 0.01 or not MAX_AF) and
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

1. Myelofibrosis with myeloid metaplasia, somatic: https://hpo.jax.org/app/browse/disease/OMIM:254450
2. 
Systemic mastocytosis with associated hematologic neoplasm : https://hpo.jax.org/app/browse/disease/ORPHA:98849



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
- Total de variantes pós filtro: 1

---


| CHROM |   POS |      REF |                                               ALT | Location |                  SYMBOL | Consequence |            Feature | MANE_SELECT |            BIOTYPE |          HGVSc |                      HGVSp |                           EXON | INTRON | VARIANT_CLASS |     SIFT | PolyPhen | gnomADg_AF |  MAX_AF |   IMPACT | CLIN_SIG |    SOMATIC | Existing_variation |       FILTER | TumorID |    GT |  DP |  AD |    AF | NormalID |   NGT | NDP | NAD |  NAF |       |
|------:|------:|---------:|--------------------------------------------------:|---------:|------------------------:|------------:|-------------------:|------------:|-------------------:|---------------:|---------------------------:|-------------------------------:|-------:|--------------:|---------:|---------:|-----------:|--------:|---------:|---------:|-----------:|-------------------:|-------------:|--------:|------:|----:|----:|------:|---------:|------:|----:|----:|-----:|-------|
|   0   | chr19 | 12943750 | AGCAGAGGCTTAAGGAGGAGGAAGAAGACAAGAAACGCAAAGAGGA... |        A | chr19:12943751-12943802 |        CALR | frameshift_variant | NM_004343.4 | ENST00000316448.10 | protein_coding | NM_004343.4:c.1099_1150del | NP_004334.1:p.Leu367ThrfsTer46 |    9/9 |             . | deletion |        . |          . | 0.00002 | 0.000066 |     HIGH | pathogenic |                  . | rs1555760738 |    PASS | WP017 | 0/1 | 102 | 62,40 |    0.416 | WP018 | 0/0 |  50 | 50,0 | 0.022 |
