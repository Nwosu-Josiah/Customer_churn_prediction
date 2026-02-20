-- =============================================================================
-- 04 — RFM SEGMENTATION ANALYSIS
-- E-Commerce Customer Churn Prediction
-- Author : Josiah Nwosu | February 2026
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 4.1  RFM score distribution — how customers spread across the 3–15 range
-- -----------------------------------------------------------------------------

SELECT
    RFM_score,
    COUNT(*)                                                AS customers,
    SUM(churned)                                            AS churned,
    ROUND(AVG(churned) * 100, 1)                            AS churn_rate_pct,
    ROUND(AVG(monetary), 0)                                 AS avg_ltv_ngn
FROM  stg_rfm_features
GROUP BY RFM_score
ORDER BY RFM_score DESC;


-- -----------------------------------------------------------------------------
-- 4.2  Average RFM component scores — churned vs retained comparison
-- -----------------------------------------------------------------------------

SELECT
    churned,
    CASE churned WHEN 1 THEN 'Churned' ELSE 'Retained' END  AS status,
    ROUND(AVG(R_score),   2)                                 AS avg_recency_score,
    ROUND(AVG(F_score),   2)                                 AS avg_frequency_score,
    ROUND(AVG(M_score),   2)                                 AS avg_monetary_score,
    ROUND(AVG(RFM_score), 2)                                 AS avg_rfm_score
FROM  stg_rfm_features
GROUP BY churned
ORDER BY churned DESC;


-- -----------------------------------------------------------------------------
-- 4.3  Full segment profile — average RFM metrics per segment
-- -----------------------------------------------------------------------------

SELECT
    segment,
    COUNT(*)                                                AS customers,
    ROUND(AVG(recency_days),      0)                        AS avg_recency_days,
    ROUND(AVG(frequency),         1)                        AS avg_orders,
    ROUND(AVG(monetary),          0)                        AS avg_ltv_ngn,
    ROUND(AVG(avg_order_value),   0)                        AS avg_order_value_ngn,
    ROUND(AVG(refund_rate) * 100, 1)                        AS avg_refund_rate_pct,
    ROUND(AVG(avg_review_score),  2)                        AS avg_review_score,
    ROUND(AVG(churned) * 100,     1)                        AS churn_rate_pct
FROM  stg_rfm_features
GROUP BY segment
ORDER BY avg_ltv_ngn DESC;


-- -----------------------------------------------------------------------------
-- 4.4  Top 20 highest-value churned customers — quantify historical revenue loss
-- -----------------------------------------------------------------------------

SELECT
    r.customer_id,
    c.state,
    c.age_group,
    r.segment,
    r.frequency                                             AS total_orders,
    ROUND(r.monetary,         0)                            AS lifetime_value_ngn,
    ROUND(r.avg_order_value,  0)                            AS avg_order_value_ngn,
    r.recency_days,
    ROUND(r.refund_rate * 100, 1)                           AS refund_rate_pct,
    ROUND(r.avg_review_score,  1)                           AS avg_review_score
FROM      stg_rfm_features r
JOIN      stg_customers    c ON r.customer_id = c.customer_id
WHERE     r.churned = 1
ORDER BY  r.monetary DESC
LIMIT 20;
