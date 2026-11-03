with source as (
    select
        *
    from {{ source('swapi', 'films') }}
),

renamed as (
    select
        {{ swapi_id('url') }} as film_id,
        title,
        episode_id,
        opening_crawl,
        director,
        {{ swapi_split_list('producer') }} as producers,
        release_date,
        characters as character_urls,
        list_transform(characters, lambda u: {{ swapi_id('u') }}) as character_ids,
        planets as planet_urls,
        list_transform(planets, lambda u: {{ swapi_id('u') }}) as planet_ids,
        starships as starship_urls,
        list_transform(starships, lambda u: {{ swapi_id('u') }}) as starship_ids,
        vehicles as vehicle_urls,
        list_transform(vehicles, lambda u: {{ swapi_id('u') }}) as vehicle_ids,
        species as species_urls,
        list_transform(species, lambda u: {{ swapi_id('u') }}) as species_ids,
        cast(created as timestamptz) as api_created_at,
        cast(edited as timestamptz) as api_edited_at,
        url as film_url,
        cast(_loaded_at as timestamptz) as _loaded_at
    from source
)

select * from renamed