# Methodology
## E-Commerce Customer Churn Prediction

**Author:** Josiah Nwosu | **Date:** February 2026

---

## 1. Churn Definition

**Problem**

The dataset contained customer transaction records but did not include an explicit churn label. Without a clear churn definition, it was impossible to build a prediction model or segment the customer base by retention risk.

**Approach**

A binary churn label was derived from purchase recency:

* Churn = 1 if the customer's last order date is before 1 January 2024
* Churn = 0 if the customer placed at least one order on or after 1 January 2024

**Rationale**

A 60-day inactivity window is a widely used churn threshold in e-commerce. Customers who have not purchased in 6+ months (relative to the June 2024 snapshot) are considered lost without active re-engagement. This definition is transparent, reproducible, and does not require external data.

---

## 2. RFM Segmentation

**Problem**

Raw transaction data does not immediately indicate customer health. Without aggregation, it is impossible to distinguish high-value retained customers from low-value churned ones.

**Approach**

Three behavioural metrics were computed per customer from the orders table:

* **Recency** — Days since last order to snapshot date (30 June 2024). Lower = more recent
* **Frequency** — Total number of completed orders
* **Monetary** — Total net spend across all orders in NGN

Each metric was scored on a 1–5 quintile scale. Scores were summed to produce a composite RFM score (range: 3–15). Segment mapping:

| RFM Score | Segment |
|---|---|
| 13–15 | Champion |
| 10–12 | Loyal |
| 7–9 | At-Risk |
| 4–6 | Hibernating |
| 3 | Lost |

**Rationale**

RFM is the standard segmentation framework for transactional customer data. It is interpretable by non-technical stakeholders and directly maps to retention strategy decisions.

---

## 3. Market Pricing Simulation

**Problem**

The dataset contained internal nightly rates but lacked competitor pricing benchmarks. Without market reference prices, pricing efficiency analysis was impossible.

**Approach**

Market average price was simulated using a state and room-based formula:

```
Market Price = Base State Price (2-room benchmark) × Room Multiplier × Seasonal Multiplier
```

State base benchmarks (2-room equivalent):

| State | Market Tier |
|---|---|
| Lagos | Premium urban |
| Abuja | High business demand |
| Rivers | Mid-tier urban |
| Oyo | Lower mid-tier |
| Delta / Enugu | Emerging markets |

Room multipliers:

| Rooms | Multiplier |
|---|---|
| 1 room | 0.85 |
| 2 rooms | 1.00 |
| 3 rooms | 1.15 |
| 4 rooms | 1.30 |
| 5+ rooms | 1.45 |

Seasonal multipliers:

| Season | Multiplier |
|---|---|
| Peak | 1.15 |
| Off-Peak | 0.95 |

Both seasonal and non-seasonal market prices are retained in the dataset to maintain analytical flexibility.

**Rationale**

Larger apartments command higher nightly rates and premium states attract higher baseline demand. This reflects real-world Nigerian shortlet market behaviour and enables identification of underpriced high-demand units.

---

## 4. Occupancy Context

**Problem**

The dataset contained booking transactions but did not include a property availability calendar, vacant days, or true occupancy capacity. This prevented accurate occupancy analysis.

**Approach**

Each property was assumed to be available year-round:

* Total available days per property = 365
* Occupancy rate = Total booked nights ÷ 365

**Rationale**

Shortlet apartments typically operate continuously unless under maintenance. This assumption enables cross-property comparison of underutilised units, high-performing properties, and revenue vs utilisation tradeoffs. The assumption is clearly documented for transparency.

---

## 5. Customer Behaviour Simulation

**Problem**

Customer-level attributes were not available in the original dataset. Without segmentation variables, channel and guest type analysis was impossible.

**Approach**

The following attributes were simulated and appended to booking records using real property IDs:

* **Booking channel** — Airbnb, Booking.com, Direct, Agent (reflects typical Nigerian shortlet distribution mix)
* **Guest type** — Business, Leisure, Couple, Family (enables profitability and retention analysis)
* **Repeat guest flag** — Binary flag simulated to approximate realistic rebooking behaviour

**Rationale**

All simulated records use real property IDs and align with existing bookings. No synthetic properties were introduced. Referential integrity is maintained across all tables to ensure compatibility with SQL joins, dashboards, and financial analysis.

---

## 6. Predictive Modelling

**Problem**

Segment labels and RFM scores describe past behaviour but do not quantify future churn risk. A ranked watchlist requires a probability score, not just a category.

**Approach**

A Random Forest Classifier was trained on the rfm_features table to predict churn probability per customer. Feature set includes recency_days, frequency, monetary, avg_order_value, refund_rate, avg_review_score, avg_delivery_days, distinct_categories, R/F/M scores, state, and age_group.

* Train set: Orders from 2022–2023
* Test set: Orders from 2024 (temporal split to prevent data leakage)
* Class weighting: Balanced (to handle 63.7% churn rate)
* Output: churn_probability score (0–1) per active customer

Revenue at risk is calculated as:

```
Revenue at Risk = Average Monthly Spend × Churn Probability × 3-month forward window
```

**Rationale**

A temporal train/test split accurately reflects production conditions where the model predicts future churn from historical behaviour. The 3-month revenue window gives the retention team a financially meaningful intervention target.

---

## 7. Data Integrity Controls

To maintain analytical reliability across all simulated and observed data:

* All simulated records use real property IDs from the original dataset
* All records align with existing bookings — no fabricated booking events
* Referential integrity is maintained across all tables
* Churn label consistency was validated: no customer with churned = 1 has a last purchase date on or after 1 January 2024
* RFM monetary values were cross-validated against the sum of orders.net_order_value per customer
* Snapshot date is hardcoded as 30 June 2024 to ensure full reproducibility

---

## 8. Limitations

The following were not available and were therefore simulated or excluded:

* Competitor pricing feeds
* True occupancy calendar
* Customer CRM history
* Maintenance downtime periods
* Session and browsing data
* App notification engagement rates

These limitations are documented to maintain transparency and analytical integrity.
