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
    population,
    -- Treats the planet as a sphere: surface area = pi * diameter^2
    pi() * diameter_km * diameter_km as surface_area_km2,
    population / (pi() * diameter_km * diameter_km) as population_per_km2
from planets
where name is not null