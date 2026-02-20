-- =============================================================================
-- 02 — CUSTOMER OVERVIEW & CHURN SUMMARY
-- E-Commerce Customer Churn Prediction
-- Author : Josiah Nwosu | February 2026
-- =============================================================================

WITH customer_stats AS (
    SELECT 
        COUNT(*) AS total_customers,
        SUM(churned) AS churned_customers,
        COUNT(*) - SUM(churned) AS retained_customers,
        ROUND(AVG(churned) * 100, 1) AS churn_rate_pct
    FROM stg_customers
),
order_stats AS (
    SELECT 
        COUNT(order_id) AS total_orders,
        ROUND(SUM(order_value_ngn) / 1e6, 2) AS gross_gmv_million_ngn,
        ROUND(SUM(net_order_value) / 1e6, 2) AS net_gmv_million_ngn,
        ROUND(SUM(refund_amount) / 1e6, 2) AS total_refunds_million_ngn,
        ROUND(AVG(net_order_value), 0) AS avg_order_value_ngn
    FROM stg_orders
)
SELECT * FROM customer_stats, order_stats;

SELECT
    c.churned,
    CASE c.churned WHEN 1 THEN 'Churned' ELSE 'Retained' END AS status,
    COUNT(DISTINCT c.customer_id)                             AS customers,
    ROUND(AVG(r.frequency),        1)                         AS avg_orders,
    ROUND(AVG(r.monetary),         0)                         AS avg_lifetime_value_ngn,
    ROUND(AVG(r.recency_days),     0)                         AS avg_recency_days,
    ROUND(AVG(r.avg_review_score), 2)                         AS avg_review_score,
    ROUND(AVG(r.refund_rate) * 100, 1)                        AS avg_refund_rate_pct,
    ROUND(AVG(r.distinct_categories), 1)                      AS avg_categories_purchased
FROM      stg_customers    c
JOIN      stg_rfm_features r ON c.customer_id = r.customer_id
GROUP BY  c.churned
ORDER BY  c.churned DESC;

SELECT
    DATE_TRUNC('month', registration_date)::VARCHAR         AS month,
    COUNT(*)                                                AS new_customers,
    SUM(churned)                                            AS eventually_churned,
    ROUND(AVG(churned) * 100, 1)                            AS churn_rate_pct
FROM  stg_customers
GROUP BY DATE_TRUNC('month', registration_date)
ORDER BY month;
