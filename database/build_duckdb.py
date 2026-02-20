import duckdb
import os

DB_PATH   = "database/churn.duckdb"
SCHEMA    = "database/schema.sql"
DATA_DIR  = "data/cleaned_data"

os.makedirs("database", exist_ok=True)

con = duckdb.connect(DB_PATH)

# -----------------------------------------------------------------------------
# Step 1 — Create schema (tables + Power BI views)
# -----------------------------------------------------------------------------
con.execute(open(SCHEMA, "r", encoding="utf-8").read())

# -----------------------------------------------------------------------------
# Step 2 — Load cleaned CSV files into staging tables
# -----------------------------------------------------------------------------
con.execute(f"INSERT INTO stg_customers    SELECT * FROM read_csv_auto('{DATA_DIR}/customers.csv',    header=true);")
con.execute(f"INSERT INTO stg_orders       SELECT * FROM read_csv_auto('{DATA_DIR}/orders.csv',       header=true);")
con.execute(f"INSERT INTO stg_rfm_features SELECT * FROM read_csv_auto('{DATA_DIR}/rfm_features.csv', header=true);")
con.execute(f"INSERT INTO stg_cohort_data  SELECT * FROM read_csv_auto('{DATA_DIR}/cohort_data.csv',  header=true);")

# -----------------------------------------------------------------------------
# Step 3 — Confirm row counts
# -----------------------------------------------------------------------------
counts = con.execute("""
    SELECT 'stg_customers'    AS table_name, COUNT(*) AS rows FROM stg_customers
    UNION ALL
    SELECT 'stg_orders',                     COUNT(*)         FROM stg_orders
    UNION ALL
    SELECT 'stg_rfm_features',               COUNT(*)         FROM stg_rfm_features
    UNION ALL
    SELECT 'stg_cohort_data',                COUNT(*)         FROM stg_cohort_data
""").fetchall()

print(f"\nBuilt database: {DB_PATH}")
print("-" * 35)
for table, rows in counts:
    print(f"  {table:<22} {rows:>7,} rows")

# -----------------------------------------------------------------------------
# Step 4 — Confirm Power BI views are accessible
# -----------------------------------------------------------------------------
views = [
    "vw_kpi_summary",
    "vw_customer_health",
    "vw_churn_by_state",
    "vw_monthly_revenue",
    "vw_cohort_retention",
    "vw_category_performance",
    "vw_segment_summary",
]

print("\nPower BI views:")
print("-" * 35)
for view in views:
    row_count = con.execute(f"SELECT COUNT(*) FROM {view}").fetchone()[0]
    print(f"  {view:<28} {row_count:>7,} rows")

con.close()
print("\nDone.")
