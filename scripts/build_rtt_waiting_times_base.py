from pathlib import Path
import re
import zipfile
import pandas as pd


BASE_DIR = Path(__file__).resolve().parents[1]
ZIP_DIR = BASE_DIR / "data" / "raw" / "rtt_waiting_times" / "zip"
PROCESSED_DIR = BASE_DIR / "data" / "processed"

OUTPUT_PARQUET = PROCESSED_DIR / "rtt_waiting_times_base.parquet"
OUTPUT_SUMMARY = PROCESSED_DIR / "rtt_waiting_times_file_summary.csv"


def normalize_column_name(col: str) -> str:
    col = col.strip().lower()
    col = re.sub(r"[^a-z0-9]+", "_", col)
    col = re.sub(r"_+", "_", col)
    return col.strip("_")


def extract_period_end_from_filename(filename: str) -> pd.Timestamp:
    match = re.search(r"(\d{8})", filename)
    if not match:
        raise ValueError(f"Could not extract YYYYMMDD from filename: {filename}")
    return pd.to_datetime(match.group(1), format="%Y%m%d")


def read_single_zip(zip_path: Path) -> tuple[pd.DataFrame, dict]:
    with zipfile.ZipFile(zip_path, "r") as zf:
        csv_files = [name for name in zf.namelist() if name.lower().endswith(".csv")]

        if len(csv_files) != 1:
            raise ValueError(f"Expected exactly 1 CSV inside {zip_path.name}, found {len(csv_files)}")

        csv_name = csv_files[0]
        period_end = extract_period_end_from_filename(csv_name)
        period_month = period_end.to_period("M").to_timestamp()

        with zf.open(csv_name) as f:
            df = pd.read_csv(f, low_memory=False)

    original_columns = list(df.columns)
    df.columns = [normalize_column_name(c) for c in df.columns]

    numeric_cols = [
        c for c in df.columns
        if c.startswith("gt_")
        or c in {"total", "patients_with_unknown_clock_start_date", "total_all"}
    ]

    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    text_cols = [c for c in df.columns if c not in numeric_cols]
    for col in text_cols:
        df[col] = df[col].astype("string").str.strip()

    df["source_zip_file"] = zip_path.name
    df["source_csv_file"] = csv_name
    df["source_period_end"] = period_end
    df["source_period_month"] = period_month
    df["ingestion_ts"] = pd.Timestamp.utcnow()

    summary = {
        "source_zip_file": zip_path.name,
        "source_csv_file": csv_name,
        "row_count": len(df),
        "column_count": len(df.columns),
        "source_period_end": period_end,
        "source_period_month": period_month,
    }

    return df, summary


def main() -> None:
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

    zip_files = sorted(ZIP_DIR.glob("*.zip"))
    if not zip_files:
        raise FileNotFoundError(f"No ZIP files found in {ZIP_DIR}")

    all_dfs = []
    summaries = []

    for zip_file in zip_files:
        df, summary = read_single_zip(zip_file)
        all_dfs.append(df)
        summaries.append(summary)

    combined = pd.concat(all_dfs, ignore_index=True)
    summary_df = pd.DataFrame(summaries)

    combined.to_parquet(OUTPUT_PARQUET, index=False)
    summary_df.to_csv(OUTPUT_SUMMARY, index=False)

    print(f"Saved base parquet: {OUTPUT_PARQUET}")
    print(f"Saved file summary: {OUTPUT_SUMMARY}")
    print(f"Combined rows: {len(combined):,}")
    print(f"Combined columns: {len(combined.columns)}")
    print("\nRows per source file:")
    print(summary_df.to_string(index=False))


if __name__ == "__main__":
    main()