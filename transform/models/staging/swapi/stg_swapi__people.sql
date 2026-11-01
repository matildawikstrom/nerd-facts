with source as (
    select
        *
    from {{ source('swapi', 'people') }}
),

renamed as (
    select
        name,
        case
            when height = 'unknown' then null
            else cast(height as integer)
        end as height_cm,
        case
            when mass = 'unknown' then null
            else cast(replace(mass, ',', '') as double)
        end as mass_kg,
        case
            when hair_color in ('n/a', 'none') then 'none'
            when hair_color = 'unknown' then null
            when hair_color in ('blond', 'blonde') then 'blond'
            else hair_color
        end as hair_color,
        case
            when skin_color in ('n/a', 'none') then 'none'
            when skin_color = 'unknown' then null
            else skin_color
        end as skin_color,
        case
            when eye_color in ('n/a', 'none') then 'none'
            when eye_color = 'unknown' then null
            else eye_color
        end as eye_color,
        case
            when birth_year = 'unknown' then null
            else birth_year
        end as birth_year,
        case
            when birth_year = 'unknown' then null
            else cast(replace(birth_year, 'BBY', '') as double)
        end as birth_year_bby,
        case
            when gender in ('n/a', 'none') then 'none'
            when gender = 'unknown' then null
            else gender
        end as gender,
        homeworld as homeworld_url,
        films as film_urls,
        species as species_urls,
        vehicles as vehicle_urls,
        starships as starship_urls,
        created as api_created_at,
        edited as api_edited_at,
        url as person_url,
        _loaded_at
    from source
)

select * from renamed