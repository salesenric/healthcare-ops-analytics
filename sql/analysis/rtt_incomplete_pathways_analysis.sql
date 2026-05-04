-- Query 1: Monthly national backlog trend
-- Purpose:
--   Track how the national incomplete RTT pathway backlog evolves month by month.
--   This query also monitors long-wait pressure using over-18, over-52, over-78
--   and over-104 week metrics.
-- Grain:
--   One row per reporting month.
-- Main metrics:
--   incomplete_pathways_count, within_18_weeks, over_18_weeks,
--   over_52_weeks, over_78_weeks, over_104_weeks.
-- Interpretation notes:
--   These are monthly snapshot counts, not unique patients across time.
--   within_18_weeks + over_18_weeks should equal incomplete_pathways_count.
--   Trends in long waits may improve even if the total backlog remains broadly stable.
select
  period_month,
  sum(incomplete_pathways_count) as incomplete_pathways_count,
  sum(incomplete_pathways_within_18_weeks) as within_18_weeks,
  sum(incomplete_pathways_over_18_weeks) as over_18_weeks,
  sum(incomplete_pathways_over_52_weeks) as over_52_weeks,
  sum(incomplete_pathways_over_78_weeks) as over_78_weeks,
  sum(incomplete_pathways_over_104_weeks) as over_104_weeks,

  round(
    100 * safe_divide(
      sum(incomplete_pathways_within_18_weeks),
      sum(incomplete_pathways_count)
    ),
    2
  ) as pct_within_18_weeks,

  round(
    100 * safe_divide(
      sum(incomplete_pathways_over_18_weeks),
      sum(incomplete_pathways_count)
    ),
    2
  ) as pct_over_18_weeks,

  round(
    100 * safe_divide(
      sum(incomplete_pathways_over_52_weeks),
      sum(incomplete_pathways_count)
    ),
    2
  ) as pct_over_52_weeks

from `healthcare-ops-analytics-dev.nhs_ops_analytics.mart_rtt__incomplete_pathways_monthly`
group by 1
order by 1;


-- Query 2: Top providers by latest month backlog
-- Purpose:
--   Identify the providers with the largest incomplete RTT pathway backlog
--   in the latest reporting month.
-- Grain:
--   One row per provider in the latest available reporting month.
-- Main metrics:
--   incomplete_pathways_count, over_18_weeks, over_52_weeks,
--   pct_over_18_weeks, pct_over_52_weeks.
-- Interpretation notes:
--   This query ranks providers by absolute backlog volume.
--   Large providers will naturally appear near the top, so high volume does not
--   automatically mean poor relative performance.
--   Compare absolute volume and percentages together.
with latest_period as (

  select max(period_month) as period_month
  from `healthcare-ops-analytics-dev.nhs_ops_analytics.mart_rtt__incomplete_pathways_monthly`

),

provider_summary as (

  select
    m.period_month,
    m.provider_org_code,
    m.provider_org_name,

    sum(m.incomplete_pathways_count) as incomplete_pathways_count,
    sum(m.incomplete_pathways_over_18_weeks) as over_18_weeks,
    sum(m.incomplete_pathways_over_52_weeks) as over_52_weeks,

    round(
      100 * safe_divide(
        sum(m.incomplete_pathways_over_18_weeks),
        sum(m.incomplete_pathways_count)
      ),
      2
    ) as pct_over_18_weeks,

    round(
      100 * safe_divide(
        sum(m.incomplete_pathways_over_52_weeks),
        sum(m.incomplete_pathways_count)
      ),
      2
    ) as pct_over_52_weeks

  from `healthcare-ops-analytics-dev.nhs_ops_analytics.mart_rtt__incomplete_pathways_monthly` m
  join latest_period lp
    on m.period_month = lp.period_month
  group by 1, 2, 3

)

select *
from provider_summary
order by incomplete_pathways_count desc
limit 20;


-- Query 3: Top treatment functions by latest month backlog
-- Purpose:
--   Identify which treatment functions account for the largest incomplete RTT
--   pathway backlog in the latest reporting month.
-- Grain:
--   One row per treatment function in the latest available reporting month.
-- Main metrics:
--   incomplete_pathways_count, over_18_weeks, over_52_weeks,
--   pct_over_18_weeks, pct_over_52_weeks.
-- Interpretation notes:
--   This query ranks treatment functions by absolute backlog volume.
--   "Other" treatment function categories should be interpreted carefully because
--   they are broad buckets rather than clean clinical specialties.
--   A high-volume treatment function is not necessarily the worst proportionally.
with latest_period as (

  select max(period_month) as period_month
  from `healthcare-ops-analytics-dev.nhs_ops_analytics.mart_rtt__incomplete_pathways_monthly`

),

treatment_summary as (

  select
    m.period_month,
    m.treatment_function_code,
    m.treatment_function_name,

    sum(m.incomplete_pathways_count) as incomplete_pathways_count,
    sum(m.incomplete_pathways_over_18_weeks) as over_18_weeks,
    sum(m.incomplete_pathways_over_52_weeks) as over_52_weeks,

    round(
      100 * safe_divide(
        sum(m.incomplete_pathways_over_18_weeks),
        sum(m.incomplete_pathways_count)
      ),
      2
    ) as pct_over_18_weeks,

    round(
      100 * safe_divide(
        sum(m.incomplete_pathways_over_52_weeks),
        sum(m.incomplete_pathways_count)
      ),
      2
    ) as pct_over_52_weeks

  from `healthcare-ops-analytics-dev.nhs_ops_analytics.mart_rtt__incomplete_pathways_monthly` m
  join latest_period lp
    on m.period_month = lp.period_month
  group by 1, 2, 3

)

select *
from treatment_summary
order by incomplete_pathways_count desc
limit 20;


-- Query 4: Month-over-month provider movement
-- Purpose:
--   Detect providers with the largest month-over-month changes in incomplete RTT
--   pathway backlog and over-18-week backlog.
-- Grain:
--   One row per provider and reporting month, excluding the first month because
--   it has no previous month for comparison.
-- Main metrics:
--   mom_backlog_change and mom_over_18_change.
-- Interpretation notes:
--   This query is useful for anomaly detection and follow-up investigation.
--   Large changes may reflect operational changes, reporting changes, case-mix
--   changes or data quality issues.
--   It should not be used alone to infer root cause.
with provider_monthly as (

  select
    period_month,
    provider_org_code,
    provider_org_name,

    sum(incomplete_pathways_count) as incomplete_pathways_count,
    sum(incomplete_pathways_over_18_weeks) as over_18_weeks

  from `healthcare-ops-analytics-dev.nhs_ops_analytics.mart_rtt__incomplete_pathways_monthly`
  group by 1, 2, 3

),

with_previous as (

  select
    *,
    lag(incomplete_pathways_count) over (
      partition by provider_org_code
      order by period_month
    ) as previous_month_incomplete_pathways_count,

    lag(over_18_weeks) over (
      partition by provider_org_code
      order by period_month
    ) as previous_month_over_18_weeks

  from provider_monthly

),

final as (

  select
    period_month,
    provider_org_code,
    provider_org_name,

    incomplete_pathways_count,
    previous_month_incomplete_pathways_count,
    incomplete_pathways_count - previous_month_incomplete_pathways_count as mom_backlog_abs_change,

    over_18_weeks,
    previous_month_over_18_weeks,
    over_18_weeks - previous_month_over_18_weeks as mom_over_18_abs_change

  from with_previous
  where previous_month_incomplete_pathways_count is not null

)

select *
from final
order by abs(mom_backlog_abs_change) desc
limit 50;


-- Query 5: Provider-treatment long-wait hotspots
-- Purpose:
--   Identify provider and treatment function combinations with the highest
--   over-18-week incomplete RTT pathway volume in the latest reporting month.
-- Grain:
--   One row per provider, treatment function and latest reporting month.
-- Main metrics:
--   incomplete_pathways_count, over_18_weeks, over_52_weeks,
--   pct_over_18_weeks.
-- Interpretation notes:
--   This query highlights operational hotspots using absolute over-18-week volume.
--   The minimum backlog filter reduces noise from very small denominators.
--   The most relevant hotspots usually combine high absolute long-wait volume,
--   high percentage over 18 weeks and sufficient total backlog.
with latest_period as (

  select max(period_month) as period_month
  from `healthcare-ops-analytics-dev.nhs_ops_analytics.mart_rtt__incomplete_pathways_monthly`

),

provider_treatment_summary as (

  select
    m.period_month,
    m.provider_org_code,
    m.provider_org_name,
    m.treatment_function_code,
    m.treatment_function_name,

    sum(m.incomplete_pathways_count) as incomplete_pathways_count,
    sum(m.incomplete_pathways_over_18_weeks) as over_18_weeks,
    sum(m.incomplete_pathways_over_52_weeks) as over_52_weeks,

    round(
      100 * safe_divide(
        sum(m.incomplete_pathways_over_18_weeks),
        sum(m.incomplete_pathways_count)
      ),
      2
    ) as pct_over_18_weeks

  from `healthcare-ops-analytics-dev.nhs_ops_analytics.mart_rtt__incomplete_pathways_monthly` m
  join latest_period lp
    on m.period_month = lp.period_month
  group by 1, 2, 3, 4, 5

)

select *
from provider_treatment_summary
where incomplete_pathways_count >= 500
order by over_18_weeks desc
limit 50;



-- Query 6: Royal Free London January 2025 backlog increase by treatment function
-- Purpose:
--   Decompose the large January 2025 month-over-month backlog increase for
--   Royal Free London NHS Foundation Trust by treatment function.
-- Grain:
--   One row per treatment function for Royal Free London in January 2025,
--   compared with December 2024.
-- Main metrics:
--   incomplete_pathways_count, previous_month_incomplete_pathways_count,
--   mom_backlog_abs_change, mom_backlog_pct_change.
-- Interpretation notes:
--   Absolute change is the main metric for explaining the provider-level movement.
--   Percentage change can be misleading when the previous month denominator is small.
--   This query identifies drivers of the movement, but it does not prove root cause.

with provider_treatment_summary as (

  select
    period_month,
    provider_org_code,
    provider_org_name,
    treatment_function_code,
    treatment_function_name,
    sum(incomplete_pathways_count) as incomplete_pathways_count

  from `healthcare-ops-analytics-dev.nhs_ops_analytics.mart_rtt__incomplete_pathways_monthly`
  where provider_org_code = 'RAL'
    and period_month between date '2024-12-01' and date '2025-01-01'
  group by 1, 2, 3, 4, 5

),

with_previous as (

  select
    *,
    lag(incomplete_pathways_count) over (
      partition by provider_org_code, treatment_function_code
      order by period_month
    ) as previous_month_incomplete_pathways_count
  from provider_treatment_summary

),

final as (

  select
    period_month,
    provider_org_code,
    provider_org_name,
    treatment_function_code,
    treatment_function_name,
    incomplete_pathways_count,
    previous_month_incomplete_pathways_count,

    incomplete_pathways_count - previous_month_incomplete_pathways_count
      as mom_backlog_abs_change,

    round(
      100 * safe_divide(
        incomplete_pathways_count - previous_month_incomplete_pathways_count,
        previous_month_incomplete_pathways_count
      ),
      2
    ) as mom_backlog_pct_change,

    previous_month_incomplete_pathways_count is null
      as is_new_or_missing_previous_month

  from with_previous

)

select *
from final
where period_month = date '2025-01-01'
order by abs(mom_backlog_abs_change) desc;



-- Query 7: Royal Free London January 2025 backlog increase by waiting-time category
-- Purpose:
--   Understand whether the January 2025 backlog increase for Royal Free London
--   was driven by pathways within 18 weeks, over 18 weeks or over 52 weeks.
-- Grain:
--   One row per treatment function for Royal Free London in January 2025,
--   compared with December 2024.
-- Main metrics:
--   mom_total_abs_change, mom_within_18_abs_change,
--   mom_over_18_abs_change, mom_over_52_abs_change.
-- Interpretation notes:
--   This query separates total backlog growth from long-wait deterioration.
--   A treatment function can have a small total change but still worsen in
--   over-18 or over-52-week waits.
--   Over-52-week changes are useful for detecting very long-wait pressure.

with provider_treatment_summary as (

  select
    period_month,
    provider_org_code,
    provider_org_name,
    treatment_function_code,
    treatment_function_name,
    sum(incomplete_pathways_count) as incomplete_pathways_count,
    sum(incomplete_pathways_within_18_weeks) as within_18_weeks,
    sum(incomplete_pathways_over_18_weeks) as over_18_weeks,
    sum(incomplete_pathways_over_52_weeks) as over_52_weeks

  from `healthcare-ops-analytics-dev.nhs_ops_analytics.mart_rtt__incomplete_pathways_monthly`
  where provider_org_code = 'RAL'
    and period_month between date '2024-12-01' and date '2025-01-01'
  group by 1, 2, 3, 4, 5

),

with_previous as (

  select
    *,
    lag(incomplete_pathways_count) over (
      partition by provider_org_code, treatment_function_code
      order by period_month
    ) as previous_month_incomplete_pathways_count,
    lag(within_18_weeks) over (
      partition by provider_org_code, treatment_function_code
      order by period_month
    ) as previous_month_within_18_weeks,
    lag(over_18_weeks) over (
      partition by provider_org_code, treatment_function_code
      order by period_month
    ) as previous_month_over_18_weeks,
    lag(over_52_weeks) over (
      partition by provider_org_code, treatment_function_code
      order by period_month
    ) as previous_month_over_52_weeks
  from provider_treatment_summary

),

final as (

  select
    period_month,
    provider_org_code,
    provider_org_name,
    treatment_function_code,
    treatment_function_name,
    incomplete_pathways_count,
    previous_month_incomplete_pathways_count,

    incomplete_pathways_count - previous_month_incomplete_pathways_count
      as mom_total_abs_change,
    within_18_weeks - previous_month_within_18_weeks
      as mom_within_18_abs_change,
    over_18_weeks - previous_month_over_18_weeks
      as mom_over_18_abs_change,
    over_52_weeks - previous_month_over_52_weeks
      as mom_over_52_abs_change,

    round(
      100 * safe_divide(
        incomplete_pathways_count - previous_month_incomplete_pathways_count,
        previous_month_incomplete_pathways_count
      ),
      2
    ) as mom_backlog_pct_change,

    previous_month_incomplete_pathways_count is null
      as is_new_or_missing_previous_month

  from with_previous

)

select *
from final
where period_month = date '2025-01-01'
order by abs(mom_total_abs_change) desc;
