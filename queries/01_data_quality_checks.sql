-- =============================================================================
-- 01 — DATA QUALITY CHECKS
-- E-Commerce Customer Churn Prediction

SELECT 'stg_customers'   AS table_name, COUNT(*) AS row_count  FROM stg_customers
UNION ALL
SELECT 'stg_orders',                     COUNT(*)              FROM stg_orders
UNION ALL
SELECT 'stg_rfm_features',               COUNT(*)              FROM stg_rfm_features
UNION ALL
SELECT 'stg_cohort_data',                COUNT(*)              FROM stg_cohort_data;

SELECT COUNT(*) AS orphaned_orders
FROM stg_orders o
LEFT JOIN stg_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS orders_before_registration
FROM stg_orders o
JOIN stg_customers c ON o.customer_id = c.customer_id
WHERE o.order_date < c.registration_date;

SELECT COUNT(*) AS churn_label_mismatches
FROM stg_customers
WHERE churned = 1
  AND last_purchase_date >= '2024-01-01';

SELECT COUNT(*) AS delivered_with_refund
FROM stg_orders
WHERE delivery_status = 'Delivered'
  AND refund_amount   > 0;

SELECT COUNT(*) AS monetary_mismatches
FROM stg_rfm_features r
JOIN (
    SELECT customer_id,
           ROUND(SUM(net_order_value), 2) AS orders_total
    FROM   stg_orders
    GROUP  BY customer_id
) o ON r.customer_id = o.customer_id
WHERE ABS(r.monetary - o.orders_total) > 0.01;

SELECT COUNT(*) AS rfm_score_mismatches
FROM stg_rfm_features
WHERE RFM_score != R_score + F_score + M_score;

SELECT COUNT(*) AS invalid_rfm_components
FROM stg_rfm_features
WHERE R_score NOT BETWEEN 1 AND 5
   OR F_score NOT BETWEEN 1 AND 5
   OR M_score NOT BETWEEN 1 AND 5;

SELECT COUNT(*) AS invalid_review_scores
FROM stg_orders
WHERE review_score NOT BETWEEN 1 AND 5;

SELECT COUNT(*) AS invalid_discount_tiers
FROM stg_orders
WHERE discount_pct NOT IN (0, 5, 10, 15, 20);

SELECT cohort_month, MIN(period_number) AS min_period
FROM stg_cohort_data
GROUP BY cohort_month
HAVING MIN(period_number) != 0;

