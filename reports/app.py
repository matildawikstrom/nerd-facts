"""Nerd Facts: Star Wars fun facts for the board, read from the dbt marts.

Run from the repo root, after the pipeline has been built:
    uv run streamlit run reports/app.py
"""

from pathlib import Path

import duckdb
import streamlit as st

DB_PATH = Path(__file__).resolve().parents[1] / "data" / "nerd_facts.duckdb"


def query(sql):
    # Open and close the connection per query, so the app doesn't block `dbt build`
    with duckdb.connect(str(DB_PATH), read_only=True) as con:
        return con.sql(sql).df()


st.set_page_config(page_title="Nerd Facts", page_icon="🌌")

st.title("Nerd Facts")
st.write("What Greta would tell you about Star Wars, now answered from data.")
st.write("Source: swapi.dev.")


# Fun fact 1: The most expensive starships
# The Death Star's price is shown as a number,
# because on a chart it would make every other ship's bar invisible.
st.header("The Death Star is in a price class of its own")

ships_by_cost = query("""
    select 
        starship_name, 
        cost_in_credits
    from dim_starship
    where cost_in_credits is not null
    order by cost_in_credits desc
""")
total_ships = query("select count(*) as ships from dim_starship").ships[0]

most_expensive = ships_by_cost.iloc[0]
runner_up = ships_by_cost.iloc[1]
times_more = most_expensive.cost_in_credits / runner_up.cost_in_credits

left, right = st.columns(2)
left.metric(f"Cost of the {most_expensive.starship_name}", f"{most_expensive.cost_in_credits / 1e12:,.0f} trillion credits")
right.metric(f"Compared with the {runner_up.starship_name}", f"{times_more:,.0f} times more")

st.subheader("The next most expensive ships")
next_ships = ships_by_cost.iloc[1:6].assign(cost_in_million_credits=lambda ships: ships.cost_in_credits / 1e6)
st.bar_chart(
    next_ships,
    x="starship_name",
    y="cost_in_million_credits",
    x_label="Cost in million credits",
    y_label="",
    horizontal=True,
    sort="-cost_in_million_credits",
)
st.caption(f"Cost is known for {len(ships_by_cost)} of {total_ships} starships.")


# Fun fact 2: Fastest starship per film
st.header("The fastest starship in every film")

fastest = query("""
    select
        film.episode_id,
        film.title,
        ship.starship_name,
        ship.hyperdrive_rating
    from fct_starship_film_appearance as appearance
    join dim_starship as ship 
         on appearance.starship_id = ship.starship_id
    join dim_film as film 
         on appearance.film_id = film.film_id
    where ship.hyperdrive_rating is not null
    qualify rank() over (partition by film.film_id order by ship.hyperdrive_rating) = 1
    order by film.episode_id
""")

st.dataframe(
    fastest,
    hide_index=True,
    column_config={
        "episode_id": st.column_config.NumberColumn("Episode"),
        "title": "Film",
        "starship_name": "Fastest starship",
        "hyperdrive_rating": st.column_config.NumberColumn("Hyperdrive rating", format="%.1f"),
    },
)
st.caption("Measured by hyperdrive rating: lower is faster.")


# Fun fact 3: Characters at the extremes, shown as big numbers
st.header("Characters at the extremes")


def extreme(column, direction):
    # The character with the highest or lowest known value; ties are broken by name
    return query(f"""
        select
            character_name,
            {column} as value
        from dim_character
        where {column} is not null
        order by {column} {direction}, character_name
        limit 1
    """).iloc[0]


tallest = extreme("height_cm", "desc")
shortest = extreme("height_cm", "asc")
heaviest = extreme("mass_kg", "desc")
oldest = extreme("birth_year_bby", "desc")

top_left, top_right = st.columns(2)
top_left.metric(f"Tallest: {tallest.character_name}", f"{tallest.value:,.0f} cm")
top_right.metric(f"Shortest: {shortest.character_name}", f"{shortest.value:,.0f} cm")
bottom_left, bottom_right = st.columns(2)
bottom_left.metric(f"Heaviest: {heaviest.character_name}", f"{heaviest.value:,.0f} kg")
bottom_right.metric(f"Oldest: {oldest.character_name}", f"Born {oldest.value:,.0f} BBY")
st.caption(
    "BBY = years before the Battle of Yavin (the end of A New Hope). "
    "Only characters with a known value are compared."
)


# Fun fact 4: Population density per planet.
# Top planet is shown as a number,
# because on a chart it would make the other bars tiny.
st.header("Coruscant is the most crowded planet")

# Earth isn't in the data but a fun reference point: about 8 billion people, 12,742 km in diameter, same formula
EARTH_PEOPLE_PER_KM2 = 16

planets_by_density = query("""
    select 
        planet_name, 
        population_per_km2
    from dim_planet
    where population_per_km2 is not null
    order by population_per_km2 desc
""")
# 'Unknown' is the unknown member, not a real planet
total_planets = query("select count(*) as planets from dim_planet where planet_name <> 'Unknown'").planets[0]
most_crowded = planets_by_density.iloc[0]

left, right = st.columns(2)
left.metric(f"People per km² on {most_crowded.planet_name}", f"{most_crowded.population_per_km2:,.0f}")
right.metric("People per km² Earth", f"{EARTH_PEOPLE_PER_KM2}")

st.subheader("The next most crowded planets")
st.bar_chart(
    planets_by_density.iloc[1:6],
    x="planet_name",
    y="population_per_km2",
    x_label="People per km²",
    y_label="",
    horizontal=True,
    sort="-population_per_km2",
)
st.caption(
    f"Population divided by total surface area, land and water, treating each planet as a sphere. "
    f"Known for {len(planets_by_density)} of {total_planets} planets. "
    f"Earth's figure ({EARTH_PEOPLE_PER_KM2} people per km²) comes from outside this data."
)
