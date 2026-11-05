with starships as (
    select * from {{ ref('stg_swapi__starships') }}
)

select
    starship_id,
    unnest(film_ids) as film_id
from starships
