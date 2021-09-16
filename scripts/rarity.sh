#!/bin/bash

cd "$(dirname "$0")/.."

exec venv/bin/brownie run rarity main "$@"
