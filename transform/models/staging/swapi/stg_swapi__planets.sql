with source as (
    select
        *
    from {{ source('swapi', 'planets') }}
),

renamed as (
    select
        name,
        rotation_period,
        orbital_period,
        diameter,
        climate,
        gravity,
        terrain,
        surface_water,
        population,
        residents,
        films,
        created,
        edited,
        url,
        _loaded_at
    from source
)

select * from renamed