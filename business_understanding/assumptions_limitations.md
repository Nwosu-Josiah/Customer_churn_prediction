# Assumptions & Limitations
## E-Commerce Customer Churn Prediction

**Author:** Josiah Nwosu | **Date:** February 2026

---

## Assumptions

* I assumed that a customer who has not placed an order in 60 or more days (before 1 January 2024) is churned
* I assumed that all monetary values are denominated in Nigerian Naira (NGN) with no currency conversion or inflation adjustment applied
* I assumed each customer placed at least one order during the simulation period
* I assumed that the nightly rate and total booking revenues are at full price, with no discounts applied, unless a discount_pct value is explicitly recorded
* I assumed that property size and operating costs are standard across all Nigerian states
* I assumed that all properties are available year-round (365 days) with no maintenance or downtime periods
* I assumed that the amount paid for services during renovation represents 35% of the actual project cost
* I assumed that customer purchase frequency and recency are sufficient proxies for engagement without additional behavioural signals such as browsing or session data
* I assumed that the RFM snapshot date is fixed at 30 June 2024 for consistency and reproducibility across all recency calculations
* I assumed that customers with a 100% refund rate are legitimate high-risk churners and not data errors or fraudulent accounts

---

## Limitations

The data for this project is **synthetically generated** and has not been validated against real customer transaction records. Model performance metrics reflect the ability to learn from simulated patterns, not real-world predictive accuracy.

Customer-level behavioural signals were not available. The following attributes were simulated to enable segmentation analysis:

* Booking channel (Airbnb, Booking.com, Direct, Agent)
* Guest type (Business, Leisure, Couple, Family)
* Repeat guest flag

The following data was not available and was therefore not simulated:

* Competitor pricing feeds
* True occupancy calendar
* Customer CRM history
* Session and browsing data
* Customer support interaction records
* App notification engagement rates

No inflation or exchange rate adjustment has been applied. A ₦30,000 order in Q1 2022 represents materially different purchasing power than ₦30,000 in Q2 2024 following the June 2023 fuel subsidy removal. Year-on-year revenue comparisons should be interpreted with this in mind.

The 35% services-to-total-cost assumption introduces the largest analytical risk in the renovation cost analysis. If the actual ratio differs from 35%, gross margin calculations at the project level will be inaccurate.

Some inaccessible or irrecoverable data was deleted during the cleaning phase. Records deleted include rows with missing customer IDs where pricing conflicts made identification impossible, rows with missing expense dates required for period analysis, and rows that were empty across all fields.
