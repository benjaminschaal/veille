#!/usr/bin/env bash
# ntfy-notify.sh
# Envoie une notification ntfy avec un résumé de la veille du jour.
#
# Usage: bash scripts/ntfy-notify.sh "<résumé en français>"
#
# Variables d'env attendues:
#   NTFY_TOPIC        — topic ntfy (défaut: veille-data-benjamin)
#   NTFY_PRIORITY     — priorité 1-5 (défaut: 3)
#   NTFY_SERVER       — serveur ntfy (défaut: https://ntfy.sh)
#   NOTIFY_EMAIL      — email destinataire (défaut: benjamin.schaal@free.fr)
#   GITHUB_PR_URL     — URL de la PR créée (optionnel, ajouté au message)

set -euo pipefail

NTFY_TOPIC="${NTFY_TOPIC:-veille-data-benjamin}"
NTFY_PRIORITY="${NTFY_PRIORITY:-3}"
NTFY_SERVER="${NTFY_SERVER:-https://ntfy.sh}"
NOTIFY_EMAIL="${NOTIFY_EMAIL:-benjamin.schaal@free.fr}"
TODAY_FR="$(LC_TIME=fr_FR.UTF-8 date +'%A %d %B %Y' 2>/dev/null || date +'%Y-%m-%d')"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <résumé FR>" >&2
  exit 1
fi

SUMMARY="$1"
TITLE="📊 Veille Data & Analytics — ${TODAY_FR}"
MESSAGE="${SUMMARY}"

if [[ -n "${GITHUB_PR_URL:-}" ]]; then
  MESSAGE="${MESSAGE}

🔗 PR : ${GITHUB_PR_URL}"
fi

HTTP_CODE=$(curl -sS -o /tmp/ntfy_response.txt -w '%{http_code}' \
  -X POST \
  -H "Title: ${TITLE}" \
  -H "Priority: ${NTFY_PRIORITY}" \
  -H "Tags: telescope,robot,memo" \
  -H "Email: ${NOTIFY_EMAIL}" \
  -H "Content-Type: text/plain; charset=utf-8" \
  --data-binary "${MESSAGE}" \
  "${NTFY_SERVER}/${NTFY_TOPIC}")

if [[ "${HTTP_CODE}" != "200" ]]; then
  echo "❌ ntfy push failed (HTTP ${HTTP_CODE})" >&2
  cat /tmp/ntfy_response.txt >&2
  exit 1
fi

echo "✅ ntfy push OK (topic: ${NTFY_TOPIC})"
