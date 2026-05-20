# Healthcare Operations Analytics

![dbt CI](https://github.com/salesenric/healthcare-ops-analytics/actions/workflows/dbt_ci.yml/badge.svg)

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
- GitHub Actions CI for automated dbt validation
- Docker and Docker Compose for reproducible local execution
- Airflow-based local orchestration
- Data Studio dashboarding on top of BigQuery marts

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

A Mermaid architecture diagram is available in:

```text
docs/architecture.md
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
- GitHub Actions
- Docker
- Docker Compose
- Apache Airflow
- Data Studio, formerly Looker Studio

## Repository structure

```text
healthcare-ops-analytics/
├── .github/
│   └── workflows/
├── airflow/
│   ├── dags/
│   ├── Dockerfile
│   └── docker-compose.yml
├── dbt/
│   ├── macros/
│   ├── models/
│   │   ├── staging/
│   │   ├── intermediate/
│   │   └── marts/
│   └── tests/
├── docs/
│   └── assets/
├── scripts/
├── sql/
│   └── analysis/
├── data/
│   ├── raw/
│   ├── processed/
│   └── exports/
├── Dockerfile
├── docker-compose.yml
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

## CI/CD

The repository includes a GitHub Actions workflow for dbt CI.

On every push to `main` and on pull requests, the workflow:

- installs Python and dbt dependencies
- creates a dbt `profiles.yml` for CI
- authenticates to BigQuery using a GitHub repository secret
- runs `dbt debug`
- runs `dbt deps`
- runs `dbt compile`
- runs `dbt test`

This validates that the dbt project compiles and that data quality tests pass in a clean CI environment.

## Docker

The project includes Docker support for reproducible local execution.

Main files:

```text
Dockerfile
docker-compose.yml
.dockerignore
```

The Docker setup provides a containerised Python/dbt environment that can run project commands without relying directly on the local virtual environments.

Example commands:

```powershell
docker compose run --rm analytics python --version
docker compose run --rm analytics dbt --version
docker compose run --rm analytics bash -c "cd dbt && dbt compile"
docker compose run --rm analytics bash -c "cd dbt && dbt test"
```

The local Docker setup mounts:

- the project directory into the container
- the local dbt profile directory
- the local Google Cloud credentials directory

This allows dbt to run inside a container while still connecting to BigQuery through the local development credentials.

## Orchestration

The project includes a local Airflow setup using Docker Compose.

Airflow is used to orchestrate the end-to-end ELT workflow from local raw files to validated dbt marts.

Main files:

```text
airflow/Dockerfile
airflow/docker-compose.yml
airflow/dags/rtt_dbt_ci_dag.py
airflow/dags/rtt_elt_pipeline_dag.py
```

### Airflow DAGs

#### `rtt_dbt_ci`

This DAG validates the dbt project from Airflow.

Workflow:

```text
dbt_debug
    ↓
dbt_deps
    ↓
dbt_compile
    ↓
dbt_test
```

It is useful for checking that Airflow can execute dbt commands and connect to BigQuery.

#### `rtt_elt_pipeline`

This DAG orchestrates the local ELT workflow.

Workflow:

```text
check_raw_files
    ↓
build_rtt_base
    ↓
validate_rtt_base
    ↓
load_rtt_base_to_bigquery
    ↓
dbt_run
    ↓
dbt_test
```

This represents the full local data pipeline:

```text
raw NHS RTT ZIP files
    ↓
Python processing
    ↓
local parquet output
    ↓
BigQuery raw table
    ↓
dbt transformations
    ↓
tested analytical marts
```

The Airflow setup is intended for local development and portfolio demonstration, not production deployment.

## Dashboard

A Data Studio dashboard is available for the final BigQuery marts.

The dashboard includes:

- national backlog overview
- provider-level analysis
- treatment-function-level analysis

Dashboard documentation and screenshots are available in:

```text
docs/dashboard.md
```

## Project showcase

A concise interview-oriented project summary is available in:

```text
docs/project_showcase.md
```

It summarises the business problem, technical solution, modelling decisions, validation results, selected findings and the skills demonstrated by the project.

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

### 6. Run dbt locally

```powershell
cd dbt
dbt debug
dbt run
dbt test
```

### 7. Run dbt through Docker Compose

```powershell
docker compose run --rm analytics bash -c "cd dbt && dbt debug"
docker compose run --rm analytics bash -c "cd dbt && dbt run"
docker compose run --rm analytics bash -c "cd dbt && dbt test"
```

### 8. Run Airflow locally

```powershell
cd airflow
docker compose up -d
```

Open the Airflow UI:

```text
http://localhost:8080
```

The local Airflow setup includes two DAGs:

- `rtt_dbt_ci`
- `rtt_elt_pipeline`

The `rtt_elt_pipeline` DAG orchestrates the full local workflow from raw files to tested dbt marts.


## Current status

Completed:

- Python ingestion and validation scripts
- BigQuery raw load
- dbt staging, intermediate and mart models
- provider-level and treatment-function-level aggregate marts
- dbt data quality tests
- SQL analysis
- documented findings
- GitHub Actions dbt CI
- Docker environment for reproducible dbt execution
- Docker Compose command wrapper for local execution
- Airflow local orchestration with Docker Compose
- Data Studio dashboard connected to BigQuery marts
- dashboard screenshots and documentation
- architecture diagram
- project showcase summary for interviews and portfolio presentation

Planned improvements:

- add dashboard share link once the report is finalised
- add cost/performance notes for BigQuery
- add incremental loading pattern
- migrate GitHub Actions authentication from service account key to OIDC / Workload Identity Federation
