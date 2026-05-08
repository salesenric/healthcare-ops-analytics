# Healthcare Operations Analytics

End-to-end analytics engineering project modelling NHS Referral to Treatment (RTT) waiting time data using Python, BigQuery and dbt.

The project focuses on building a reliable ELT workflow for healthcare operations analytics: ingesting public monthly NHS RTT data, loading it into BigQuery, modelling it with dbt, validating metric consistency, and producing marts for provider-level and treatment-function-level analysis.

## Project objectives

This project was built to practice and demonstrate:

- Python-based ingestion and preprocessing of public healthcare datasets
- Cloud warehouse loading into BigQuery
- dbt Core modelling with staging, intermediate and mart layers
- Analytical grain validation and metric reconciliation
- Data quality checks with dbt tests
- Reusable marts for BI and operational reporting
- SQL analysis of waiting list backlog and long-wait pressure

## Business context

NHS Referral to Treatment (RTT) data tracks patient pathways from referral to consultant-led elective treatment.

This project focuses on `Part_2` incomplete pathways, which represent RTT pathways still open at the end of the reporting period. These are used as a proxy for waiting list backlog.

The analysis excludes `C_999` treatment function rows because they represent aggregate totals, not granular treatment functions.

## Data source

Dataset: NHS RTT Waiting Times 2024-25 monthly CSV releases.

Current scope:

- October 2024
- November 2024
- December 2024
- January 2025
- February 2025
- March 2025

The raw files are downloaded manually as monthly ZIP files and processed locally before being loaded into BigQuery.

## Architecture

```text
NHS monthly ZIP files
        ↓
Python ingestion and validation scripts
        ↓
Local processed parquet
        ↓
BigQuery raw table
        ↓
dbt staging model
        ↓
dbt intermediate model
        ↓
dbt detailed mart
        ↓
dbt aggregate marts
        ↓
SQL analysis / BI layer
```

## Tech stack

- Python
- pandas
- pyarrow
- BigQuery
- dbt Core
- dbt-bigquery
- SQL
- Git / GitHub
- Tableau Public, Looker Studio or Power BI planned for BI layer

## Repository structure

```text
healthcare-ops-analytics/
├── dbt/
│   ├── macros/
│   ├── models/
│   │   ├── staging/
│   │   ├── intermediate/
│   │   └── marts/
│   └── tests/
├── docs/
├── scripts/
├── sql/
│   └── analysis/
├── data/
│   ├── raw/
│   ├── processed/
│   └── exports/
├── requirements.txt
├── requirements-dbt.txt
└── README.md
```

## Python pipeline

The Python scripts handle raw file inspection, base table construction, validation and BigQuery loading.

Main scripts:

- `scripts/inspect_rtt_raw_files.py`
- `scripts/build_rtt_waiting_times_base.py`
- `scripts/validate_rtt_waiting_times_base.py`
- `scripts/load_rtt_waiting_times_base_to_bigquery.py`

The base processed file contains:

- 1,118,038 rows
- 126 columns
- 6 monthly reporting periods

## BigQuery datasets

Raw dataset:

```text
healthcare-ops-analytics-dev.nhs_ops_raw
```

Analytics dataset:

```text
healthcare-ops-analytics-dev.nhs_ops_analytics
```

Raw table:

```text
nhs_ops_raw.rtt_waiting_times_base
```

## dbt models

### Source

```text
source('nhs_ops_raw', 'rtt_waiting_times_base')
```

### Staging

```text
stg_nhs_ops__rtt_waiting_times_base
```

Standardises period fields, renames waiting-time band columns and casts count measures to integers.

### Intermediate

```text
int_rtt__incomplete_pathways
```

Filters the raw RTT dataset to:

```sql
rtt_part_type = 'Part_2'
and treatment_function_code != 'C_999'
```

The validated grain is:

```text
one row per reporting month, provider, commissioner and treatment function
```

### Detailed mart

```text
mart_rtt__incomplete_pathways_monthly
```

Detailed mart for incomplete RTT pathways, including backlog and waiting-time KPI fields.

### Aggregate marts

```text
mart_rtt__provider_monthly
mart_rtt__treatment_function_monthly
```

These marts provide reusable provider-level and treatment-function-level datasets for BI, reporting and analysis.

## Key metrics

- `incomplete_pathways_count`
- `incomplete_pathways_within_18_weeks`
- `incomplete_pathways_over_18_weeks`
- `incomplete_pathways_over_52_weeks`
- `incomplete_pathways_over_78_weeks`
- `incomplete_pathways_over_104_weeks`
- `pct_within_18_weeks`
- `pct_over_18_weeks`
- `pct_over_52_weeks`

## Data quality and validation

The project includes semantic profiling and dbt tests to validate:

- raw row counts
- reporting month coverage
- RTT part composition
- candidate analytical grain
- exclusion of `C_999` aggregate rows
- waiting-time band totals against published totals
- uniqueness of mart grains
- KPI consistency checks

Key reconciliation result for the detailed mart:

```text
incomplete_pathways_count = 44,918,019
within_18_weeks           = 26,548,948
over_18_weeks             = 18,369,071
over_52_weeks             = 1,244,748
```

The project validates that:

```text
within_18_weeks + over_18_weeks = incomplete_pathways_count
```

## Analysis

Analysis SQL is stored in:

```text
sql/analysis/rtt_incomplete_pathways_analysis.sql
```

Findings are documented in:

```text
docs/rtt_incomplete_pathways_findings.md
```

The analysis covers:

- national backlog trend
- top providers by backlog
- top treatment functions by backlog
- month-over-month provider movement
- provider-treatment long-wait hotspots
- drill-down of Royal Free London’s January 2025 backlog increase
- comparison of absolute volume and percentage-based long-wait pressure

## Selected findings

Between October 2024 and March 2025:

- total incomplete pathways decreased slightly from 7.57M to 7.45M
- over-18-week pathways decreased from 3.11M to 3.00M
- over-52-week pathways decreased from 237.5k to 182.6k
- the share within 18 weeks improved from 58.90% to 59.74%

Provider-level analysis shows that the largest providers by backlog volume are not always the worst performers proportionally. Absolute backlog and long-wait percentages need to be interpreted together.

Royal Free London NHS Foundation Trust showed a large January 2025 month-over-month increase. The increase was broad-based across treatment functions and was driven mainly by pathways within 18 weeks rather than very long waits over 52 weeks.

## How to run

### 1. Create Python environment

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### 2. Build processed base file

```powershell
python scripts/build_rtt_waiting_times_base.py
```

### 3. Validate processed base file

```powershell
python scripts/validate_rtt_waiting_times_base.py
```

### 4. Load to BigQuery

```powershell
python scripts/load_rtt_waiting_times_base_to_bigquery.py
```

### 5. Create dbt environment

```powershell
python -m venv .venv-dbt
.\.venv-dbt\Scripts\Activate.ps1
pip install -r requirements-dbt.txt
```

### 6. Run dbt

```powershell
cd dbt
dbt debug
dbt run
dbt test
```

## Current status

Completed:

- Python ingestion and validation scripts
- BigQuery raw load
- dbt staging, intermediate and mart models
- provider-level and treatment-function-level aggregate marts
- dbt data quality tests
- SQL analysis
- documented findings

Planned improvements:

- add GitHub Actions for dbt compile/test
- add orchestration with Airflow or Prefect
- add a lightweight BI dashboard
- add architecture diagram
- add incremental loading pattern
- add cost/performance notes for BigQuery