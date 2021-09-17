#!/bin/bash
set -ex

# TODO: only pull if we haven't pulled in the last 24 hours

exec docker run \
    --rm -it \
    -v "$HOME/.brownie-rarity/:/root/" \
    bwstitt/rarity \
    "$@" \
;
