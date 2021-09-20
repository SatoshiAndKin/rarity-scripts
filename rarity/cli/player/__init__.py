import click
from click_spinner import spinner

from rarity.cli import rarity_cli


@rarity_cli.group()
def player():
    """Manage player characters."""


@player.command()
@click.pass_context
def adventure(ctx):
    """Send all your player characters on adventures."""
    from rarity.adventure import adventure

    ctx.obj["setup_gas_strat"]()

    # TODO: make leveling optional
    adventure(True)


@player.command()
@click.pass_context
def idle_adventure(ctx):
    """Automatically send all your player characters on adventures."""
    from rarity.adventure import adventure
    import time

    ctx.obj["setup_gas_strat"]()

    while True:
        try:
            # TODO: make leveling optional
            next_run = adventure(with_level_up=True)

            with spinner(beep=True):
                time.sleep(next_run)
        except Exception as exc:
            click.secho(f"Caught exception! {exc}", fg="red")
            time.sleep(10)


@player.command()
@click.pass_context
def summon(ctx):
    """Summon a new player character."""
    from rarity.summoner import summon

    ctx.obj["setup_gas_strat"]()

    summon(ctx)
