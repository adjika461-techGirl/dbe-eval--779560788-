#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage : bash scripts/analyse.sh <fichier.log> [--top N]" >&2
    exit 1
}

verifier_arguments() {
    if [[ $# -ne 1 && $# -ne 3 ]]; then usage; fi
    FICHIER=$1
    TOP=3
    if [[ $# -eq 3 ]]; then
        [[ $2 == "--top" && $3 =~ ^[1-9][0-9]*$ ]] || usage
        TOP=$3
    fi
    if [[ -z "${MATRICULE:-}" ]]; then
        echo "Erreur : la variable MATRICULE n'est pas définie." >&2
        exit 1
    fi
    if [[ ! -f $FICHIER ]]; then
        echo "Erreur : fichier introuvable : $FICHIER" >&2
        exit 2
    fi
    if [[ ! -s $FICHIER ]]; then
        echo "Erreur : fichier vide : $FICHIER" >&2
        exit 3
    fi
}

entete() {
    echo "===== Rapport d'analyse ====="
    echo "Date       : $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Session    : $(whoami)@$(hostname)"
    echo "Matricule  : $MATRICULE"
    echo "Fichier    : $FICHIER"
    echo "SHA-256    : $(sha256sum "$FICHIER" | awk '{print $1}')"
    echo
}

familles() {
    echo "--- Requêtes par famille de codes ---"
    local f n
    for f in 2 3 4 5; do
        n=$(awk -v f="$f" '$9 ~ "^" f {c++} END {print c+0}' "$FICHIER")
        echo "${f}xx : $n"
    done
    echo
}

top_endpoints() {
    echo "--- Top $TOP des endpoints ---"
    awk '{split($7, a, "?"); c[a[1]]++} END {for (k in c) print c[k], k}' "$FICHIER" \
        | sort -rn | awk -v n="$TOP" 'NR <= n'
    echo
}

ip_suspecte() {
    echo "--- IP suspecte (échecs 401 sur /api/auth/login) ---"
    awk '$7 == "/api/auth/login" && $9 == 401 {c[$1]++}
         END {
             for (i in c) if (c[i] > m) {m = c[i]; ip = i}
             if (m) print ip " (" m " échecs)"; else print "aucune"
         }' "$FICHIER"
    echo
}

temps_moyen() {
    echo "--- Temps de réponse moyen (code 200) ---"
    awk '$9 == 200 {s += $11; n++}
         END {if (n) printf "%.1f\n", s / n; else print "aucune requête 200"}' "$FICHIER"
}

main() {
    verifier_arguments "$@"
    mkdir -p rapports
    local rapport="rapports/rapport_${MATRICULE}_$(date +%Y%m%d_%H%M).txt"
    {
        entete
        familles
        top_endpoints
        ip_suspecte
        temps_moyen
    } > "$rapport"
    echo "Rapport écrit dans $rapport"
}

main "$@"
