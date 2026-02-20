-- =============================================================================
-- 06 — ORDER & PRODUCT ANALYSIS
-- E-Commerce Customer Churn Prediction
-- Author : Josiah Nwosu | February 2026
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 6.1  Revenue and order volume by product category
-- -----------------------------------------------------------------------------

SELECT
    category,
    COUNT(*)                                                AS total_orders,
    ROUND(SUM(order_value_ngn) / 1e6, 2)                    AS gross_revenue_million_ngn,
    ROUND(SUM(net_order_value) / 1e6,  2)                   AS net_revenue_million_ngn,
    ROUND(AVG(net_order_value), 0)                          AS avg_order_value_ngn,
    ROUND(SUM(refund_amount)   / 1e6,  2)                   AS refunds_million_ngn,
    ROUND(SUM(CASE WHEN refund_amount > 0
                   THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 1)                            AS refund_rate_pct,
    ROUND(AVG(review_score),   2)                           AS avg_review_score,
    ROUND(AVG(delivery_days),  1)                           AS avg_delivery_days
FROM  stg_orders
GROUP BY category
ORDER BY gross_revenue_million_ngn DESC;


-- -----------------------------------------------------------------------------
-- 6.2  Delivery status breakdown — volume and revenue impact
-- -----------------------------------------------------------------------------

SELECT
    delivery_status,
    COUNT(*)                                                AS total_orders,
    ROUND(COUNT(*) * 100.0
          / SUM(COUNT(*)) OVER (), 1)                       AS pct_of_all_orders,
    ROUND(SUM(net_order_value) / 1e6,  2)                   AS net_revenue_million_ngn,
    ROUND(SUM(refund_amount)   / 1e6,  2)                   AS refunds_million_ngn,
    ROUND(AVG(review_score),   2)                           AS avg_review_score
FROM  stg_orders
GROUP BY delivery_status
ORDER BY total_orders DESC;


-- -----------------------------------------------------------------------------
-- 6.3  Payment method performance — revenue and customer experience
-- -----------------------------------------------------------------------------

SELECT
    payment_method,
    COUNT(*)                                                AS total_orders,
    ROUND(SUM(net_order_value) / 1e6,  2)                   AS net_revenue_million_ngn,
    ROUND(AVG(net_order_value), 0)                          AS avg_order_value_ngn,
    ROUND(AVG(delivery_days),  1)                           AS avg_delivery_days,
    ROUND(AVG(review_score),   2)                           AS avg_review_score,
    ROUND(SUM(CASE WHEN refund_amount > 0
                   THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 1)                            AS refund_rate_pct
FROM  stg_orders
GROUP BY payment_method
ORDER BY net_revenue_million_ngn DESC;


-- -----------------------------------------------------------------------------
-- 6.4  Channel performance — Mobile App vs Web vs Social Commerce
-- -----------------------------------------------------------------------------

SELECT
    channel,
    COUNT(*)                                                AS total_orders,
    COUNT(DISTINCT customer_id)                             AS unique_customers,
    ROUND(SUM(net_order_value) / 1e6,  2)                   AS net_revenue_million_ngn,
    ROUND(AVG(net_order_value), 0)                          AS avg_order_value_ngn,
    ROUND(AVG(review_score),   2)                           AS avg_review_score
FROM  stg_orders
GROUP BY channel
ORDER BY net_revenue_million_ngn DESC;


-- -----------------------------------------------------------------------------
-- 6.5  Discount effectiveness — does heavier discounting correlate with more orders?
-- -----------------------------------------------------------------------------

SELECT
    discount_pct,
    COUNT(*)                                                AS total_orders,
    COUNT(DISTINCT customer_id)                             AS unique_customers,
    ROUND(AVG(net_order_value), 0)                          AS avg_net_order_value_ngn,
    ROUND(SUM(discount_amount) / 1e6,  2)                   AS total_discount_given_million_ngn,
    ROUND(AVG(review_score),   2)                           AS avg_review_score,
    ROUND(SUM(CASE WHEN refund_amount > 0
                   THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 1)                            AS refund_rate_pct
FROM  stg_orders
GROUP BY discount_pct
ORDER BY discount_pct;
