# Brownie scripts for Rarity

<https://rarity.game/>

<https://github.com/andrecronje/rarity/tree/main/core>

<https://andrecronje.medium.com/rarity-composable-nft-architecture-5a76cbc85d58>

## Installation

Run the following in your terminal:

    python3 -m venv
    sourve venv/bin/activate
    pip install -U pip setuptools wheel
    pip install -r requirements.in -e .

## Usage

Run the following in your terminal:

    ./scripts/rarity.sh /help

NOTE: brownie flags start with "--". rarity command flags start with "/"

### Setup your account

    ./scripts/rarity.sh accounts from_mnemonic

### Create your first summoner

    ./scripts/rarity.sh /account YOUR_ACCOUNT player summon

### Interactive console

    ./scripts/rarity.sh /account YOUR_ACCOUNT console

### Create or Join a Guild

    ./scripts/rarity.sh /account YOUR_ACCOUNT guild /help

### Create an NPC Town for your Guild

...

### Enroll your summoner in your Guild

...

### Adventure with your Guild

...

### Create a Dungeon

    ./scripts/rarity.sh /account YOUR_ACCOUNT dungeon /help

### Enter the Dungeon

...
