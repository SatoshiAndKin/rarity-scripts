#!/bin/bash
# start a docker container to play Rarity
set -eu

DOCKER_PULL=${DOCKER_PULL:-1}
RARITY_HOME=${RARITY_HOME:-$HOME/.rarity-docker}
RARITY_TAG=${RARITY_TAG:-latest}

# pull if we haven't pulled in the last 24 hours
if [ "$RARITY_TAG" == "latest" ] && [ "$DOCKER_PULL" == "1" ]; then
    mkdir -p "$RARITY_HOME"

    next_pull=$RARITY_HOME/.next_pull
    now=$(date +%s)
    if [ -e "$next_pull" ] && [[ "$now" -lt "$(cat "$next_pull")" ]]; then
        # already pulled inside the last 24 hours
        :
    else
        docker pull bwstitt/rarity:latest
        echo "$now + 86400" | bc > "$next_pull"

        # TODO: i'd like to copy the latest docker-rarity.sh, but copying it over top a running script won't work well
    fi
fi

build_dir="$RARITY_HOME/build/rarity-brownie"
if [ ! -d "$build_dir" ]; then
    mkdir -p "$build_dir"
fi

exec docker run \
    --rm -it \
    -v "$RARITY_HOME/:/root/" \
    "bwstitt/rarity:$RARITY_TAG" \
    "$@" \
;
