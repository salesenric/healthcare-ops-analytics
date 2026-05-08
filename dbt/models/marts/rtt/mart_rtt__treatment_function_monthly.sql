with base as (

    select *
    from {{ ref('mart_rtt__incomplete_pathways_monthly') }}

),

aggregated as (

    select
        period_month,
        period_end_date,

        treatment_function_code,
        any_value(treatment_function_name) as treatment_function_name,

        count(distinct provider_org_code) as provider_count,
        count(distinct commissioner_org_code) as commissioner_count,

        sum(incomplete_pathways_count) as incomplete_pathways_count,
        sum(incomplete_pathways_within_18_weeks) as incomplete_pathways_within_18_weeks,
        sum(incomplete_pathways_over_18_weeks) as incomplete_pathways_over_18_weeks,
        sum(incomplete_pathways_over_52_weeks) as incomplete_pathways_over_52_weeks,
        sum(incomplete_pathways_over_78_weeks) as incomplete_pathways_over_78_weeks,
        sum(incomplete_pathways_over_104_weeks) as incomplete_pathways_over_104_weeks

    from base
    group by 1, 2, 3

),

final as (

    select
        *,

        round(
            100 * safe_divide(
                incomplete_pathways_within_18_weeks,
                incomplete_pathways_count
            ),
            2
        ) as pct_within_18_weeks,

        round(
            100 * safe_divide(
                incomplete_pathways_over_18_weeks,
                incomplete_pathways_count
            ),
            2
        ) as pct_over_18_weeks,

        round(
            100 * safe_divide(
                incomplete_pathways_over_52_weeks,
                incomplete_pathways_count
            ),
            2
        ) as pct_over_52_weeks,

        round(
            100 * safe_divide(
                incomplete_pathways_over_78_weeks,
                incomplete_pathways_count
            ),
            2
        ) as pct_over_78_weeks,

        round(
            100 * safe_divide(
                incomplete_pathways_over_104_weeks,
                incomplete_pathways_count
            ),
            2
        ) as pct_over_104_weeks

    from aggregated

)

select *
from final