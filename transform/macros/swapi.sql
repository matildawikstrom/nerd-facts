-- Extracts ID's from urls
{%- macro swapi_id(url) -%}
    cast(regexp_extract({{ url }}, '/(\d+)/$', 1) as integer)
{%- endmacro -%}
