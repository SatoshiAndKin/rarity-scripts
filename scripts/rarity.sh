#!/bin/bash

cd "$(dirname "$0")/.."

exec brownie run rarity main "$@"
