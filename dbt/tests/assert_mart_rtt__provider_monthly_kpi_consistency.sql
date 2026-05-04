select *
from {{ ref('mart_rtt__provider_monthly') }}
where incomplete_pathways_count
      != incomplete_pathways_within_18_weeks + incomplete_pathways_over_18_weeks

   or incomplete_pathways_over_18_weeks < incomplete_pathways_over_52_weeks

   or incomplete_pathways_over_52_weeks < incomplete_pathways_over_78_weeks

   or incomplete_pathways_over_78_weeks < incomplete_pathways_over_104_weeks

   or pct_within_18_weeks < 0
   or pct_within_18_weeks > 100

   or pct_over_18_weeks < 0
   or pct_over_18_weeks > 100

   or pct_over_52_weeks < 0
   or pct_over_52_weeks > 100

   or pct_over_78_weeks < 0
   or pct_over_78_weeks > 100

   or pct_over_104_weeks < 0
   or pct_over_104_weeks > 100