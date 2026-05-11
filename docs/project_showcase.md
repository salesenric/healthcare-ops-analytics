# Healthcare Operations Analytics — Project Showcase

## One-line summary

End-to-end analytics engineering project using NHS RTT waiting time data to build a healthcare operations analytics pipeline with Python, BigQuery, dbt, Airflow, Docker, GitHub Actions and Data Studio.

## Problem

NHS Referral to Treatment data contains monthly waiting time snapshots across providers, commissioners and treatment functions.

The goal was to transform raw public RTT files into reliable analytical marts that can support provider-level and treatment-function-level backlog monitoring.

## Technical solution

The project implements an ELT workflow:

1. Python scripts ingest and validate monthly NHS RTT ZIP files.
2. Processed data is loaded into BigQuery raw tables.
3. dbt models transform the raw data into staging, intermediate and mart layers.
4. dbt tests validate grain, nulls and KPI consistency.
5. GitHub Actions runs dbt validation automatically on push.
6. Docker provides reproducible local execution.
7. Airflow orchestrates the local ELT pipeline.
8. Data Studio provides a lightweight BI layer on top of BigQuery marts.

## Key modelling decisions

- Focused v1 on `Part_2` incomplete pathways as the waiting list backlog metric.
- Excluded `C_999` treatment function rows to avoid double-counting aggregate totals.
- Validated the analytical grain before modelling.
- Created reusable aggregate marts for provider-month and treatment-function-month analysis.
- Separated absolute volume metrics from relative long-wait pressure metrics.

## Key outputs

- `mart_rtt__incomplete_pathways_monthly`
- `mart_rtt__provider_monthly`
- `mart_rtt__treatment_function_monthly`
- Data Studio dashboard with:
  - national backlog overview
  - provider analysis
  - treatment function analysis

## Validation

The detailed mart reconciles to:

- incomplete pathways: 44,918,019
- within 18 weeks: 26,548,948
- over 18 weeks: 18,369,071
- over 52 weeks: 1,244,748

The project validates that:

```text
within_18_weeks + over_18_weeks = incomplete_pathways_count
```

## Selected findings

Between October 2024 and March 2025:

- total incomplete pathways decreased slightly from 7.57M to 7.45M
- over-18-week pathways decreased from 3.11M to 3.00M
- over-52-week pathways decreased from 237.5k to 182.6k
- the share within 18 weeks improved from 58.90% to 59.74%

## What this project demonstrates

- SQL modelling and grain control
- dbt staging/intermediate/mart design
- data quality testing
- BigQuery-based ELT
- workflow orchestration with Airflow
- containerised execution with Docker
- CI with GitHub Actions
- BI-ready analytical marts
- ability to explain technical decisions in business terms