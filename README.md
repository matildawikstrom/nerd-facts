# Nerd Facts

Greta, the company's Nerd Facts expert, is retiring. This project replaces her Star Wars
knowledge with a small data pipeline: it downloads data from [swapi.dev](https://swapi.dev),
models it with dbt in DuckDB, and shows fun facts for the board in a Streamlit page.

The goal is a small, complete pipeline that is easy to run and to discuss, not an exhaustive one.

## Quick start

**Prerequisites:** [uv](https://docs.astral.sh/uv/getting-started/installation/) and git.
uv installs the right Python version (3.14) and all packages itself.

Run from the repo root:

```
uv sync                                   # install Python and the packages
uv run python ingestion/load_swapi.py     # optional: refresh the raw data from swapi.dev
cd transform
uv run dbt build                          # build and test all models
cd ..
uv run streamlit run reports/app.py       # open the fun facts page in the browser
```

The raw data is committed as a snapshot in `data/raw/swapi/`, so the loader step can be
skipped, for example if swapi.dev is down.

To browse the models, columns and lineage graph:

```
cd transform
uv run dbt docs generate
uv run dbt docs serve
```

## Troubleshooting

**"File is being used by another process":** DuckDB allows only one process to write to the
database file. Close other tools that have `data/nerd_facts.duckdb` open, such as a database
viewer in your IDE, and run `dbt build` again.

## Architecture

The pipeline follows ELT: Python extracts and loads, dbt transforms.

```
swapi.dev API
    │  ingestion/load_swapi.py
    ▼
data/raw/swapi/*.json            raw API responses            (bronze)
    │  dbt sources (read directly from the files)
    ▼
staging: stg_swapi__*            cleaned, typed, renamed      (silver)
    │  dbt ref()
    ▼
marts: dim_* and fct_*           star schema for analysis     (gold)
    │
    ▼
reports/app.py                   Streamlit fun facts page
```

| folder | contents |
|---|---|
| `ingestion/` | Python loader: fetches every page of each endpoint and writes one JSON file per endpoint |
| `transform/` | dbt project `nerd_facts`: sources, staging and marts models, macros and tests |
| `reports/` | Streamlit app that reads the marts |
| `data/` | raw JSON, committed as a snapshot, and the DuckDB file, which is git-ignored because `dbt build` rebuilds it |

## Data model

A star schema with four dimensions and two fact tables:

| model | one row per | notes |
|---|---|---|
| `dim_character` | character | `homeworld_id` links to `dim_planet` |
| `dim_film` | film | `film_id` is the API's id, not the episode number |
| `dim_planet` | planet | includes an `Unknown` member and `population_per_km2`, calculated in dbt |
| `dim_starship` | starship | |
| `fct_character_film_appearance` | character in a film | factless fact table |
| `fct_starship_film_appearance` | starship in a film | factless fact table |

The fact tables only hold keys: they record that something happened, and the measure is a
count of rows. Names, titles and other attributes come from joining the dimensions.

## Data quality

`dbt build` runs every test before the models that depend on it, so bad data stops the build.

- **Keys:** `unique` and `not_null` on every primary key, `relationships` from every foreign
  key to its dimension, and a custom `unique_pair` test for the fact tables' composite keys.
- **Values:** `accepted_values` on gender, plausible ranges for height, mass and surface water,
  and a reusable `non_negative` test for costs, passengers, hyperdrive rating and density.
- **Source types:** every column of every source is declared with the type the API documents,
  so a change in the API fails loudly when the data is read.

## Known limitations

- swapi.dev covers only the first six films, so facts such as how many films a character
  appears in stop at *Return of the Jedi*.
- Only part of swapi.dev is modelled: people, films, planets and starships. Species and
  vehicles are downloaded but not modelled, and starship pilots are not used.
- The committed raw data is a snapshot. Refreshing it needs swapi.dev to be online.

## Next steps

Ranked by value for the business:

1. **Scheduling and CI:** run the loader and `dbt build` on a schedule, and run `dbt build` on
   every pull request, for example with GitHub Actions. This turns the project into a service
   instead of something someone has to remember to run.
2. **Complete the swapi.dev model:** add species, vehicles and pilots with the same pattern.
   No loader change is needed.
3. **More sources:** add the other APIs from the brief with a loader and staging models per
   API. Shared concepts, such as a character, become conformed dimensions that all sources use.
4. **Serving more users:** publish the page, define metrics in a semantic layer, and add model
   contracts so other teams can rely on the marts.
