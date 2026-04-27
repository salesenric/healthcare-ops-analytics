with incomplete_pathways as (

    select *
    from {{ ref('int_rtt__incomplete_pathways') }}

),

calculated as (

    select
        period_month,
        period_end_date,

        provider_parent_org_code,
        provider_parent_name,
        provider_org_code,
        provider_org_name,

        commissioner_parent_org_code,
        commissioner_parent_name,
        commissioner_org_code,
        commissioner_org_name,

        treatment_function_code,
        treatment_function_name,

        incomplete_pathways_count,

        {{ rtt_wait_band_sum(0, 18) }} as incomplete_pathways_within_18_weeks,

        {{ rtt_wait_band_sum(18, 104, include_104_plus=true) }} as incomplete_pathways_over_18_weeks,

        {{ rtt_wait_band_sum(52, 104, include_104_plus=true) }} as incomplete_pathways_over_52_weeks,

        {{ rtt_wait_band_sum(78, 104, include_104_plus=true) }} as incomplete_pathways_over_78_weeks,

        coalesce(pathways_104_plus_weeks, 0) as incomplete_pathways_over_104_weeks

    from incomplete_pathways

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

    from calculated

)

select *
from final