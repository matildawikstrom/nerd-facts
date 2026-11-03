with starships as (
    select * from {{ ref('stg_swapi__starships') }}
)

select
    starship_id,
    name as starship_name,
    model as starship_model,
    manufacturer as starship_manufacturer,
    cost_in_credits,
    length_m,
    max_atmosphering_speed,
    max_atmosphering_speed_value,
    crew,
    crew_min,
    passengers,
    cargo_capacity_kg,
    consumables,
    hyperdrive_rating,
    mglt,
    starship_class
from starships
