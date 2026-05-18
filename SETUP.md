# Setup — Procédure complète

Temps estimé : **15 minutes** dont 5 min pour le script bootstrap et 10 min pour la config UI Claude Code.

## Étape 1 — Bootstrap des deux repos (5 min)

Pré-requis : `git`, `gh` (GitHub CLI authentifié), bash.

```bash
# 1. Clone ce repo en local
git clone git@github.com:Yoz69/veille_techno.git
cd veille_techno

# 2. Lance le bootstrap (clone obsidian-vault, commits initiaux, push)
bash scripts/bootstrap.sh
```

Le script `bootstrap.sh` fait :
- Vérifie que `gh` est authentifié sur le compte Yoz69
- Clone `obsidian-vault` à côté du dossier courant
- Crée le dossier `Veille/` avec un README et un `.gitkeep` dans `obsidian-vault`
- Commit + push sur `obsidian-vault`
- Vérifie que ce repo (`veille_techno`) a bien tous les fichiers attendus

## Étape 2 — Activer Claude Code on the web (1 min)

Sur `claude.ai/settings/profile` :
- Section "Claude Code" → toggle **"Web access"** ON

Sans ça, l'option Routines n'apparaît pas.

## Étape 3 — Configurer les connectors (2 min)

Sur `claude.ai/settings/connectors` :
- ✅ **GitHub** — obligatoire. Vérifie que les deux repos `Yoz69/veille_techno` et `Yoz69/obsidian-vault` sont dans le scope (sinon ré-autorise)
- ✅ **Web Search** — déjà actif par défaut
- ⚪ **Gmail** — optionnel. Active uniquement si tu veux que la routine lise tes newsletters (recommandé : crée un label `Veille` dans Gmail et applique-le manuellement à tes newsletters de veille)

## Étape 4 — Créer la routine (5 min)

Sur `claude.ai/code/routines` → **+ New routine** → choisir **Cloud**.

Paramètres :

| Champ | Valeur |
|---|---|
| Name | `veille-ia-haiku` |
| Description | `Veille quotidienne IA + stack data (Airflow, BQ, Composer, Talend, Claude)` |
| Repository | `Yoz69/veille_techno` |
| Branch | `main` |
| Model | **Claude Sonnet 4.6** |
| Permission mode | **Auto** (branch security `claude/*` activée par défaut) |
| Worktree isolation | ✅ ON |
| Schedule trigger | Custom cron : `30 6 * * *` |
| Timezone | `Europe/Paris` |
| Prompt | Coller le contenu de `prompt.md` |

Save (mais **ne pas activer** le schedule encore).

## Étape 5 — Configurer les secrets (1 min)

Dans la routine → onglet **Secrets** → Add secret :

| Key | Value |
|---|---|
| `NTFY_TOPIC` | `pocketcrm-nighlty-Yoann` |

Optionnels :
| Key | Value |
|---|---|
| `OBSIDIAN_VAULT_REPO` | `Yoz69/obsidian-vault` (par défaut dans le prompt, à override seulement si tu changes de repo) |

## Étape 6 — Premier run manuel (5–10 min)

Dans la routine → **Run now**.

Pendant le run, vérifie en direct :
- [ ] La routine charge bien les 2 skills au démarrage (visible dans les logs)
- [ ] Elle clone bien `Yoz69/obsidian-vault` (étape "git clone")
- [ ] Elle utilise web_search et github connectors (pas inventer de sources)
- [ ] Elle crée la branche `claude/veille-ia-{date}` sur `obsidian-vault`
- [ ] Elle crée la PR sur `obsidian-vault` (pas sur `veille_techno`)
- [ ] Tu reçois la notif ntfy à la fin

Si tout est OK : ouvre la PR créée sur `Yoz69/obsidian-vault`, vérifie le format de la note. Si ça te plaît, merge.

## Étape 7 — Activer le schedule

Une fois le run manuel validé : toggle **Active** dans la routine.

À partir du lendemain matin 06h30 (Europe/Paris), tu auras automatiquement :
- Une notif ntfy ~06h35 sur ton téléphone
- Une PR en attente sur `Yoz69/obsidian-vault`
- La note disponible dans ton vault Obsidian au prochain pull

## Étape 8 — Calibration semaine 1

- Si trop de notes inintéressantes → augmente `min_score_threshold` à 65 ou 70 dans `sources.yaml`
- Si scoring tape à côté → ajuste les pondérations dans `.claude/skills/ai-watch-rules/SKILL.md`
- Si certaines sources reviennent toujours sans valeur → ajoute-les dans la `blacklist` de `sources.yaml`

Commit + push sur `veille_techno` après chaque ajustement. La routine relit la config à chaque run.

## Troubleshooting

**Le bootstrap échoue avec "permission denied"** → Vérifie `gh auth status` et `git config --global user.email`.

**La routine échoue avec "repo not found"** → Le connector GitHub doit avoir accès aux repos privés. Reconnecte-le sur `claude.ai/settings/connectors`.

**ntfy ne reçoit rien** → Teste manuellement : `curl -d "test" https://ntfy.sh/pocketcrm-nighlty-Yoann`. Si OK, vérifie que le secret `NTFY_TOPIC` est bien set dans la routine (sans guillemets).

**La routine pousse sur `veille_techno` au lieu de `obsidian-vault`** → Le prompt explicite le repo cible. Si ça arrive, vérifie que tu as bien copié-collé `prompt.md` dans son intégralité.
