# RTT Incomplete Pathways Analysis Findings

## Executive summary

This analysis explores NHS RTT incomplete pathways for Oct 2024 to Mar 2025. It focuses on monthly waiting list backlog, long-wait pressure and provider/treatment-function variation using the dbt mart `mart_rtt__incomplete_pathways_monthly`.

The analysis shows that the national incomplete pathway backlog was broadly stable over the six-month period, while very long waits improved materially. Provider-level analysis shows that the largest backlog providers are not always the worst performers proportionally, so absolute volume and long-wait percentages should be interpreted together.

## Scope

This analysis focuses on NHS RTT `Part_2` incomplete pathways, excluding `C_999` aggregate treatment function rows.

The analysis covers six reporting months:

- October 2024
- November 2024
- December 2024
- January 2025
- February 2025
- March 2025

## Data model

Source mart:

`healthcare-ops-analytics-dev.nhs_ops_analytics.mart_rtt__incomplete_pathways_monthly`

Grain:

One row per reporting month, provider, commissioner and treatment function.

## Key metrics

- `incomplete_pathways_count`: total incomplete RTT pathways.
- `incomplete_pathways_within_18_weeks`: incomplete pathways waiting within 18 weeks.
- `incomplete_pathways_over_18_weeks`: incomplete pathways waiting over 18 weeks.
- `incomplete_pathways_over_52_weeks`: incomplete pathways waiting over 52 weeks.
- `pct_over_18_weeks`: share of incomplete pathways waiting over 18 weeks.
- `pct_over_52_weeks`: share of incomplete pathways waiting over 52 weeks.

## Key findings

### 1. National backlog was broadly stable, but very long waits improved

Between Oct 2024 and Mar 2025:

- Total incomplete pathways decreased from 7.57M to 7.45M.
- Over-18-week pathways decreased from 3.11M to 3.00M.
- Over-52-week pathways decreased from 237.5k to 182.6k.
- The share within 18 weeks improved from 58.90% to 59.74%.

This suggests that the overall backlog remained broadly stable, while very long waits improved more clearly.

### 2. Largest providers by volume are not always the worst proportionally

Provider rankings differ depending on whether the analysis uses absolute backlog volume or long-wait percentage.

For example, Manchester University NHS Foundation Trust has the largest March 2025 backlog by absolute volume, while other providers show higher `pct_over_18_weeks` or `pct_over_52_weeks`.

### 3. Treatment functions show different long-wait profiles

High-volume treatment functions include Trauma and Orthopaedics, ENT, Ophthalmology, Gynaecology and Urology.

However, their long-wait profiles differ. Ophthalmology has high volume but comparatively lower `pct_over_18_weeks`, while ENT has both high volume and high long-wait pressure.

### 4. Royal Free London’s January 2025 increase was broad-based

Royal Free London NHS Foundation Trust had a large month-over-month increase in January 2025, increasing by around 31.3k incomplete pathways versus December 2024.

The increase was not concentrated in a single treatment function. The largest contributors included Other Medical Services, Trauma and Orthopaedics, Other Surgical Services, Gastroenterology, Cardiology and Gynaecology.

A further drill-down showed that most of the increase came from pathways within 18 weeks. The increase was approximately +19.7k within-18-week pathways, +11.7k over-18-week pathways and only around +0.3k over-52-week pathways. This suggests that the spike was not primarily driven by very long waits.

## Caveats

- Monthly counts are snapshots and should not be interpreted as unique patients across time.
- The analysis counts RTT pathways, not necessarily unique patients.
- Treatment function categories labelled “Other” are broad buckets and should be interpreted carefully.
- Provider rankings by absolute volume are affected by provider size and case mix.
- This analysis identifies patterns and drivers, but does not prove operational root cause.
- Commissioner-level and organisation-structure changes have not yet been deeply investigated.

## Next questions

- Which providers have high long-wait percentages after controlling for backlog size?
- Which treatment functions are consistently improving or worsening over time?
- Which provider-treatment combinations represent the most important operational hotspots?
- Are large month-over-month provider movements driven by specific commissioners?
- Can the analysis be turned into a small BI dashboard for portfolio presentation?

## Additional SQL practice findings

### Relative long-wait pressure differs from absolute backlog volume

Ranking providers by `pct_over_18_weeks` surfaces different organisations than ranking by total backlog. This reinforces the need to compare absolute volume and percentages together.

Specialist providers may appear as high-pressure outliers because of case mix, so rankings should not be interpreted as performance league tables without further context.

### Selected treatment functions show different trends

Ophthalmology and Urology show improving over-18-week shares over the period. ENT improves slightly but remains high. Trauma and Orthopaedics has a slightly declining total backlog but a worsening over-18-week share, suggesting a deterioration in backlog composition.

### Provider improvement depends on the metric used

Some providers improve in percentage terms while worsening in absolute volume. For example, Sussex Community NHS Foundation Trust shows a lower over-18-week percentage in March than October, but both total backlog and over-18 volume increase. This demonstrates why percentage and absolute change should be interpreted together.