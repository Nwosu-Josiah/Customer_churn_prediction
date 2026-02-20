# E-Commerce Customer Churn Prediction

> **Can we identify at-risk customers before they leave — and quantify what it costs if we don't?**

A full-stack data science project covering business framing, SQL analysis, machine learning, and an interactive Power BI dashboard. Built on a Nigerian e-commerce dataset of 5,000 customers and 43,057 orders spanning January 2022 to June 2024.

---

## Results at a Glance

| Metric | Value |
|---|---|
| Customers analysed | 5,000 |
| Orders analysed | 43,057 |
| Overall churn rate | 63.7% |
| Model AUC-ROC (tuned) | **0.9766** |
| Precision @ Top Decile | **100%** |
| Revenue at risk (3-month) | **NGN 26.8M** |
| High-risk customers identified | 76 |
| Strongest churn signal | recency_days (54.2% feature importance) |

---

## Project Structure

```
ecommerce-churn-prediction/
├── README.md
├── .gitignore
├── data/
│   └── cleaned/
│       ├── customers.csv          # 5,000 customers with segments and churn label
│       ├── orders.csv             # 43,057 orders with delivery and refund data
│       ├── rfm_features.csv       # RFM scores + engineered features per customer
│       └── cohort_data.csv        # Monthly cohort retention counts (29 periods)
├── docs/
│   ├── business_problem_statement.pdf
│   ├── methodology.md
│   ├── assumptions_limitations.md
│   ├── data_dictionary.xlsx
│   ├── data_validation_checklist.xlsx
│   ├── cleaning_decisions.xlsx
│   ├── dashboard_specification.pdf
│   └── dashboard_build_steps.pdf
├── queries/                
│   ├── 01_data_quality_checks.sql
│   ├── 02_customer_overview.sql
│   ├── 03_churn_by_dimension.sql
│   ├── 04_rfm_segmentation.sql
│   ├── 05_cohort_retention.sql
│   ├── 06_order_product_analysis.sql
│   └── 07_revenue_at_risk.sql
├── database/
│   ├── build_duckdb.py   
│   └── schema.sql  
        
├── model_outputs/
│   ├── churn_prediction.ipynb            
│   ├── churn_predictions.csv      
│   ├── tuning_results.csv         
│   ├── model_evaluation.png       
│   ├── model_summary.txt
│   └── classification_report.txt
└── dashboard/
    └── customer_churn.pbix        
```

---

## Technology Stack

| Layer | Tool |
|---|---|
| Data storage & querying | DuckDB |
| SQL analysis | DuckDB SQL (7 modular query files) |
| Machine learning | Python — scikit-learn, pandas, numpy |
| Hyperparameter tuning | RandomizedSearchCV + StratifiedKFold |
| Visualisation (charts) | matplotlib, seaborn |
| Dashboard | Microsoft Power BI Desktop |
| Documentation | Markdown, Excel, PDF |

---

## How to Run the Model

**Requirements:** Python 3.9+, scikit-learn, pandas, numpy, matplotlib, seaborn

```bash
pip install scikit-learn pandas numpy matplotlib seaborn

# From the repo root:
Run all the cells of the notebook
```

Outputs are saved to `model/`:
- `churn_predictions.csv` — scored predictions for all 5,000 customers
- `model_evaluation.png` — evaluation charts
- `tuning_results.csv` — hyperparameter search results
- `model_summary.txt` — full metrics and best parameters

---

## How to Use the DuckDB Database

```bash
pip install duckdb pandas

# Build the database from cleaned CSVs:
python database/build_duckdb.py

# Query it directly:
python3 -c "
import duckdb
con = duckdb.connect('database/churn.duckdb')
print(con.execute('SELECT * FROM vw_kpi_summary').df())
"
```

---

## How to Open the Dashboard

1. Download and install [Power BI Desktop](https://powerbi.microsoft.com/desktop/) (free)
2. Open `dashboard/customer_churn.pbix`
3. If prompted to update data source paths, point each source to `data/cleaned/`

**Pages:**
- **Executive Overview** — Leadership summary: churn rate, GMV, revenue at risk
- **Customer Health Monitor** — Retention watchlist ranked by revenue at risk
- **Cohort Retention Analysis** — When do customers drop off after registration?
- **Order & Product Deep Dive** — Category, channel, delivery, and discount analysis

---

## Key Findings

**Churn is concentrated in recency.** Customers who haven't ordered in 90+ days have a >75% predicted churn probability. Recency alone accounts for 54.2% of the model's feature importance — engagement frequency and monetary value matter far less.

**The top-risk segment is small and high-value.** Only 76 customers are classified as High Risk (churn probability ≥ 75%, not yet churned). Their combined 3-month revenue at risk is the most immediately actionable intervention target.

**Cohort drop-off is steepest in Month 1.** The average cohort loses approximately 30–40% of its members within the first month after registration, suggesting onboarding is the highest-leverage retention moment.

**Electronics and Fashion drive the most revenue but also the highest refund exposure.** The combo chart on Page 4 shows that high-revenue categories carry proportionally elevated refund rates, which likely correlates with churn in the high-spend segment.

---

## Model Performance

| Model | AUC-ROC | F1 Score | Precision @ Decile 1 |
|---|---|---|---|
| Random Forest (tuned) | **0.9766** | **0.9370** | **100%** |
| Random Forest (default) | 0.9748 | 0.9344 | 100% |
| Logistic Regression | 0.9746 | 0.9234 | 100% |

**Tuning details:**
- Method: RandomizedSearchCV, 50 trials, StratifiedKFold (5 folds)
- Best params: `n_estimators=200, max_depth=5, min_samples_leaf=10, max_features=0.5`
- CV stability: mean AUC = 0.9818, std = 0.0034 (stable)

---

## Documentation

| Document | Purpose |
|---|---|
| `business_understanding/business_problem_statement.pdf` | Stakeholder brief and success criteria |
| `documentation/methodology.md` | Full analytical approach and phase breakdown |
| `business_understanding/assumptions_limitations.md` | Documented caveats and design decisions |
| `documentation/data_dictionary.xlsx` | Field definitions for all 5 tables |
| `documentation/cleaning_decisions.xlsx` | 12 cleaning steps with before/after counts |
| `documentation/data_validation_checklist.xlsx` | 9 QC checks, all returning 0 rows |

---

## Author

**Josiah Nwosu** — Data Analyst  
February 2026

---

*Built as a portfolio project demonstrating the full data analysis lifecycle: problem framing → data engineering → SQL analysis → machine learning → business dashboard.*
