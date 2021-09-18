import random

import brownie
import click

from rarity.contracts import RARITY, RARITY_ATTRIBUTES, RARITY_SKILLS


def summon(click_ctx):
    account = brownie.accounts.default

    class_ids = list(range(1, 12))

    with brownie.multicall:
        class_names = [RARITY.classes(i) for i in class_ids]

    for i, name in zip(class_ids, class_names):
        print(str(i).rjust(3), "-", name)

    class_id = click.prompt(
        "\nWhat class?",
        default=random.choice(class_ids),
        type=click.Choice(class_ids),
        value_proc=int,
        show_choices=False,
        show_default=True,
    )

    # TODO: pick ability scores
    strength = None
    if click.confirm("Set ability scores?", default=True):
        if click.confirm("Set randomized ability scores?", default=True):
            raise NotImplementedError
        else:
            score_type = click.IntRange(8, 22)

            strength = click.prompt("STR", type=score_type)
            dexterity = click.prompt("DEX", type=score_type)
            constitution = click.prompt("CON", type=score_type)
            intelligence = click.prompt("INT", type=score_type)
            wisdom = click.prompt("WIS", type=score_type)
            charisma = click.prompt("CHA", type=score_type)

    # TODO: pick skills?
    skills = [0] * 36
    if click.confirm("Set skills?", default=True):
        raise NotImplementedError

    # print pending summoner stats
    print("Class:", class_names[class_id])
    if strength:
        print("STR:", strength)
        print("DEX:", dexterity)
        print("CON:", constitution)
        print("INT:", intelligence)
        print("WIS:", wisdom)
        print("CHA:", charisma)

    click.confirm("Are you sure?", abort=True, default=False)

    summon_tx = RARITY.summon(class_id)

    summon_tx.info()

    summoner = summon_tx.events["summoned"]["summoner"]

    # save the summoner id in the context
    # TODO: think about this more. save it somewhere persistent
    if "summoners" not in click_ctx.obj:
        click_ctx.obj["summoners"] = set()
    click_ctx.obj["summoners"].add(summoner)

    if strength:
        RARITY_ATTRIBUTES.point_buy(summoner, strength, dexterity, constitution, intelligence, wisdom, charisma).info()

    if sum(skills):
        RARITY_SKILLS.set_skills(summoner, skills).info()

    print(f"{account} has summoned #{summoner:_}")
