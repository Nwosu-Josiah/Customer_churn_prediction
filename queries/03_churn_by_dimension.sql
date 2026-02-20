-- =============================================================================
-- 03 — CHURN ANALYSIS BY DIMENSION
-- E-Commerce Customer Churn Prediction
-- Author : Josiah Nwosu | February 2026
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 3.1  Churn rate by Nigerian state — ranked highest to lowest
-- -----------------------------------------------------------------------------

SELECT
    state,
    COUNT(*)                                                AS total_customers,
    SUM(churned)                                            AS churned_customers,
    ROUND(AVG(churned) * 100, 1)                            AS churn_rate_pct,
    ROUND((COUNT(*) - SUM(churned)) * 100.0 / COUNT(*), 1) AS retention_rate_pct
FROM  stg_customers
GROUP BY state
ORDER BY churn_rate_pct DESC;


-- -----------------------------------------------------------------------------
-- 3.2  Churn rate by customer segment
-- -----------------------------------------------------------------------------

SELECT
    c.segment,
    COUNT(*)                                                AS total_customers,
    SUM(c.churned)                                          AS churned_customers,
    ROUND(AVG(c.churned) * 100, 1)                          AS churn_rate_pct,
    ROUND(AVG(r.monetary),       0)                         AS avg_lifetime_value_ngn,
    ROUND(AVG(r.recency_days),   0)                         AS avg_recency_days
FROM      stg_customers    c
JOIN      stg_rfm_features r ON c.customer_id = r.customer_id
GROUP BY  c.segment
ORDER BY  churn_rate_pct DESC;


-- -----------------------------------------------------------------------------
-- 3.3  Churn rate by age group
-- -----------------------------------------------------------------------------

SELECT
    age_group,
    COUNT(*)                                                AS total_customers,
    SUM(churned)                                            AS churned_customers,
    ROUND(AVG(churned) * 100, 1)                            AS churn_rate_pct
FROM  stg_customers
GROUP BY age_group
ORDER BY age_group;


-- -----------------------------------------------------------------------------
-- 3.4  Churn rate by preferred payment method
-- -----------------------------------------------------------------------------

SELECT
    c.preferred_payment,
    COUNT(*)                                                AS total_customers,
    SUM(c.churned)                                          AS churned_customers,
    ROUND(AVG(c.churned) * 100, 1)                          AS churn_rate_pct,
    ROUND(AVG(r.avg_order_value), 0)                        AS avg_order_value_ngn
FROM      stg_customers    c
JOIN      stg_rfm_features r ON c.customer_id = r.customer_id
GROUP BY  c.preferred_payment
ORDER BY  churn_rate_pct DESC;


-- -----------------------------------------------------------------------------
-- 3.5  Churn rate by preferred channel
-- -----------------------------------------------------------------------------

SELECT
    c.preferred_channel,
    COUNT(*)                                                AS total_customers,
    SUM(c.churned)                                          AS churned_customers,
    ROUND(AVG(c.churned) * 100, 1)                          AS churn_rate_pct,
    ROUND(AVG(r.monetary), 0)                               AS avg_lifetime_value_ngn
FROM      stg_customers    c
JOIN      stg_rfm_features r ON c.customer_id = r.customer_id
GROUP BY  c.preferred_channel
ORDER BY  churn_rate_pct DESC;


-- -----------------------------------------------------------------------------
-- 3.6  Churn rate by preferred product category
-- -----------------------------------------------------------------------------

SELECT
    c.preferred_category,
    COUNT(*)                                                AS total_customers,
    SUM(c.churned)                                          AS churned_customers,
    ROUND(AVG(c.churned) * 100, 1)                          AS churn_rate_pct,
    ROUND(AVG(r.monetary), 0)                               AS avg_lifetime_value_ngn
FROM      stg_customers    c
JOIN      stg_rfm_features r ON c.customer_id = r.customer_id
GROUP BY  c.preferred_category
ORDER BY  churn_rate_pct DESC;


-- -----------------------------------------------------------------------------
-- 3.7  Churn rate by state × segment cross-tab — source for heatmap visual
-- -----------------------------------------------------------------------------

SELECT
    c.state,
    c.segment,
    COUNT(*)                                                AS total_customers,
    SUM(c.churned)                                          AS churned_customers,
    ROUND(AVG(c.churned) * 100, 1)                          AS churn_rate_pct
FROM  stg_customers c
GROUP BY c.state, c.segment
ORDER BY c.state, churn_rate_pct DESC;