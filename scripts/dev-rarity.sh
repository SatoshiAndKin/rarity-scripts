#!/bin/bash
set -eux

cd "$(dirname "$0")/.."

export RARITY_TAG=dev

docker build . --progress plain -t "bwstitt/rarity:$RARITY_TAG"

./scripts/play-rarity.sh "$@"
