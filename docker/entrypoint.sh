#!/bin/bash
set -o errexit

case "$1" in
    sh|bash)
        set -- "$@"
    ;;
    *)
        set -- /rarity-scripts/scripts/rarity.sh "$@"
    ;;
esac

exec "$@"
