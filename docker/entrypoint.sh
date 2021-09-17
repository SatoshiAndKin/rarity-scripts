#!/bin/bash
set -o errexit

case "$1" in
    sh|bash)
        set -- "$@"
    ;;
    *)
        set -- /rarity-brownie/scripts/rarity.sh "$@"
    ;;
esac

exec "$@"
