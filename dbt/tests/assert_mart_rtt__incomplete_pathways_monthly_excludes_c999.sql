select *
from {{ ref('mart_rtt__incomplete_pathways_monthly') }}
where treatment_function_code = 'C_999'