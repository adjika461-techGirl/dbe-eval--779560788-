#!/usr/bin/env bash

LOG="logs/surveillance.log"
JOURNAL="logs/access.log"

mkdir -p logs

arret() {
    echo "arrêt propre" >> "$LOG"
    exit 0
}

trap arret SIGTERM

while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') $(wc -l < "$JOURNAL") lignes" >> "$LOG"
    sleep 5 &
    wait $!
done
