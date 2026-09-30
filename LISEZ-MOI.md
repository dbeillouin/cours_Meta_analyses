# Cours méta-analyse FRB-CESAB 2026 : où est quoi ?

## Je veux…

| Je veux… | J'ouvre… |
|---|---|
| **Projeter une séance** | `diapos/01-introduction.html` : double-clic, ça s'ouvre dans le navigateur. Un seul fichier, qui marche aussi hors ligne. |
| Voir mes **notes d'orateur** pendant la séance | Dans la présentation, touche **S** |
| Envoyer ou imprimer les diapos | `diapos/01-introduction.pdf` |
| **Préparer les participants** | envoyer `email_participants.md` une semaine avant, avec le lien du site. Ils téléchargent **un seul kit** : `diapos/kit_meta_analysis_course_2026.zip` (4 scripts de TD + données + script d'installation qui se termine par « All good ») |
| Donner un TD | projeter la page `diapos/0X-..._TD.html` ; les participants ouvrent `meta_analysis_course.Rproj` du kit puis le script du TD |
| Modifier le kit | `kit/meta_analysis_course_2026/` (README, script d'installation) ; scripts et données y sont recopiés automatiquement par `quarto render` |
| **Mettre le site en ligne** | `quarto render` puis `Rscript R/build_site.R` → dossier `docs/` (page d'accueil `site/index.qmd`), publié par GitHub Pages |
| Modifier un TD | `td/02-td-evidence-map/td.qmd` (la page), `td/02-td-evidence-map/pack_participants/` (ce que les participants reçoivent) |
| **Modifier le texte d'une séance** | `seances/01-introduction/slides.qmd`. C'est du texte Markdown : une diapo commence par `##`. |
| Changer une image d'une séance | `seances/01-introduction/img/` |
| Changer les couleurs ou le style de **toutes** les diapos | `theme/cesab.src.scss`, puis `python3 theme/build_theme.py` |
| Ajouter une référence | `references.bib` (commun à toutes les séances), puis citer avec `@clé` dans le `.qmd` |
| Lire ou modifier le **notebook en ligne** (livre de référence pour après le cours) | dossier voisin `../notebook/` : `_book/index.html` pour le lire, `chapters/*.qmd` pour le modifier, `quarto render` dans ce dossier pour le reconstruire. Règles d'écriture : `STYLE.md`. |
| Voir ou changer la **préparation des données** | `R/00_prepare_data.R` : le seul script qui touche aux données |

## L'arborescence

```
cours_2026/
│
├── LISEZ-MOI.md            ← ce fichier
│
├── diapos/                 ← CE QUE TU PROJETTES / DISTRIBUES (généré, ne pas modifier)
│   ├── 01-introduction.html / .pdf
│   ├── 02-td-evidence-map.html / .pdf          diapos de cadrage du TD
│   ├── 02-td-evidence-map_TD.html              la page du TD (énoncés + solutions repliées)
│   ├── 03-effect-sizes.html / .pdf             tailles d'effet (mercredi 9h)
│   ├── 03-effect-sizes_formula_sheet.pdf       fiche de formules A4 à imprimer/distribuer
│   ├── 04-models.html / .pdf                   modèles fixes/aléatoires/multiniveaux (mercredi 14h)
│   ├── 04-models_TD.html                       la page du TD modèles
│   ├── 05-bias.html / .pdf + 05-bias_TD.html    biais (mercredi 15h)
│   ├── 06-advanced.html / .pdf + 06-advanced_TD.html   méthodes avancées (mercredi 16h15)
│   ├── kit_meta_analysis_course_2026.zip        LE kit unique pour les participants
│   └── (les anciens packs par séance sont remplacés par le kit unique)
│
├── seances/                ← CE QUE TU MODIFIES : une séance = un dossier
│   ├── _metadata.yml         réglages communs (taille, numéros de diapo, auteur…)
│   ├── 01-introduction/
│   │   ├── slides.qmd        le texte et le code des diapos
│   │   └── img/              les images de la séance
│   ├── 02-td-evidence-map/slides.qmd
│   ├── 03-effect-sizes/slides.qmd
│   ├── 04-models/slides.qmd
│   ├── 05-bias/slides.qmd
│   └── 06-advanced/slides.qmd
│
├── td/                     ← LES TD : une page HTML + un pack participants par TD
│   ├── 02-td-evidence-map/
│   │   ├── td.qmd            la page du TD
│   │   └── pack_participants/   script à trous, .Rproj, données, 00_install.R
│   ├── 03-effect-sizes/formula_sheet.qmd   la fiche de formules
│   ├── 04-models/   td.qmd + pack_participants/
│   ├── 05-bias/     td.qmd + pack_participants/
│   └── 06-advanced/ td.qmd + pack_participants/
│
├── donnees/                ← le jeu fil rouge (Jones et al. 2021)
│   ├── brutes/               fichiers Excel originaux, jamais modifiés
│   └── derivees/             CSV produits par R/00_prepare_data.R
│
├── R/                      ← le code R commun
│   ├── 00_prepare_data.R     construit tous les jeux de données de la semaine
│   ├── theme_cesab.R         style ggplot commun (couleurs Cesab)
│   └── post_render.R         copie automatiquement diapos et TD dans diapos/ et zippe les packs
│
├── theme/                  ← le masque Cesab 2026 transposé en Quarto
├── references.bib          ← bibliographie commune
└── _quarto.yml             ← réglages du projet (ne pas toucher)
```

Les dossiers `_site/` et `_freeze/` sont créés automatiquement au rendu : tu peux les ignorer.

## Regénérer les diapos après une modification

Dans RStudio, ouvre le dossier `cours_2026` comme projet, puis, dans le **Terminal** (pas la console R) :

```bash
quarto render
```

Les nouvelles versions arrivent dans `diapos/` (les PDF d'aperçu, eux, ne sont pas regénérés automatiquement). Pour voir les changements en direct pendant que tu écris :

```bash
quarto preview seances/01-introduction/slides.qmd
```

Si tu as modifié les données brutes, relance d'abord `Rscript R/00_prepare_data.R`.

Packages R nécessaires : `dplyr`, `tidyr`, `readr`, `readxl`, `ggplot2`, `metafor`.

## Le jeu de données fil rouge

Jones SK, Sánchez AC, Juventia SD, Estrada-Carmona N (2021). *A global database of diversified farming effects on biodiversity and yield.* Scientific Data 8:212. https://doi.org/10.1038/s41597-021-01000-y

| Fichier (`donnees/derivees/`) | Contenu | Utilisé pour |
|---|---|---|
| `screening_records.csv` | 1 590 références criblées, dont 237 incluses | diagramme PRISMA/ROSES, screening |
| `comparisons_all.csv` | 4 076 comparaisons, 237 études | carte des preuves (mardi), intro |
| `intercropping_biodiversity.csv` | 888 comparaisons, 42 études | tailles d'effet, modèles, biais, modérateurs, SD manquants (24 %) |
| `biodiversity_yield_pairs.csv` | 1 096 comparaisons, 49 études | compromis biodiversité × rendement |

⚠ Une ligne = une **comparaison**, pas une étude. Pour compter les études : `n_distinct(study_id)`.

## Mémo : écrire une diapo avec le masque Cesab

| Élément | Ce qu'on écrit dans le `.qmd` |
|---|---|
| Nouvelle diapo | `## Titre de la diapo` |
| Objectifs (pastilles numérotées) | `## Learning objectives {.objectives}` puis une liste `1.` `2.`… |
| Séparateur de partie | `# Titre {.section-divider background-image="../../theme/img/bg-keymessages.jpg"}` |
| Question ou sondage | `## Titre {.question}` puis un bloc `::: question-card` |
| Encadré | `::: {.box}` … `:::` (couleurs : `.blue`, `.green`, `.warn`) |
| Source en bas de diapo | `::: {.source}` → `Source: @jones2021.` |
| Messages clés (mise en page du masque) | `## Key messages {.key-messages background-image="../../theme/img/bg-keymessages.jpg"}` puis 4 points maximum |
| Notes d'orateur | `::: notes` … `:::` |
| Faire apparaître au clic | `::: {.fragment}` … `:::` |

Chaque séance suit le même plan : objectifs → contenu → au moins une interaction → messages clés → références.

## Astuce rendu

Si des caractères comme `<U+00B9>` apparaissent dans les sorties R des TD, lancer le rendu en UTF-8 :
`LANG=C.UTF-8 LC_ALL=C.UTF-8 quarto render`
