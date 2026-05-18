# veille

Configuration d'une routine Claude Code qui exécute une veille quotidienne pour un Analytics Engineer, couvrant BigQuery, Dataform, Salesforce, Marketing Cloud, Power BI, Dataplex Catalog, DuckDB, Streamlit, gouvernance data et documentation. La routine pousse les notes dans le vault Obsidian [`benjaminschaal/wiki`](https://github.com/benjaminschaal/wiki) et notifie par email via ntfy.

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│ Routine Claude Code (cloud, daily 06:30 Paris)              │
│ ├── attached repo: benjaminschaal/veille                    │
│ │   ├── lit prompt.md (instructions)                        │
│ │   ├── lit sources.yaml (sources à scruter)                │
│ │   └── charge .claude/skills/* (scoring + impact)          │
│ │                                                            │
│ ├── exécution :                                             │
│ │   1. collecte (web_search, github, gmail, LinkedIn)       │
│ │   2. scoring + analyse impact                             │
│ │   3. rédaction note markdown                              │
│ │                                                            │
│ └── output :                                                 │
│     ├── push vers benjaminschaal/wiki (branche claude/*)    │
│     ├── PR auto vers main                                   │
│     └── notif email via ntfy.sh (benjamin.schaal@free.fr)   │
└──────────────────────────────────────────────────────────────┘
```

## Structure du repo

```
veille/
├── .claude/
│   └── skills/
│       ├── ai-watch-rules/SKILL.md        # scoring + format AE
│       └── haiku-stack-impact/SKILL.md    # impact stack AE
├── scripts/
│   ├── ntfy-notify.sh                     # notif email + ntfy
│   └── bootstrap.sh                       # init des deux repos
├── prompt.md                              # instructions routine
├── sources.yaml                           # liste sources tier 1/2/3
└── README.md
```

## Quotas (plan Max)

- **Routines** : 1/jour utilisé / 15 disponibles → marge confortable
- **Modèle** : Sonnet 4.6 (Opus inutile, économie quota subscription)
- **Run typique** : 5–10 min, ~5% d'une fenêtre 5h

## Setup

Voir `SETUP.md` pour la procédure complète. TL;DR :

1. Lance `bash scripts/bootstrap.sh` localement (clone + commits initiaux des 2 repos)
2. Active "Claude Code on the web" et le connector GitHub sur `claude.ai/settings`
3. Crée la routine sur `claude.ai/code/routines` en pointant vers ce repo
4. Configure les secrets :
   - `NTFY_TOPIC=veille-data-benjamin`
   - `NOTIFY_EMAIL=benjamin.schaal@free.fr`
5. Lance un **Run now** manuel pour valider, puis active le schedule

## Calibration

Première semaine = mode observation. Tu lis les notes générées et tu merges les bonnes PR. À partir de la semaine 2, ajuste les pondérations dans `.claude/skills/ai-watch-rules/SKILL.md` selon les sujets qui t'ont vraiment intéressé.

## Maintenance

Édite `sources.yaml` pour ajouter/retirer des sources. Pas besoin de redémarrer la routine, elle relit le fichier à chaque run.

Pour ajouter un nouveau composant stack à monitorer (ex: nouvelle techno adoptée), édite `.claude/skills/haiku-stack-impact/SKILL.md` et ajoute la section correspondante.

Stack couverte : BigQuery, Dataform, Cloud Composer/Airflow, Salesforce, Marketing Cloud, Power BI, Fabric, Dataplex Catalog, DuckDB, Streamlit, Terraform, Cloud Run, Claude/Anthropic, Obsidian.
