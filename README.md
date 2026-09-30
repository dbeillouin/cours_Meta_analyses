# Meta-analysis and systematic reviews in ecology and agronomy

Course material of the FRB-CESAB training course (2026), sessions by Damien Beillouin (CIRAD): slides, practical pages and the participant kit. All sessions use the same real data, the global database of diversified farming experiments of Jones et al. (2021, *Scientific Data* 8:212).

**Website:** https://dbeillouin.github.io/cours_Meta_analyses/

The material of the previous editions (2024–2025) is kept under the tag [`v2025`](https://github.com/dbeillouin/cours_Meta_analyses/tree/v2025).
**After the course:** the online notebook https://literaturesynthesis.github.io/notebook

## For participants

Download `kit_meta_analysis_course_2026.zip` from the website, unzip it, open `meta_analysis_course.Rproj` in RStudio and run `00_install_and_check.R`.

## For the authors

| Folder | Content |
|---|---|
| `seances/` | slides (Quarto revealjs), one folder per session |
| `td/` | practical pages and the R scripts given to participants |
| `kit/` | participant kit (README, install check, .Rproj); scripts and data are copied in by `R/build_kit.R` |
| `donnees/` | raw data (`brutes/`) and derived files (`derivees/`, built by `R/00_prepare_data.R`) |
| `theme/` | FRB-CESAB 2026 theme |
| `diapos/` | rendered files (generated) |
| `docs/` | website published by GitHub Pages (generated) |

Rebuild everything:

```sh
Rscript R/00_prepare_data.R   # only if the raw data change
quarto render                 # slides + practicals -> diapos/ + participant kit
Rscript R/build_site.R        # website -> docs/
```
