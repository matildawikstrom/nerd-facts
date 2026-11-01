-- Masses outside a plausible range point to a cleaning bug (e.g. the decimal comma in '1,358')
select
    person_id,
    name,
    mass_kg
from {{ ref('stg_swapi__people') }}
where mass_kg < 10 or mass_kg > 2000