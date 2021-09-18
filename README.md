# Scripts for Playing Rarity

<https://andrecronje.medium.com/rarity-composable-nft-architecture-5a76cbc85d58>

<https://rarity.game/>

<https://github.com/andrecronje/rarity/tree/main/core>

<https://eth-brownie.readthedocs.io/>

## Installation

Install [Docker for Desktop](https://www.docker.com/products/docker-desktop).

Copy and paste the following into your terminal:

    docker run --pull always -v "$HOME/bin/:/host/" bwstitt/rarity:latest bash -c "cp /rarity-scripts/scripts/play-rarity.sh /host/ && echo Successfully installed to \~/bin/play-rarity.sh"

To upgrade, run the above command again.

## Usage

Run the following in your terminal:

    ~/bin/play-rarity.sh /help

You can add "/help" to the end of any command to see more information.

Most of the commands are still under construction.

NOTE: Brownie's flags (like "--help") start with "--". Rarity's flags start with "/". This is so the scripts can easily tell flags apart.

### Setup Your Account

    ~/bin/play-rarity.sh accounts from_mnemonic

Follow the prompts to setup your account. The account's key will be encrypted with a passphrase of your choosing.

Replace "$ACCOUNT" in any other command with the account name that you chose.

### Get Some FTM

In order to send any transactions, your account will need some [FTM](https://fantom.foundation/) on the Fantom chain.

Depending on your situation and current prices, one of these choices will probably be best:

1) Trade your tokens for FTM on any chain. Then bridge your FTM to Fantom.
2) Bridge your tokens to Fantom. Then trade your tokens for FTM on Fantom.

Exchanges:

- <https://paraswap.io/#/?network=ethereum>
- <https://app.sushi.com/swap>
- <https://spookyswap.finance/>

Bridges:

- <https://multichain.xyz/>
- <https://docs.spookyswap.finance/links/bridge-to-fantom-opera>

### Create a Summoner

    ~/bin/play-rarity.sh /account "$ACCOUNT" player summon

Follow the prompts to build a summoner.

### Send your Summoners on Adventures

**UNDER CONSTRUCTION!**

    ~/bin/play-rarity.sh /account "$ACCOUNT" player adventure

### Interactive Console

    ~/bin/play-rarity.sh /account "$ACCOUNT" console

This opens an [Ipython](https://ipython.org/) console with a bunch of helpful things already imported. Run `dir()` to see them all.

### Create a Guild

**UNDER CONSTRUCTION!**

    ~/bin/play-rarity.sh /account "$ACCOUNT" guild create

Follow the prompts to create a guild.

At the end, you will be given an address. Save this address! Replace "$GUILD_ADDR" in any later command with this address.

### Create a summoner for your Guild

**UNDER CONSTRUCTION!**

    ~/bin/play-rarity.sh /account "$ACCOUNT" guild summon "$GUILD_ADDR"

Follow the prompts to build a summoner.

### Invite Someone to your Guild

**UNDER CONSTRUCTION!**

    ~/bin/play-rarity.sh /account "$ACCOUNT" guild invite "$GUILD_ADDR"

Be **VERY** careful with who you invite! Any member can take everything from the guild!

More advanced security is planned.

### Create an NPC Town for Your Guild

**UNDER CONSTRUCTION!**

    ~/bin/play-rarity.sh /account "$ACCOUNT" npc create_town "$GUILD_ADDR"

Follow the prompts to create a town full of multiple NPCs. Only the guild can interact with the town.

Towns that are open for any player to interact with are planned.

### Enroll Your Summoner in Your Guild

**UNDER CONSTRUCTION!**

    ~/bin/play-rarity.sh /account "$ACCOUNT" guild enroll_summoner "$GUILD_ADDR" "$SUMMONER_ID"

Allow your guildmates to control your summoner. You will retain ownership of the summoner, but the guild can take it.

### Summon for Your Guild

**UNDER CONSTRUCTION!**

    ~/bin/play-rarity.sh /account "$ACCOUNT" guild summon "$GUILD_ADDR"

Follow the prompts to craete a summoner for your guild.

### Give a summoner to Your Guild

**UNDER CONSTRUCTION!**

    ~/bin/play-rarity.sh /account "$ACCOUNT" guild give_summoner "$GUILD_ADDR" "$SUMMONER_ID"

Give a summoner that you control to your guild.

### Remove a summoner from your Guild

**UNDER CONSTRUCTION!**

    ~/bin/play-rarity.sh /account "$ACCOUNT" guild remove_summoner "$GUILD_ADDR" "$SUMMONER_ID" "$DESTINATION_ADDR"

Please don't steal from your guildmates!

DESTINATION_ADDR can be your account or any other account. If not specified, it will default to your account. Be careful with this! Summoners could be lost!

### Adventure with your Guild

**UNDER CONSTRUCTION!**

    ~/bin/play-rarity.sh /account "$ACCOUNT" guild adventure "$GUILD_ADDR"

Depending on the size of your guild, you may need to call this multiple times per day.

### Send your Guild's NPCs to work

**UNDER CONSTRUCTION!**

    ~/bin/play-rarity.sh /account "$ACCOUNT" guild work_npcs "$GUILD_ADDR"

This function can be called as many times per day as you are willing to pay for.

### Create a Dungeon

**UNDER CONSTRUCTION!**

    ./scripts/rarity.sh /account "$ACCOUNT" dungeon /help

Create an interactive dungeon for summoners to adventure inside.

At the end, you will be given an address. Replace "$DUNGEON_ADDR" in the later example commands with this address.

### Adventure in the Dungeon

**UNDER CONSTRUCTION!**

First, scout the dungeon:

    ~/bin/play-rarity.sh /account "$ACCOUNT" dungeon scout "$DUNGEON_ADDR" "$SUMMONER_ID"

If you think you will survive, enter the dungeon:

    ~/bin/play-rarity.sh /account "$ACCOUNT" dungeon adventure "$DUNGEON_ADDR" "$SUMMONER_ID"

Then, repeat these until your summoner has returned:

    ~/bin/play-rarity.sh /account "$ACCOUNT" dungeon choose "$DUNGEON_ADDR" "$SUMMONER_ID"

### Advanced: Open a bash shell

If you want to explore the docker container, open a shell:

    ~/bin/play-rarity.sh bash
