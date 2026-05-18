---
name: ai-watch-rules
description: Règles de scoring et de mise en forme pour les notes de veille IA et stack data. À charger automatiquement quand un agent prépare une note de veille technologique pour un Senior Data Engineer travaillant sur GCP/Airflow/BigQuery/Talend/Fabric.
---

# AI Watch Rules — Scoring & Format

## Grille de scoring (sur 100)

### Pertinence stack (40 pts max)

Composants prioritaires (poids fort) :
- Cloud Composer / Airflow 3.x → +40 si l'item touche directement
- BigQuery → +35
- Dataform → +30
- Cloud Run / Cloud Build → +25
- Anthropic Claude (Code, Cowork, API, Agent SDK, MCP) → +35
- Microsoft Fabric / Power BI → +25
- Talend Cloud → +25
- IFS Cloud / Sage X3 → +25
- Pub/Sub, GCS, Vertex AI → +20

Composants secondaires (+10 à +15) :
- Python / FastAPI / pgvector / PostgreSQL
- Terraform / IaC GCP
- Observability (OpenTelemetry, Datadog, GCP Operations)

Composants ignorés (score 0 sur ce critère) :
- AWS-only sans transposable
- Frontend pur (sauf si lié à un agent)
- Crypto / Web3
- Hardware grand public

### Actionnabilité (30 pts max)

- **30 pts** : impact direct sur du code maintenu (Airflow DAG, requête BigQuery, job Talend) — exemple : breaking change Airflow 3.2, deprecation BQ
- **25 pts** : nouvelle feature qui peut remplacer ou améliorer une partie de la stack
- **20 pts** : pattern architectural transposable à un projet en cours
- **15 pts** : info utile pour une décision tech court terme
- **10 pts** : utile pour culture générale tech sans action immédiate
- **0 pt** : informatif pur, marketing, recyclage

### Nouveauté (20 pts max)

- **20 pts** : info que je ne pouvais pas connaître via mes sources habituelles (paper récent, release surprise, leak)
- **15 pts** : annonce officielle majeure du jour
- **10 pts** : analyse approfondie d'une annonce récente
- **5 pts** : récap ou dérivé d'une annonce déjà connue
- **0 pt** : recyclage de contenu vu il y a plus de 7 jours

### Profondeur technique (10 pts max)

- **10 pts** : code, benchmarks chiffrés, architecture détaillée, retours d'expérience prod
- **7 pts** : analyse technique sérieuse sans être deep-tech
- **5 pts** : article généraliste correctement rédigé
- **0 pt** : post LinkedIn vide, thread Twitter sans substance, communiqué de presse pur

## Seuils

- **≥ 80** : Top 5 garanti, à mettre en avant
- **60–79** : Section "Le reste", liste compacte
- **40–59** : Faibles signaux (2-3 max), notés pour suivi sans détail
- **< 40** : ignoré, pas mentionné

## Sources de qualité par tier

**Tier 1** (signal fort par défaut, +5 pts bonus actionnabilité) : Anthropic news/engineering, Google Cloud release notes, Apache Airflow GitHub releases, arXiv cs.LG/cs.AI avec citations existantes, Talend release notes officielles

**Tier 2** (signal moyen, scoring normal) : Google Cloud blog (hors marketing), Microsoft Fabric blog, Latent Space, The Batch, Data Engineering Weekly

**Tier 3** (signal à filtrer, -5 pts pertinence) : Hacker News (sauf top 5 du jour), r/dataengineering (sauf > 100 upvotes), Medium/dev.to (sauf auteurs identifiés), LinkedIn posts (sauf comptes officiels Anthropic/Google/Microsoft)

## Format de sortie

### Frontmatter obligatoire

```yaml
---
date: {YYYY-MM-DD}
tags: [veille, ia, data-eng]
nb_items: {entier}
top_score: {entier 0-100}
sources_scrutees: {entier}
---
```

### Item Top 5 — Format

```markdown
### {N}. {Titre traduit en français si besoin}

**Source** : [{nom source}]({url}) · **Score** : {score}/100 · **Tier** : {1|2|3}

{Résumé en 3-4 lignes max, en français, en tes propres mots. Jamais de copie-collé. Mentionne un chiffre ou un fait précis si l'article en contient.}

**🎯 Impact stack** : {composant impacté} — {type d'impact}

**▶ Action** : {action recommandée} — {1 ligne pourquoi}

**Tags** : `#veille/ia` `#stack/{composant}` `#tier/{1-3}`

---
```

### Item liste compacte (score 60-79)

```markdown
- **{Titre court}** · [{source}]({url}) · score {N} · {1 ligne pourquoi c'est noté}
```

### Faibles signaux

```markdown
> 🔮 **{Titre}** ({source}) — {2 lignes max sur pourquoi suivre sans agir maintenant}
```

## Anti-patterns à éviter

- ❌ Liste de tous les items collectés sans filtrage
- ❌ Résumés > 5 lignes
- ❌ Tags génériques (`#tech`, `#news`) au lieu de `#stack/composer`
- ❌ Liens vers des paywalls (Bloomberg, WSJ, FT) sans alternative gratuite
- ❌ Citation directe de contenu copyrighted
- ❌ Verbiage marketing ("révolutionnaire", "game-changer", "disruptif")
- ❌ Ton enthousiaste artificiel — la veille est un outil de travail

## Tags Obsidian recommandés

- `#veille/ia` `#veille/data-eng` `#veille/cloud`
- `#stack/composer` `#stack/bigquery` `#stack/dataform` `#stack/cloudrun` `#stack/talend` `#stack/fabric` `#stack/ifs` `#stack/claude`
- `#impact/breaking` `#impact/feature` `#impact/risque` `#impact/opportunite`
- `#tier/1` `#tier/2` `#tier/3`
- `#action/creuser` `#action/prototyper` `#action/documenter` `#action/monitorer`
