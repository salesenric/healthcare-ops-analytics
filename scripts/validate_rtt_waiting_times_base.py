from pathlib import Path
import pandas as pd


BASE_DIR = Path(__file__).resolve().parents[1]
PROCESSED_DIR = BASE_DIR / "data" / "processed"

INPUT_PARQUET = PROCESSED_DIR / "rtt_waiting_times_base.parquet"

OUT_ROWS_BY_MONTH = PROCESSED_DIR / "rtt_rows_by_month.csv"
OUT_RTT_PART_TYPES = PROCESSED_DIR / "rtt_part_type_summary.csv"
OUT_TREATMENT_CODES = PROCESSED_DIR / "rtt_treatment_function_summary.csv"
OUT_TOTAL_CHECK = PROCESSED_DIR / "rtt_total_all_check_sample.csv"
OUT_NULLS = PROCESSED_DIR / "rtt_null_rate_summary.csv"


def main() -> None:
    df = pd.read_parquet(INPUT_PARQUET)

    # 1) Rows by month
    rows_by_month = (
        df.groupby("source_period_month", dropna=False)
        .size()
        .reset_index(name="row_count")
        .sort_values("source_period_month")
    )
    rows_by_month.to_csv(OUT_ROWS_BY_MONTH, index=False)

    # 2) RTT part type / description summary
    rtt_part_summary = (
        df.groupby(["rtt_part_type", "rtt_part_description"], dropna=False)
        .size()
        .reset_index(name="row_count")
        .sort_values(["rtt_part_type", "rtt_part_description"], na_position="last")
    )
    rtt_part_summary.to_csv(OUT_RTT_PART_TYPES, index=False)

    # 3) Treatment function summary
    treatment_summary = (
        df.groupby(["treatment_function_code", "treatment_function_name"], dropna=False)
        .size()
        .reset_index(name="row_count")
        .sort_values("row_count", ascending=False)
    )
    treatment_summary.to_csv(OUT_TREATMENT_CODES, index=False)

    # 4) Check whether total_all ~= total + unknown
    sample = df[
        [
            "source_period_month",
            "rtt_part_type",
            "rtt_part_description",
            "treatment_function_code",
            "treatment_function_name",
            "total",
            "patients_with_unknown_clock_start_date",
            "total_all",
        ]
    ].copy()

    sample["recalc_total_all"] = (
        sample["total"].fillna(0) + sample["patients_with_unknown_clock_start_date"].fillna(0)
    )
    sample["total_all_diff"] = sample["total_all"].fillna(0) - sample["recalc_total_all"]

    sample = sample.sort_values("total_all_diff", ascending=False)
    sample.head(500).to_csv(OUT_TOTAL_CHECK, index=False)

    # 5) Null rate summary
    null_summary = pd.DataFrame(
        {
            "column_name": df.columns,
            "null_count": [df[col].isna().sum() for col in df.columns],
            "null_rate": [df[col].isna().mean() for col in df.columns],
        }
    ).sort_values(["null_rate", "null_count"], ascending=[False, False])

    null_summary.to_csv(OUT_NULLS, index=False)

    print("Validation files created:")
    print(f" - {OUT_ROWS_BY_MONTH}")
    print(f" - {OUT_RTT_PART_TYPES}")
    print(f" - {OUT_TREATMENT_CODES}")
    print(f" - {OUT_TOTAL_CHECK}")
    print(f" - {OUT_NULLS}")


if __name__ == "__main__":
    main()