-- Heights outside a plausible range.
select
    person_id,
    name,
    height_cm
from {{ ref('stg_swapi__people') }}
where height_cm < 30 or height_cm > 300