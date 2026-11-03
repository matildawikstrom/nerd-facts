with people as (
    select * from {{ ref('stg_swapi__people') }}
),

planets as (
    select planet_id from {{ ref('dim_planet') }}
)

select
    people.person_id as character_id,
    people.name as character_name,
    people.height_cm,
    people.mass_kg,
    people.hair_colors,
    people.skin_colors,
    people.eye_colors,
    people.birth_year_bby,
    people.gender,
    planets.planet_id as homeworld_id
from people
left join planets
    on people.homeworld_id = planets.planet_id