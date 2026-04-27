select
    period_month,
    provider_org_code,
    commissioner_org_code,
    treatment_function_code,
    count(*) as row_count
from {{ ref('mart_rtt__incomplete_pathways_monthly') }}
group by 1, 2, 3, 4
having count(*) > 1