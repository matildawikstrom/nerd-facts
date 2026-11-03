with planets as (
    select * from {{ ref('stg_swapi__planets') }}
)

select
    planet_id,
    name as planet_name,
    rotation_period_hours,
    orbital_period_days,
    diameter_km,
    climates,
    gravity_standard_g,
    terrains,
    surface_water_percentage,
    population
from planets
where name is not null