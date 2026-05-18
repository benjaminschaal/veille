#!/usr/bin/env bash
# bootstrap.sh
# Initialise les deux repos benjaminschaal/veille et benjaminschaal/wiki pour la routine de veille.
#
# Pré-requis:
#   - git installé
#   - gh (GitHub CLI) authentifié sur le compte benjaminschaal (gh auth status)
#   - Lancé depuis la racine du repo benjaminschaal/veille cloné en local
#
# Ce que fait le script:
#   1. Vérifie les pré-requis
#   2. Vérifie que ce repo (benjaminschaal/veille) a tous les fichiers attendus
#   3. Clone benjaminschaal/wiki à côté
#   4. Crée le dossier Notes 📝/Veille/ avec README + .gitkeep dans wiki
#   5. Commit et push sur main de wiki
#   6. Affiche un récap des étapes manuelles UI restantes

set -euo pipefail

# --- Couleurs ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Bootstrap routine veille data & analytics${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# --- Étape 1 : Vérifier les pré-requis ---
echo -e "${YELLOW}[1/6]${NC} Vérification des pré-requis..."

if ! command -v git &> /dev/null; then
  echo -e "${RED}❌ git non installé${NC}"
  exit 1
fi

if ! command -v gh &> /dev/null; then
  echo -e "${RED}❌ gh (GitHub CLI) non installé${NC}"
  echo "  Installation: https://cli.github.com/"
  exit 1
fi

if ! gh auth status &> /dev/null; then
  echo -e "${RED}❌ gh non authentifié${NC}"
  echo "  Lance: gh auth login"
  exit 1
fi

GH_USER=$(gh api user --jq .login)
if [[ "${GH_USER}" != "benjaminschaal" ]]; then
  echo -e "${YELLOW}⚠️  Utilisateur gh authentifié: ${GH_USER} (attendu: benjaminschaal)${NC}"
  read -p "Continuer quand même ? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi
fi

echo -e "${GREEN}✅ Pré-requis OK (gh user: ${GH_USER})${NC}"
echo ""

# --- Étape 2 : Vérifier que ce repo (benjaminschaal/veille) est correct ---
echo -e "${YELLOW}[2/6]${NC} Vérification du repo benjaminschaal/veille..."

EXPECTED_FILES=(
  "prompt.md"
  "sources.yaml"
  "scripts/ntfy-notify.sh"
  ".claude/skills/ai-watch-rules/SKILL.md"
  ".claude/skills/haiku-stack-impact/SKILL.md"
  "README.md"
  "SETUP.md"
)

MISSING=0
for f in "${EXPECTED_FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo -e "${RED}  ❌ Manquant: $f${NC}"
    MISSING=$((MISSING + 1))
  fi
done

if [[ $MISSING -gt 0 ]]; then
  echo -e "${RED}❌ ${MISSING} fichier(s) manquant(s) dans benjaminschaal/veille${NC}"
  echo "  Lance ce script depuis la racine du repo benjaminschaal/veille après avoir copié tous les fichiers."
  exit 1
fi

echo -e "${GREEN}✅ Tous les fichiers attendus sont présents${NC}"
echo ""

# --- Étape 3 : chmod sur les scripts ---
echo -e "${YELLOW}[3/6]${NC} Permissions sur les scripts..."
chmod +x scripts/*.sh
echo -e "${GREEN}✅ Scripts exécutables${NC}"
echo ""

# --- Étape 4 : Validation YAML ---
echo -e "${YELLOW}[4/6]${NC} Validation YAML de sources.yaml..."
if command -v python3 &> /dev/null; then
  if python3 -c "import yaml; yaml.safe_load(open('sources.yaml'))" 2>/dev/null; then
    echo -e "${GREEN}✅ sources.yaml valide${NC}"
  else
    echo -e "${RED}❌ sources.yaml invalide${NC}"
    exit 1
  fi
else
  echo -e "${YELLOW}⚠️  python3 absent, skip validation YAML${NC}"
fi
echo ""

# --- Étape 5 : Clone et init wiki ---
echo -e "${YELLOW}[5/6]${NC} Initialisation de wiki..."

WIKI_DIR="../wiki"
if [[ -d "$WIKI_DIR" ]]; then
  echo "  wiki existe déjà localement à $WIKI_DIR"
  read -p "  Réinitialiser ? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$WIKI_DIR"
  else
    echo "  Skip clone, on utilise le repo existant."
  fi
fi

if [[ ! -d "$WIKI_DIR" ]]; then
  gh repo clone benjaminschaal/wiki "$WIKI_DIR" 2>&1 | sed 's/^/  /'
fi

cd "$WIKI_DIR"

# Crée le dossier Notes 📝/Veille/ s'il n'existe pas
VEILLE_DIR="Notes 📝/Veille"
if [[ ! -d "$VEILLE_DIR" ]]; then
  mkdir -p "$VEILLE_DIR"
  cat > "$VEILLE_DIR/.gitkeep" <<EOF
EOF

  cat > "$VEILLE_DIR/README.md" <<'VAULT_README'
# Veille

Dossier alimenté automatiquement par la routine Claude Code veille data & analytics.

## Convention

- 1 fichier par jour : `{YYYY-MM-DD}-veille.md`
- Format : frontmatter YAML + Top 5 + reste + signaux faibles
- Tags hiérarchiques Obsidian : `#veille/analytics`, `#stack/{composant}`, `#impact/{type}`, `#tier/{1-3}`

## Workflow

1. La routine push une PR `claude/veille-{date}` chaque matin
2. Tu review la PR, merge si OK
3. La note arrive dans ton vault au prochain pull Obsidian
4. Tu tag avec `#kept` les notes que tu gardes en référence

## Calibration

Si la qualité de la veille dérive, édite `sources.yaml` ou `.claude/skills/ai-watch-rules/SKILL.md` dans [`benjaminschaal/veille`](https://github.com/benjaminschaal/veille).
VAULT_README

  git add "$VEILLE_DIR"
  if git diff --cached --quiet; then
    echo "  Rien à commit (déjà à jour)"
  else
    git commit -m "veille: init dossier 'Notes 📝/Veille/' pour routine veille data & analytics"
    git push origin main
    echo -e "${GREEN}  ✅ Commit + push sur wiki/main${NC}"
  fi
else
  echo "  Dossier Notes 📝/Veille/ existe déjà, skip"
fi

cd - > /dev/null
echo -e "${GREEN}✅ wiki prêt${NC}"
echo ""

# --- Étape 6 : Récap final ---
echo -e "${YELLOW}[6/6]${NC} Récap..."
echo ""
echo -e "${GREEN}✅ Bootstrap terminé.${NC}"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Étapes manuelles restantes (5 min)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "  ${YELLOW}1.${NC} Active 'Claude Code on the web' :"
echo "     → https://claude.ai/settings/profile"
echo ""
echo "  ${YELLOW}2.${NC} Vérifie/active les connectors :"
echo "     → https://claude.ai/settings/connectors"
echo "     → GitHub avec accès aux 2 repos (benjaminschaal/veille + benjaminschaal/wiki)"
echo "     → Web Search (par défaut)"
echo "     → Gmail (optionnel, pour newsletters)"
echo ""
echo "  ${YELLOW}3.${NC} Crée la routine sur :"
echo "     → https://claude.ai/code/routines"
echo "     → New routine → Cloud"
echo "     → Name: veille-data-analytics"
echo "     → Repository: benjaminschaal/veille"
echo "     → Branch: main"
echo "     → Model: Claude Sonnet 4.6"
echo "     → Schedule: 30 6 * * * (Europe/Paris)"
echo "     → Prompt: copier-coller le contenu de prompt.md"
echo ""
echo "  ${YELLOW}4.${NC} Ajoute les secrets de la routine :"
echo "     → NTFY_TOPIC = {votre topic ntfy, ex: veille-data}"
echo "     → NOTIFY_EMAIL = {votre email pour notifications}"
echo ""
echo "  ${YELLOW}5.${NC} Lance un Run now manuel pour valider"
echo "     puis active le schedule."
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "Documentation complète : ${BLUE}SETUP.md${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
