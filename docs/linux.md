mkdir -p docs logs
export MATRICULE=779560788
: > logs/vide.log

{
  echo "## L4 - Tests de scripts/analyse.sh"
  echo

  bash scripts/analyse.sh logs/access.log; rc=$?
  echo "- Cas correct : code de retour $rc (attendu 0)"

  bash scripts/analyse.sh; rc=$?
  echo "- Sans argument : code de retour $rc (attendu 1)"

  bash scripts/analyse.sh logs/absent.log; rc=$?
  echo "- Fichier absent : code de retour $rc (attendu 2)"

  bash scripts/analyse.sh logs/vide.log; rc=$?
  echo "- Fichier vide : code de retour $rc (attendu 3)"
} >> docs/linux.md 2>&1 || true
