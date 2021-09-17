# Brownie scripts for Rarity

<https://rarity.game/>

<https://github.com/andrecronje/rarity/tree/main/core>

<https://andrecronje.medium.com/rarity-composable-nft-architecture-5a76cbc85d58>

## Installation

Install [Docker for Desktop](https://www.docker.com/products/docker-desktop).

Run the following in your terminal:

    docker pull bwstitt/rarity

    docker run --entrypoint "" -v "$HOME/bin/:/host/" bwstitt/rarity cp ./scripts/docker-rarity.sh /host/play-rarity.sh


## Usage

Run the following in your terminal:

    ~/bin/play-rarity.sh /help

NOTE: brownie's flags start with "--". rarity's flags start with "/"

### Setup your account

    ~/bin/play-rarity.sh accounts from_mnemonic

### Create your first summoner

    ~/bin/play-rarity.sh /account YOUR_ACCOUNT player summon

### Interactive console

    ~/bin/play-rarity.sh /account YOUR_ACCOUNT console

### Create or Join a Guild

    ~/bin/play-rarity.sh /account YOUR_ACCOUNT guild /help

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
