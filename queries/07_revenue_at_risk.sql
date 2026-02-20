-- =============================================================================
-- 07 — REVENUE AT RISK
-- E-Commerce Customer Churn Prediction
-- Author : Josiah Nwosu | February 2026
--
-- Revenue at risk is calculated as:
--   avg monthly spend × 3-month forward window
--   = (monetary / frequency) × 3
--
-- Risk tiers are defined by recency days for retained (churned = 0) customers:
--   High Risk   → 90–180 days since last order
--   Medium Risk → 60–89  days since last order
--   Low Risk    → 30–59  days since last order
--   Active      → fewer than 30 days since last order
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 7.1  Revenue at risk summary by tier
-- -----------------------------------------------------------------------------

SELECT
    CASE
        WHEN recency_days BETWEEN 90  AND 180 THEN '1 — High Risk'
        WHEN recency_days BETWEEN 60  AND  89 THEN '2 — Medium Risk'
        WHEN recency_days BETWEEN 30  AND  59 THEN '3 — Low Risk'
        ELSE                                       '4 — Active'
    END                                                     AS risk_tier,
    COUNT(*)                                                AS customers,
    ROUND(SUM(monetary) / 1e6, 2)                           AS total_ltv_million_ngn,
    ROUND(AVG(monetary), 0)                                 AS avg_ltv_ngn,
    ROUND(AVG(avg_order_value), 0)                          AS avg_order_value_ngn,
    ROUND(SUM(monetary / NULLIF(frequency, 0)
              * 3) / 1e6, 2)                                AS revenue_at_risk_3m_million_ngn
FROM  stg_rfm_features
WHERE churned = 0
GROUP BY risk_tier
ORDER BY risk_tier;


-- -----------------------------------------------------------------------------
-- 7.2  At-risk customer watchlist — top 50 retained customers by 3-month revenue at risk
--      This is the retention team's prioritised outreach list.
-- -----------------------------------------------------------------------------

SELECT
    r.customer_id,
    c.state,
    c.age_group,
    c.preferred_channel,
    c.preferred_payment,
    r.segment,
    r.frequency                                             AS total_orders,
    ROUND(r.monetary,          0)                           AS lifetime_value_ngn,
    ROUND(r.avg_order_value,   0)                           AS avg_order_value_ngn,
    r.recency_days,
    ROUND(r.avg_review_score,  1)                           AS avg_review_score,
    ROUND(r.refund_rate * 100, 1)                           AS refund_rate_pct,
    r.RFM_score,
    ROUND(r.monetary / NULLIF(r.frequency, 0) * 3, 0)      AS revenue_at_risk_3m_ngn
FROM      stg_rfm_features r
JOIN      stg_customers    c ON r.customer_id = c.customer_id
WHERE     r.churned      = 0
  AND     r.recency_days >= 30
ORDER BY  revenue_at_risk_3m_ngn DESC
LIMIT 50;


-- -----------------------------------------------------------------------------
-- 7.3  Revenue at risk by state — where is concentration highest?
-- -----------------------------------------------------------------------------

SELECT
    r.state,
    COUNT(*)                                                AS at_risk_customers,
    ROUND(SUM(r.monetary) / 1e6, 2)                         AS total_ltv_million_ngn,
    ROUND(SUM(r.monetary / NULLIF(r.frequency, 0)
              * 3) / 1e6, 2)                                AS revenue_at_risk_3m_million_ngn,
    ROUND(AVG(r.recency_days), 0)                           AS avg_recency_days
FROM  stg_rfm_features r
WHERE r.churned      = 0
  AND r.recency_days >= 30
GROUP BY r.state
ORDER BY revenue_at_risk_3m_million_ngn DESC;


-- -----------------------------------------------------------------------------
-- 7.4  Revenue already lost — what churned customers were worth
-- -----------------------------------------------------------------------------

SELECT
    c.state,
    COUNT(*)                                                AS churned_customers,
    ROUND(SUM(r.monetary) / 1e6, 2)                         AS lost_ltv_million_ngn,
    ROUND(AVG(r.monetary), 0)                               AS avg_lost_ltv_ngn,
    ROUND(AVG(r.frequency), 1)                              AS avg_orders_before_churn,
    ROUND(AVG(r.avg_review_score), 2)                       AS avg_review_score
FROM      stg_rfm_features r
JOIN      stg_customers    c ON r.customer_id = c.customer_id
WHERE     r.churned = 1
GROUP BY  c.state
ORDER BY  lost_ltv_million_ngn DESC;
