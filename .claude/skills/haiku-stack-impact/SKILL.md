---
name: haiku-stack-impact
description: Analyse l'impact d'une nouvelle technologique (release, paper, annonce produit) sur la stack data Haïku de HomeServe France. Couvre Cloud Composer/Airflow 3.x, BigQuery, Dataform, Cloud Run, Talend Cloud, Fabric/Power BI, IFS Cloud. À charger automatiquement quand un agent doit qualifier l'impact technique d'un item de veille pour un Senior Data Engineer.
---

# Haïku Stack Impact Analysis

## Composants de la stack et leurs zones de sensibilité

### Cloud Composer / Airflow 3.x

**Sensibilités** :
- Migration Airflow 2 → 3.1.x récemment finalisée. Tout breaking change Airflow 3.x est critique.
- Patterns sensibles : `airflow.sdk` migration, callback rewrites, sensor patterns, DAG factory templates
- Bugs prod connus à monitorer : Redis/Celery port exhaustion, Cloud NAT saturation, scheduler VARCHAR(20) callback_request, heartbeat timeouts
- Versions concernées : Airflow 3.1.x sur Composer 3.x

**Signaux à élever** :
- Toute release `apache/airflow` 3.x.x
- Toute release Cloud Composer (notes officielles GCP)
- Tout post post-mortem ou retour d'expérience Airflow 3 en prod
- Changements de provider GCP pour Airflow

### BigQuery

**Sensibilités** :
- SCD Type 2 historization jobs en prod
- Modèles de churn scoring
- Vector Search (POC GraphRAG)
- Pipelines via Dataform
- Coûts slot reservation

**Signaux à élever** :
- Nouveaux types de tables, syntaxes SQL, fonctions analytiques
- Changements de pricing
- Nouvelles capacités Vector Search / pgvector équivalents
- Intégrations natives BigQuery ↔ Vertex AI

### Dataform

**Sensibilités** :
- Workspaces et CI/CD Dataform
- Compilation et tests assertions
- Intégration Git

**Signaux à élever** :
- Toute release Dataform (peu fréquent → signal fort quand ça arrive)
- Nouveaux opérateurs SQLX
- Changements d'authentication / permissions

### Cloud Run

**Sensibilités** :
- Hébergement de l'agent compétitive intelligence (FastAPI + Gemini 2.5 Flash, 76 sources)
- Hébergement futur des agents Avaudroit, PocketCRM
- Cloud Run Jobs pour scrapers nocturnes

**Signaux à élever** :
- Nouvelles features Cloud Run (jobs, sidecars, GPU)
- Limites mémoire / CPU / startup time
- Intégrations avec Cloud Build / Artifact Registry

### Talend Cloud

**Sensibilités** :
- Pipeline OData Sage X3 → PostgreSQL → BigQuery (en cours)
- Job `JI_GesteCommercieaux_SF_To_Sage` reverse-engineered
- Conventions d'escaping `''` spécifiques
- Bugs connus : JGit ref corruption, MemoCode compilation, FTPS tFTPPut SSL config, tREST OAuth2 pour Keycloak IFS

**Signaux à élever** :
- Releases Talend Studio et Cloud
- Changements API Talend Cloud
- Tout retour d'expérience migration Talend → autre outil

### Microsoft Fabric / Power BI

**Sensibilités** :
- Pipeline CI/CD Fabric Git integration (GitHub Actions, Fabric REST API, FABRIC_GIT_CONNECTION_ID)
- Documentation TMDL → Markdown des semantic models
- Power BI desktop versions

**Signaux à élever** :
- Changements API Fabric REST
- Nouvelles capacités TMDL
- Évolutions Git integration

### IFS Cloud

**Sensibilités** :
- Migration en cours `hsv-migration-ifs`
- Jobs FNDMIG (_L/_M pattern)
- Idée prototype : staging table générique C1…C200 avec reconfig dynamique Source Name
- OData API + Keycloak auth + PowerShell→Python port

**Signaux à élever** :
- Releases IFS Cloud officielles (peu fréquentes mais critiques)
- Changements OData API
- Patterns de migration FNDMIG documentés

### Claude / Anthropic

**Sensibilités** :
- Usage intensif Claude Code (loops `--dangerously-skip-permissions --remote-control`)
- CLAUDE.md + LOOP_PROMPT.md methodology
- Plugins, skills, MCP servers
- Routines Claude Code (15/jour Max)

**Signaux à élever** :
- Toute release Claude (modèles, features Cowork/Code, plugins)
- Nouveaux MCP servers utiles pour data eng
- Changements de pricing / quotas
- Nouvelles capacités Agent SDK
- Patterns de sécurité (sandboxing, IAM deny policies)

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
