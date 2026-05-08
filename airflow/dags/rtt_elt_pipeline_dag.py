from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator


PROJECT_DIR = "/opt/airflow/project"
DBT_DIR = f"{PROJECT_DIR}/dbt"

COMMON_ENV = {
    "GOOGLE_CLOUD_PROJECT": "healthcare-ops-analytics-dev",
    "CLOUDSDK_CORE_PROJECT": "healthcare-ops-analytics-dev",
    "DBT_PROFILES_DIR": "/home/airflow/.dbt",
    "CLOUDSDK_CONFIG": "/home/airflow/.config/gcloud",
}


with DAG(
    dag_id="rtt_elt_pipeline",
    description="End-to-end ELT pipeline for NHS RTT incomplete pathways analytics.",
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
    tags=["elt", "dbt", "bigquery", "healthcare", "rtt"],
) as dag:

    check_raw_files = BashOperator(
        task_id="check_raw_files",
        bash_command=(
            f"cd {PROJECT_DIR} && "
            "test -d data/raw/rtt_waiting_times/zip && "
            "ls -1 data/raw/rtt_waiting_times/zip/*.zip"
        ),
        env=COMMON_ENV,
        append_env=True,
    )

    build_rtt_base = BashOperator(
        task_id="build_rtt_base",
        bash_command=(
            f"cd {PROJECT_DIR} && "
            "python scripts/build_rtt_waiting_times_base.py"
        ),
        env=COMMON_ENV,
        append_env=True,
    )

    validate_rtt_base = BashOperator(
        task_id="validate_rtt_base",
        bash_command=(
            f"cd {PROJECT_DIR} && "
            "python scripts/validate_rtt_waiting_times_base.py"
        ),
        env=COMMON_ENV,
        append_env=True,
    )

    load_rtt_base_to_bigquery = BashOperator(
        task_id="load_rtt_base_to_bigquery",
        bash_command=(
            f"cd {PROJECT_DIR} && "
            "python scripts/load_rtt_waiting_times_base_to_bigquery.py"
        ),
        env=COMMON_ENV,
        append_env=True,
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"cd {DBT_DIR} && dbt run",
        env=COMMON_ENV,
        append_env=True,
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {DBT_DIR} && dbt test",
        env=COMMON_ENV,
        append_env=True,
    )

    (
        check_raw_files
        >> build_rtt_base
        >> validate_rtt_base
        >> load_rtt_base_to_bigquery
        >> dbt_run
        >> dbt_test
    )