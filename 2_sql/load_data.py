import sqlite3
import pandas as pd
from pathlib import Path

# Build paths relative to this script's location
BASE_DIR = Path(__file__).resolve().parent.parent

# Load validated parquet files
national_df = pd.read_parquet(
    BASE_DIR / "0_data" / "1_validated" / "national_validated.parquet"
)
regional_df = pd.read_parquet(
    BASE_DIR / "0_data" / "1_validated" / "regional_validated.parquet"
)
icd10_df = pd.read_parquet(
    BASE_DIR / "0_data" / "1_validated" / "icd10_regional_rates_validated.parquet"
)

# Create SQLite database
conn = sqlite3.connect(
    BASE_DIR / "0_data" / "2_sqlite" / "cyp_cancer.db"
)

# Write tables
national_df.to_sql(
    "national_incidence", conn, if_exists="replace", index=False
)
regional_df.to_sql(
    "regional_incidence", conn, if_exists="replace", index=False
)
icd10_df.to_sql(
    "icd10_regional_rates", conn, if_exists="replace", index=False
)

# Confirm tables created
print("Tables created:")
cursor = conn.cursor()
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
print(cursor.fetchall())

# Confirm row counts
for table in ["national_incidence", "regional_incidence", "icd10_regional_rates"]:
    cursor.execute(f"SELECT COUNT(*) FROM {table}")
    print(f"{table}: {cursor.fetchone()[0]} rows")

conn.close()
print("Done.")