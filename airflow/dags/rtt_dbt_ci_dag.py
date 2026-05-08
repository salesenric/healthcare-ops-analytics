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
    dag_id="rtt_dbt_ci",
    description="Run dbt debug, deps, compile and test for the Healthcare Ops Analytics project.",
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
    tags=["dbt", "healthcare", "rtt"],
) as dag:

    dbt_debug = BashOperator(
        task_id="dbt_debug",
        bash_command=f"cd {DBT_DIR} && dbt debug",
        env=COMMON_ENV,
        append_env=True,
    )

    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=f"cd {DBT_DIR} && dbt deps",
        env=COMMON_ENV,
        append_env=True,
    )

    dbt_compile = BashOperator(
        task_id="dbt_compile",
        bash_command=f"cd {DBT_DIR} && dbt compile",
        env=COMMON_ENV,
        append_env=True,
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {DBT_DIR} && dbt test",
        env=COMMON_ENV,
        append_env=True,
    )

    dbt_debug >> dbt_deps >> dbt_compile >> dbt_test