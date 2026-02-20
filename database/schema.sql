-- =============================================================================
-- E-COMMERCE CUSTOMER CHURN PREDICTION
-- Schema Definition
-- Author  : Josiah Nwosu
-- Date    : February 2026
-- =============================================================================


-- -----------------------------------------------------------------------------
-- STAGING TABLES
-- Raw cleaned CSV data loaded exactly as-is with correct types.
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS stg_customers (
    customer_id          VARCHAR     NOT NULL,
    segment              VARCHAR     NOT NULL,
    state                VARCHAR     NOT NULL,
    preferred_category   VARCHAR     NOT NULL,
    preferred_channel    VARCHAR     NOT NULL,
    preferred_payment    VARCHAR     NOT NULL,
    registration_date    DATE        NOT NULL,
    age_group            VARCHAR     NOT NULL,
    n_orders             INTEGER     NOT NULL,
    last_purchase_date   DATE        NOT NULL,
    churned              INTEGER     NOT NULL,
    PRIMARY KEY (customer_id)
);

CREATE TABLE IF NOT EXISTS stg_orders (
    order_id             VARCHAR         NOT NULL,
    customer_id          VARCHAR         NOT NULL,
    order_date           DATE            NOT NULL,
    category             VARCHAR         NOT NULL,
    payment_method       VARCHAR         NOT NULL,
    channel              VARCHAR         NOT NULL,
    order_value_ngn      DECIMAL(18, 2)  NOT NULL,
    discount_pct         INTEGER         NOT NULL,
    discount_amount      DECIMAL(18, 2)  NOT NULL,
    net_order_value      DECIMAL(18, 2)  NOT NULL,
    delivery_status      VARCHAR         NOT NULL,
    delivery_days        INTEGER         NOT NULL,
    refund_amount        DECIMAL(18, 2)  NOT NULL,
    review_score         INTEGER         NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE IF NOT EXISTS stg_rfm_features (
    customer_id          VARCHAR         NOT NULL,
    last_order_date      DATE            NOT NULL,
    frequency            INTEGER         NOT NULL,
    monetary             DECIMAL(18, 2)  NOT NULL,
    avg_order_value      DECIMAL(18, 2)  NOT NULL,
    total_refunds        DECIMAL(18, 2)  NOT NULL,
    refund_count         INTEGER         NOT NULL,
    avg_review_score     DECIMAL(5,  3)  NOT NULL,
    avg_delivery_days    DECIMAL(5,  2)  NOT NULL,
    distinct_categories  INTEGER         NOT NULL,
    total_discounts      DECIMAL(18, 2)  NOT NULL,
    recency_days         INTEGER         NOT NULL,
    refund_rate          DECIMAL(5,  3)  NOT NULL,
    R_score              INTEGER         NOT NULL,
    F_score              INTEGER         NOT NULL,
    M_score              INTEGER         NOT NULL,
    RFM_score            INTEGER         NOT NULL,
    churned              INTEGER         NOT NULL,
    segment              VARCHAR         NOT NULL,
    state                VARCHAR         NOT NULL,
    age_group            VARCHAR         NOT NULL,
    registration_date    DATE            NOT NULL,
    PRIMARY KEY (customer_id)
);

CREATE TABLE IF NOT EXISTS stg_cohort_data (
    cohort_month         VARCHAR     NOT NULL,
    period_number        INTEGER     NOT NULL,
    active_customers     INTEGER     NOT NULL,
    PRIMARY KEY (cohort_month, period_number)
);


-- -----------------------------------------------------------------------------
-- POWER BI VIEWS
-- Pre-aggregated views optimised for direct import into Power BI.
-- Each view maps to one dashboard visual or table.
-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_kpi_summary AS
WITH customer_stats AS (
    SELECT 
        COUNT(customer_id)           AS total_customers,
        SUM(churned)                 AS churned_customers,
        COUNT(*) - SUM(churned)      AS retained_customers,
        ROUND(AVG(churned) * 100, 1) AS churn_rate_pct
    FROM stg_customers
),
order_stats AS (
    SELECT 
        COUNT(order_id)                     AS total_orders,
        ROUND(SUM(order_value_ngn) / 1e6, 2) AS gross_gmv_million_ngn,
        ROUND(SUM(net_order_value)  / 1e6, 2) AS net_gmv_million_ngn,
        ROUND(SUM(refund_amount)    / 1e6, 2) AS total_refunds_million_ngn,
        ROUND(AVG(net_order_value), 0)       AS avg_order_value_ngn
    FROM stg_orders
)
SELECT 
    c.*, 
    o.* FROM customer_stats c, order_stats o;

CREATE OR REPLACE VIEW vw_customer_health AS
SELECT
    r.customer_id,
    c.state,
    c.age_group,
    c.preferred_channel,
    c.preferred_payment,
    r.segment,
    r.churned,
    r.frequency                                             AS total_orders,
    ROUND(r.monetary, 0)                                    AS lifetime_value_ngn,
    ROUND(r.avg_order_value, 0)                             AS avg_order_value_ngn,
    r.recency_days,
    ROUND(r.avg_review_score, 1)                            AS avg_review_score,
    ROUND(r.refund_rate * 100, 1)                           AS refund_rate_pct,
    r.R_score,
    r.F_score,
    r.M_score,
    r.RFM_score,
    ROUND(r.monetary / NULLIF(r.frequency, 0) * 3, 0)      AS revenue_at_risk_3m_ngn,
    CASE
        WHEN r.churned      = 1    THEN 'Churned'
        WHEN r.recency_days >= 90  THEN 'High Risk'
        WHEN r.recency_days >= 60  THEN 'Medium Risk'
        WHEN r.recency_days >= 30  THEN 'Low Risk'
        ELSE                            'Active'
    END                                                     AS health_status
FROM      stg_rfm_features r
JOIN      stg_customers    c ON r.customer_id = c.customer_id;


CREATE OR REPLACE VIEW vw_churn_by_state AS
SELECT
    state,
    COUNT(*)                                                AS total_customers,
    SUM(churned)                                            AS churned_customers,
    ROUND(AVG(churned) * 100, 1)                            AS churn_rate_pct,
    ROUND(SUM(
        CASE WHEN churned = 0 AND recency_days >= 30
             THEN monetary / NULLIF(frequency, 0) * 3
             ELSE 0
        END) / 1e6, 2)                                      AS revenue_at_risk_3m_million_ngn
FROM  stg_rfm_features
GROUP BY state;


CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    DATE_TRUNC('month', order_date)::VARCHAR                AS order_month,
    COUNT(DISTINCT customer_id)                             AS active_customers,
    COUNT(DISTINCT order_id)                                AS total_orders,
    ROUND(SUM(net_order_value) / 1e6, 2)                    AS net_revenue_million_ngn,
    ROUND(AVG(net_order_value), 0)                          AS avg_order_value_ngn,
    ROUND(SUM(refund_amount)   / 1e6, 2)                    AS refunds_million_ngn
FROM  stg_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month;


CREATE OR REPLACE VIEW vw_cohort_retention AS
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


CREATE OR REPLACE VIEW vw_category_performance AS
SELECT
    category,
    COUNT(*)                                                AS total_orders,
    ROUND(SUM(net_order_value) / 1e6,  2)                  AS net_revenue_million_ngn,
    ROUND(AVG(net_order_value), 0)                          AS avg_order_value_ngn,
    ROUND(AVG(review_score),   2)                           AS avg_review_score,
    ROUND(SUM(CASE WHEN refund_amount > 0
                   THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 1)                            AS refund_rate_pct
FROM  stg_orders
GROUP BY category
ORDER BY net_revenue_million_ngn DESC;


CREATE OR REPLACE VIEW vw_segment_summary AS
SELECT
    segment,
    COUNT(*)                                                AS customers,
    SUM(churned)                                            AS churned,
    ROUND(AVG(churned) * 100, 1)                            AS churn_rate_pct,
    ROUND(AVG(monetary), 0)                                 AS avg_ltv_ngn,
    ROUND(AVG(recency_days), 0)                             AS avg_recency_days,
    ROUND(AVG(frequency), 1)                                AS avg_orders
FROM  stg_rfm_features
GROUP BY segment
ORDER BY avg_ltv_ngn DESC;
