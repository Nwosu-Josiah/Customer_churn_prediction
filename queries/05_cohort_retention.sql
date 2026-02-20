-- =============================================================================
-- 05 — COHORT RETENTION ANALYSIS
-- E-Commerce Customer Churn Prediction
-- Author : Josiah Nwosu | February 2026
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 5.1  Cohort size — customers registered and their eventual churn rate
-- -----------------------------------------------------------------------------

SELECT
    DATE_TRUNC('month', registration_date)::VARCHAR         AS cohort_month,
    COUNT(*)                                                AS cohort_size,
    SUM(churned)                                            AS churned_from_cohort,
    ROUND(AVG(churned) * 100, 1)                            AS cohort_churn_rate_pct
FROM  stg_customers
GROUP BY DATE_TRUNC('month', registration_date)
ORDER BY cohort_month;


-- -----------------------------------------------------------------------------
-- 5.2  Full cohort retention rates — percentage of each cohort still active
--      each month after registration. Source for retention heatmap in Power BI.
-- -----------------------------------------------------------------------------

WITH cohort_sizes AS (
    SELECT
        cohort_month,
        MAX(CASE WHEN period_number = 0
                 THEN active_customers END)                 AS cohort_size
    FROM   stg_cohort_data
    GROUP  BY cohort_month
)
SELECT
    cd.cohort_month,
    cd.period_number,
    cd.active_customers,
    cs.cohort_size,
    ROUND(cd.active_customers * 100.0 / cs.cohort_size, 1) AS retention_rate_pct
FROM      stg_cohort_data cd
JOIN      cohort_sizes    cs ON cd.cohort_month = cs.cohort_month
ORDER BY  cd.cohort_month, cd.period_number;


-- -----------------------------------------------------------------------------
-- 5.3  Average retention by period — across all cohorts combined
--      Answers: on average, what % of customers are still buying at Month N?
-- -----------------------------------------------------------------------------

WITH cohort_sizes AS (
    SELECT
        cohort_month,
        MAX(CASE WHEN period_number = 0
                 THEN active_customers END)                 AS cohort_size
    FROM   stg_cohort_data
    GROUP  BY cohort_month
),
retention_rates AS (
    SELECT
        cd.period_number,
        ROUND(cd.active_customers * 100.0 / cs.cohort_size, 2) AS retention_rate_pct
    FROM      stg_cohort_data cd
    JOIN      cohort_sizes    cs ON cd.cohort_month = cs.cohort_month
)
SELECT
    period_number,
    ROUND(AVG(retention_rate_pct), 1)                       AS avg_retention_pct,
    ROUND(MIN(retention_rate_pct), 1)                       AS min_retention_pct,
    ROUND(MAX(retention_rate_pct), 1)                       AS max_retention_pct
FROM  retention_rates
GROUP BY period_number
ORDER BY period_number;


-- -----------------------------------------------------------------------------
-- 5.4  Month-over-month active customer and revenue trend
-- -----------------------------------------------------------------------------

SELECT
    DATE_TRUNC('month', order_date)::VARCHAR                AS order_month,
    COUNT(DISTINCT customer_id)                             AS active_customers,
    COUNT(DISTINCT order_id)                                AS total_orders,
    ROUND(SUM(net_order_value) / 1e6, 2)                    AS net_revenue_million_ngn,
    ROUND(AVG(net_order_value), 0)                          AS avg_order_value_ngn
FROM  stg_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month;
