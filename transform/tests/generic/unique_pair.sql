{% test unique_pair(model, column_a, column_b) %}

select
    {{ column_a }},
    {{ column_b }}
from {{ model }}
group by 1, 2
having count(*) > 1

{% endtest %}
