with base as (

    select *
    from {{ ref('mart_rtt__incomplete_pathways_monthly') }}

),

aggregated as (

    select
        period_month,
        period_end_date,

        provider_org_code,
        any_value(provider_org_name) as provider_org_name,
        any_value(provider_parent_org_code) as provider_parent_org_code,
        any_value(provider_parent_name) as provider_parent_name,

        count(distinct commissioner_org_code) as commissioner_count,
        count(distinct treatment_function_code) as treatment_function_count,

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