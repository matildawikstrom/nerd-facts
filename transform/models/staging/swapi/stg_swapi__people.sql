with source as (
    select
        *
    from {{ source('swapi', 'people') }}
),

renamed as (
    select
        {{ swapi_id('url') }} as person_id,
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
            when hair_color in ('blond', 'blonde') then 'blond'
            else {{ swapi_text('hair_color') }}
        end as hair_color,
        {{ swapi_split_list(swapi_text("replace(hair_color, 'blonde', 'blond')")) }} as hair_colors,
        {{ swapi_text('skin_color') }} as skin_color,
        {{ swapi_split_list(swapi_text('skin_color')) }} as skin_colors,
        {{ swapi_text('eye_color') }} as eye_color,
        {{ swapi_split_list(swapi_text('eye_color')) }} as eye_colors,
        nullif(birth_year, 'unknown') as birth_year,
        case
            when birth_year = 'unknown' then null
            else cast(replace(birth_year, 'BBY', '') as double)
        end as birth_year_bby,
        {{ swapi_text('gender') }} as gender,
        homeworld as homeworld_url,
        {{ swapi_id('homeworld') }} as homeworld_id,
        films as film_urls,
        list_transform(films, lambda u: {{ swapi_id('u') }}) as film_ids,
        species as species_urls,
        list_transform(species, lambda u: {{ swapi_id('u') }}) as species_ids,
        vehicles as vehicle_urls,
        list_transform(vehicles, lambda u: {{ swapi_id('u') }}) as vehicle_ids,
        starships as starship_urls,
        list_transform(starships, lambda u: {{ swapi_id('u') }}) as starship_ids,
        cast(created as timestamptz) as api_created_at,
        cast(edited as timestamptz) as api_edited_at,
        url as person_url,
        cast(_loaded_at as timestamptz) as _loaded_at
    from source
)

select * from renamed