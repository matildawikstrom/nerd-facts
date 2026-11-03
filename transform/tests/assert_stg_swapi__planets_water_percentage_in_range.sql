-- Water percentage outside valid range.
select
    planet_id,
    name,
    surface_water_percentage
from {{ ref('stg_swapi__planets') }}
where surface_water_percentage < 0.0 or surface_water_percentage > 100.0