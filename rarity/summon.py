import random
from rarity.ability_scores import AbilityScores

import brownie
import click
from click_spinner import spinner

from rarity.contracts import RARITY, RARITY_ATTRIBUTES, RARITY_SKILLS
from rarity.ability_scores import get_good_random_scores


def summon(click_ctx):
    # this will prompt the user to load their account
    # if they type their passphrase wrong, best to quit now then after they've chosen stats
    account_address = brownie.accounts.default.address

    print("Classes...")
    with spinner():
        class_ids = list(range(1, 12))
        with brownie.multicall:
            class_names = [RARITY.classes(i) for i in class_ids]

    # pick a class
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

    # pick ability scores
    ability_scores = None
    if click.confirm("Set ability scores?", default=True):
        if click.confirm("Get good randomized ability scores?", default=True):
            while True:
                ability_scores = get_good_random_scores(class_id)

                print(ability_scores)

                if click.confirm("Use these scores?", default=True):
                    break
        else:
            score_type = click.IntRange(8, 22)

            while True:
                strength = click.prompt("STR", type=score_type)
                dexterity = click.prompt("DEX", type=score_type)
                constitution = click.prompt("CON", type=score_type)
                intelligence = click.prompt("INT", type=score_type)
                wisdom = click.prompt("WIS", type=score_type)
                charisma = click.prompt("CHA", type=score_type)

                print("Calculating...")
                with spinner():
                    points_spent = RARITY_ATTRIBUTES.calculate_point_buy(
                        strength, dexterity, constitution, intelligence, wisdom, charisma
                    )

                if points_spent == 32:
                    break
                if points_spent < 32:
                    if click.confirm(f"You only spent {points_spent}/32 points. Are you sure?", default=False):
                        break
                else:
                    # points_spent >32
                    print(f"You spent {points_spent}/32 points. That isn't valid")

                print("Try again...")

            ability_scores = AbilityScores(strength, dexterity, constitution, intelligence, wisdom, charisma)

    # pick skills?
    skills = [0] * 36
    if click.confirm("Set skills?", default=True):
        print(click.style("Sorry! Setting skills is not yet supported. You'll have to use the console to do that.", fg="yellow"))

    # print pending summoner stats
    print("\n")
    print("*" * 80, "\n")
    print("Class:", click.style(str(class_names[class_id - 1]), fg="green"))
    if ability_scores:
        print()
        print(click.style(ability_scores, fg="green"))
    if sum(skills):
        print()
        print("Skills:")
        print(click.style(skills, fg="green"))

    click.confirm(
        click.style(
            "\nAre you sure you want to create this summoner? FTM will be spent!",
            bold=True,
            fg="yellow",
        ),
        abort=True,
        default=False,
    )

    summon_tx = RARITY.summon(class_id)

    summon_tx.info()

    summoner = summon_tx.events["summoned"]["summoner"]

    # save the summoner id in the context
    # TODO: think about this more. save it somewhere persistent
    if "summoners" not in click_ctx.obj:
        click_ctx.obj["summoners"] = set()
    click_ctx.obj["summoners"].add(summoner)

    if ability_scores:
        RARITY_ATTRIBUTES.point_buy(
            summoner,
            ability_scores.STR,
            ability_scores.DEX,
            ability_scores.CON,
            ability_scores.INT,
            ability_scores.WIS,
            ability_scores.CHA,
        ).info()

    if sum(skills):
        RARITY_SKILLS.set_skills(summoner, skills).info()

    print(f"{account_address} has summoned #{summoner:_}")