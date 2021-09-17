#!/bin/bash
set -o errexit

case "$1" in
    sh|bash)
        set -- "$@"
    ;;
    *)
        set -- ./scripts/rarity.sh "$@"
    ;;
esac

exec "$@"
