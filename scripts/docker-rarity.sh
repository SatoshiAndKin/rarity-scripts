#!/bin/bash
# start a docker container 
set -eu

DOCKER_RARITY_TAG=${DOCKER_RARITY_TAG:-latest}

DOCKER_RARITY_HOME=${DOCKER_RARITY_HOME:-$HOME/.rarity-docker}

# pull if we haven't pulled in the last 24 hours
if [ "$DOCKER_RARITY_TAG" == "latest" ]; then
    next_pull=$DOCKER_RARITY_HOME/.next_pull
    now=$(date +%s)
    if [ -e "$next_pull" ] && [[ "$now" -lt "$(cat "$next_pull")" ]]; then
        # no need to pull
        ;
    else
        docker pull bwstitt/rarity:latest
        echo "$now + 86400" | bc > "$next_pull"

        # TODO: i'd like to copy the latest docker-rarity.sh, but copying it over top a running script won't work well
    fi
fi

exec docker run \
    --rm -it \
    -v "$DOCKER_RARITY_HOME/:/root/" \
    "bwstitt/rarity:$DOCKER_RARITY_TAG" \
    "$@" \
;
