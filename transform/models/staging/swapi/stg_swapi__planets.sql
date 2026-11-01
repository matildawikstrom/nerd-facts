with source as (
    select
        *
    from {{ source('swapi', 'planets') }}
),

renamed as (
    select
        {{ swapi_id('url') }} as planet_id,
        nullif(name, 'unknown') as name,
        case
            when rotation_period  in ('unknown', '0') then null
            else cast(rotation_period as integer)
        end as rotation_period_hours,
        case
            when orbital_period  in ('unknown', '0') then null
            else cast(orbital_period as integer)
        end as orbital_period_days,
        case
            when diameter  in ('unknown', '0') then null
            else cast(diameter as integer)
        end as diameter_km,
        {{ swapi_text('climate') }} as climate,
        {{ swapi_split_list( swapi_text('climate') ) }} as climates_list,
        gravity,
        case
            when gravity in ('unknown', 'N/A') then null
            else cast( regexp_extract(gravity, '^[0-9.]+') as double)
        end as gravity_standard_g,
        {{ swapi_text('terrain') }} as terrain,
        {{ swapi_split_list( swapi_text('terrain') ) }} as terrains_list,
        case
            when surface_water = 'unknown' then null
            else cast(surface_water as double)
        end as surface_water_percentage,
        case
            when population = 'unknown' then null
            else cast(population as bigint)
        end as avg_population_sentinent,
        residents as resident_urls,
        list_transform(residents, lambda u: {{ swapi_id('u') }}) as resident_ids,
        films as film_urls,
        list_transform(films, lambda u: {{ swapi_id('u') }}) as film_ids,
        cast(created as timestamptz) as api_created_at,
        cast(edited as timestamptz) as api_edited_at,
        url as planet_url,
        cast(_loaded_at as timestamptz) as _loaded_at
    from source
)

select * from renamed