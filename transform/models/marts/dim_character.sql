with people as (
    select * from {{ ref('stg_swapi__people') }}
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
    people.homeworld_id
from people