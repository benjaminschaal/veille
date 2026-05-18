---
name: haiku-stack-impact
description: Analyse l'impact d'une nouvelle technologique sur la stack data d'un Analytics Engineer. Couvre BigQuery, Dataform, Salesforce/Marketing Cloud, Power BI/Fabric, Dataplex Catalog, Cloud Composer/Airflow, DuckDB, Streamlit, Terraform, Cloud Run, Claude/Anthropic.
---

# Analytics Engineer Stack Impact Analysis

## Composants de la stack et leurs zones de sensibilité

### Cloud Composer / Airflow 3.x

**Sensibilités** :
- Orchestration des pipelines Dataform et data apps
- Patterns DAG, sensors, callbacks
- Versions Airflow 3.x

**Signaux à élever** :
- Toute release apache/airflow 3.x.x
- Breaking changes ou deprecations
- Nouveaux providers GCP pour Airflow
- Retours d'expérience Airflow en prod

### BigQuery

**Sensibilités** :
- Cœur des pipelines analytiques AE
- Modèles et vues analytiques
- Pipelines Dataform
- Coûts slot reservation

**Signaux à élever** :
- Nouveaux types de tables, syntaxes SQL, fonctions analytiques
- Changements de pricing ou slot policies
- Nouvelles capacités (Vector Search, BQML, Vertex AI intégration)
- Optimisations de perf (partitioning, clustering)

### Dataform

**Sensibilités** :
- Cœur de la transformation AE — modèles SQL, assertions, tests
- Workspaces et CI/CD Dataform
- Compilation et assertions
- Intégration Git et deployment

**Signaux à élever** :
- Toute release Dataform (peu fréquent → signal fort quand ça arrive)
- Nouveaux opérateurs SQLX ou fonctionnalités
- Changements d'authentication / permissions
- Évolutions de la documentation AE

### Power BI / Microsoft Fabric

**Sensibilités** :
- Semantic layer et modèles Power BI
- Fabric pipelines et CI/CD Git integration
- Reports et dashboards
- Integration avec BigQuery

**Signaux à élever** :
- Changements API Fabric REST
- Nouvelles capacités TMDL ou semantic model
- Évolutions Git integration
- Nouvelles sources de données natives

### DuckDB

**Sensibilités** :
- Analytics local et testing
- Requêtes analytiques rapides en Python/dbt
- Extensions (spatial, Arrow, JSON)
- Intégration BigQuery pour export/testing

**Signaux à élever** :
- Nouvelles releases DuckDB avec optimisations
- Nouvelles extensions utiles (spatial, time series)
- Benchmarks SQL et perf comparées BigQuery
- Patterns DuckDB pour testing Dataform

### Terraform / Terragrunt

**Sensibilités** :
- Provisioning GCP : BigQuery datasets, IAM, Cloud Run, Composer environments
- Infrastructure as Code pour la stack data
- Versioning et collaboration

**Signaux à élever** :
- Nouveaux providers GCP
- Changements Terraform Cloud / Terraform Enterprise
- Patterns Terragrunt pour réutilisabilité
- Security best practices (IAM, state management)

### Data Catalog & Gouvernance

**Composants** : Dataplex Universal Catalog, Coalesce Catalog, OpenMetadata, Atlan, DataHub

**Sensibilités** :
- Lineage automatique Dataform → BigQuery
- Metadata management et documentation
- Data contracts et qualité
- Glossaire métier
- Découverte et accessibilité des données

**Signaux à élever** :
- Nouvelles features catalog (lineage, data profiling, data sharing)
- Standards data contracts (dbt, OpenMetadata)
- Intégrations BigQuery ↔ catalog
- Frameworks gouvernance data

### Salesforce / Marketing Cloud

**Sensibilités** :
- API REST Salesforce (Bulk API v2, SOQL)
- Marketing Cloud API et Journey Builder
- Salesforce Data Cloud
- Connecteurs BigQuery ↔ Salesforce
- ETL Salesforce → BigQuery

**Signaux à élever** :
- Changements API Salesforce ou versioning
- Nouvelles intégrations Marketing Cloud
- Évolutions Salesforce Data Cloud
- Patterns de synchronisation / replication

### Streamlit

**Sensibilités** :
- Data apps Python connectées BigQuery / Dataform
- Dashboards interactifs
- Prototypage rapide d'analyses

**Signaux à élever** :
- Nouvelles features Streamlit (multipage, database connectors)
- Intégrations cloud (Streamlit Cloud vs auto-hosted)
- Patterns de performance pour grandes datasets

### Claude / Anthropic

**Sensibilités** :
- Claude Code pour l'automatisation de tâches AE
- MCP servers pour integration data stack
- Agent SDK pour agents IA data
- APIs et pricing

**Signaux à élever** :
- Releases Claude (modèles, features Code/Cowork)
- Nouveaux MCP servers pour data eng
- Changements de pricing / quotas
- Nouvelles capacités Agent SDK
- Patterns de sécurité et IAM

### Obsidian / Documentation

**Sensibilités** :
- PKM et documentation de la stack
- Wiki interne AE
- Runbooks et guides

**Signaux à élever** :
- Nouvelles features Obsidian (templates, plugins)
- Patterns de documentation technique
- Tools complémentaires (Dataflakes, Git sync)

## Catégorisation de l'impact

Pour chaque item, choisis **une seule** catégorie :

| Catégorie | Définition | Exemples |
|---|---|---|
| `breaking` | Va casser du code en prod si pas adressé | Deprecation, removal, signature change |
| `feature` | Nouvelle capacité à tester/intégrer | Nouvel opérateur, nouveau service, nouvelle API |
| `risque` | Vulnérabilité, incident, faille de sécurité | CVE, data leak, post-mortem critique |
| `opportunite` | Optimisation possible (perf, coût, DX) | Nouveau pricing, nouveau pattern plus simple |
| `inspiration` | Idée architecturale transposable | Article de fond, paper, talk |
| `monitoring` | À surveiller sans action immédiate | Roadmap annoncée, beta features |

## Action recommandée

Pour chaque item du Top 5, recommande **une seule** action :

| Action | Quand l'utiliser |
|---|---|
| `à creuser` | Lecture approfondie nécessaire avant décision |
| `à prototyper` | Mérite un POC dans la semaine |
| `à documenter` | À ajouter au runbook / wiki d'équipe |
| `à monitorer` | À garder sous surveillance, ré-évaluer dans X semaines |
| `ignorer après vérif` | Vérification faite, pas d'impact, classé sans suite |

## Format de sortie pour la section "Impact stack"

```markdown
**🎯 Impact stack** : [{composant principal}] — [{catégorie}]

{1-2 lignes expliquant concrètement quel code/job/process est impacté}

**▶ Action** : `{action}` — {1 ligne sur le pourquoi et l'horizon de temps}
```

## Anti-patterns

- ❌ Lister tous les composants stack alors qu'un seul est concerné
- ❌ Recommander "à creuser" par défaut — sois sélectif, l'inflation des "à creuser" tue le signal
- ❌ Inventer un impact spéculatif si l'item n'a pas de lien clair avec la stack
- ❌ Mélanger plusieurs catégories d'impact dans le même item
