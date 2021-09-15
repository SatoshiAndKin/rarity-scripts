#!/bin/sh -eux

solhint  --fix contracts/**.sol

black --line-length 120 rarity/ scripts/ tests/
