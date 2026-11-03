with source as (
    select
        *
    from {{ source('swapi', 'starships') }}
),

renamed as (
    select
        {{ swapi_id('url') }} as starship_id,
        name,
        model,
        manufacturer,
        case
            when cost_in_credits = 'unknown' then null
            else cast(cost_in_credits as bigint)
        end as cost_in_credits,
        cast(replace(length, ',', '') as double) as length_m,
        {{ swapi_text('max_atmosphering_speed') }} as max_atmosphering_speed,
        case
            when max_atmosphering_speed in ('unknown', 'n/a') then null
            else cast(regexp_extract(max_atmosphering_speed, '^[0-9]+') as integer)
        end as max_atmosphering_speed_value,
        case
            when crew = 'unknown' then null
            else replace(crew, ',', '')
        end as crew,
        case
            when crew = 'unknown' then null
            else cast(replace(string_split(crew, '-')[1], ',', '') as integer)
        end as crew_min,
        case
            when passengers in ('unknown', 'n/a') then null
            else cast(replace(passengers, ',', '') as integer)
        end as passengers,
        case
            when cargo_capacity = 'unknown' then null
            else cast(cargo_capacity as bigint)
        end as cargo_capacity_kg,
        {{ swapi_text('consumables') }} as consumables,
        case
            when hyperdrive_rating = 'unknown' then null
            else cast(hyperdrive_rating as double)
        end as hyperdrive_rating,
        case
            when MGLT = 'unknown' then null
            else cast(MGLT as integer)
        end as mglt,
        -- Same class in different casing ('Starfighter', 'starfighter')
        lower(starship_class) as starship_class,
        pilots as pilot_urls,
        list_transform(pilots, lambda u: {{ swapi_id('u') }}) as pilot_ids,
        films as film_urls,
        list_transform(films, lambda u: {{ swapi_id('u') }}) as film_ids,
        cast(created as timestamptz) as api_created_at,
        cast(edited as timestamptz) as api_edited_at,
        url as starship_url,
        cast(_loaded_at as timestamptz) as _loaded_at
    from source
)

select * from renamed
