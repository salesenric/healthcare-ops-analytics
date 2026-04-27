from pathlib import Path
import zipfile
import pandas as pd


BASE_DIR = Path(__file__).resolve().parents[1]
ZIP_DIR = BASE_DIR / "data" / "raw" / "rtt_waiting_times" / "zip"
EXTRACT_DIR = BASE_DIR / "data" / "raw" / "rtt_waiting_times" / "extracted"


def inspect_zip(zip_path: Path) -> None:
    print("=" * 100)
    print(f"ZIP FILE: {zip_path.name}")

    with zipfile.ZipFile(zip_path, "r") as zf:
        members = zf.namelist()
        print(f"Files inside ZIP: {len(members)}")

        for member in members:
            print(f"  - {member}")

        csv_members = [m for m in members if m.lower().endswith(".csv")]

        if not csv_members:
            print("No CSV file found inside this ZIP.")
            return

        if len(csv_members) > 1:
            print("WARNING: More than one CSV found. Inspecting the first one only.")

        target_csv = csv_members[0]
        print(f"Inspecting CSV: {target_csv}")

        with zf.open(target_csv) as f:
            df = pd.read_csv(f, nrows=5)

        print("\nColumns:")
        for col in df.columns:
            print(f"  - {col}")

        print("\nSample rows:")
        print(df.head(3).to_string(index=False))
        print()


def main() -> None:
    EXTRACT_DIR.mkdir(parents=True, exist_ok=True)

    zip_files = sorted(ZIP_DIR.glob("*.zip"))

    if not zip_files:
        print(f"No ZIP files found in: {ZIP_DIR}")
        return

    print(f"Found {len(zip_files)} ZIP files in {ZIP_DIR}\n")

    for zip_file in zip_files:
        inspect_zip(zip_file)


if __name__ == "__main__":
    main()