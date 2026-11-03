{# Extracts IDs from urls #}
{%- macro swapi_id(url) -%}
    cast(regexp_extract({{ url }}, '/(\d+)/$', 1) as integer)
{%- endmacro -%}

{# Handle unknowns, n/a and none #}
{%- macro swapi_text(column) -%}
    case
        when {{ column }} in ('n/a', 'none') then 'n/a'
        when {{ column }} = 'unknown' then null
        else {{ column }}
    end
{%- endmacro -%}

{# Split comma-separated values to list #}
{%- macro swapi_split_list(column) -%}
    list_transform(string_split({{ column }}, ','), lambda p: trim(p))
{%- endmacro -%}
