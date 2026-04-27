{% macro rtt_wait_band_sum(start_week, end_week, include_104_plus=false) %}
    (
    {%- set expressions = [] -%}

    {%- for week in range(start_week, end_week) -%}
        {%- set start_label = "%02d"|format(week) -%}
        {%- set end_label = "%02d"|format(week + 1) -%}
        {%- set col_name = "pathways_" ~ start_label ~ "_to_" ~ end_label ~ "_weeks" -%}
        {%- do expressions.append("coalesce(" ~ col_name ~ ", 0)") -%}
    {%- endfor -%}

    {%- if include_104_plus -%}
        {%- do expressions.append("coalesce(pathways_104_plus_weeks, 0)") -%}
    {%- endif -%}

    {{ expressions | join(" +\n        ") }}
    )
{% endmacro %}