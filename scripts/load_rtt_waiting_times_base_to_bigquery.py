from pathlib import Path
from google.cloud import bigquery


BASE_DIR = Path(__file__).resolve().parents[1]
PARQUET_FILE = BASE_DIR / "data" / "processed" / "rtt_waiting_times_base.parquet"

PROJECT_ID = "healthcare-ops-analytics-dev"
DATASET_ID = "nhs_ops_raw"
TABLE_ID = "rtt_waiting_times_base"

FULL_TABLE_ID = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"


def main() -> None:
    client = bigquery.Client(project=PROJECT_ID, location="EU")

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.PARQUET,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
    )

    with open(PARQUET_FILE, "rb") as f:
        job = client.load_table_from_file(
            f,
            FULL_TABLE_ID,
            job_config=job_config,
        )

    job.result()

    table = client.get_table(FULL_TABLE_ID)

    print(f"Loaded table: {FULL_TABLE_ID}")
    print(f"Rows: {table.num_rows:,}")
    print(f"Columns: {len(table.schema)}")


if __name__ == "__main__":
    main()