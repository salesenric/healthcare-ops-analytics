# Setup

## Purpose
This project uses two separate Python environments:

- `.venv` for Python ingestion, cleaning, and BigQuery interaction
- `.venv-dbt` for dbt Core and dbt BigQuery

Keeping them separate makes dependency management easier and avoids mixing data engineering scripts with dbt dependencies.

---

## Environment 1: Python scripts

Used for:
- downloading or consolidating raw files
- cleaning and standardizing datasets
- loading data into BigQuery
- exploratory checks in Python

### Create
```powershell
py -V:3.11 -m venv .venv
```

### Activate
```powershell
.\.venv\Scripts\Activate.ps1
```

### Install dependencies
```powershell
pip install --upgrade pip
pip install -r requirements.txt
```

---

## Environment 2: dbt

Used for:
- `dbt run`
- `dbt test`
- `dbt docs generate`
- `dbt docs serve`

### Create
```powershell
py -V:3.11 -m venv .venv-dbt
```

### Activate
```powershell
.\.venv-dbt\Scripts\Activate.ps1
```

### Install dependencies
```powershell
pip install --upgrade pip
pip install -r requirements-dbt.txt
```

---

## Planned workflow
1. ingest raw monthly files with Python
2. clean and standardize them into base tables
3. load them into BigQuery
4. transform them with dbt
5. expose final marts for lightweight BI

---

## Notes
- BigQuery setup will be configured after the local environments are ready.
- dbt will connect to BigQuery through a local profile configuration.