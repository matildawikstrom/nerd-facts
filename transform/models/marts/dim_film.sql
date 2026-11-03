with films as (
    select * from {{ ref('stg_swapi__films') }}
)

select
    film_id,
    title,
    episode_id,
    opening_crawl,
    director,
    producers,
    release_date
from films