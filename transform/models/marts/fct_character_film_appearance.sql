with people as (
    select * from {{ ref('stg_swapi__people') }}
)

select
    person_id as character_id,
    unnest(film_ids) as film_id
from people
