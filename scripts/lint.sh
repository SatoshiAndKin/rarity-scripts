#!/bin/sh -eux
# Development helper function to lint all the smart contracts and python code

solhint  --fix contracts/**.sol

# TODO: run pip-compile if setup.cfg or requirements-dev.in have changed

black --line-length 120 rarity/ scripts/ tests/

# TODO: isort
