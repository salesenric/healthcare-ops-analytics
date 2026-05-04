select
    period_month,
    provider_org_code,
    count(*) as row_count
from {{ ref('mart_rtt__provider_monthly') }}
group by 1, 2
having count(*) > 1