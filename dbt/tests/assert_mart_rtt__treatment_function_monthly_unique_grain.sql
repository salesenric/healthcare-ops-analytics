select
    period_month,
    treatment_function_code,
    count(*) as row_count
from {{ ref('mart_rtt__treatment_function_monthly') }}
group by 1, 2
having count(*) > 1