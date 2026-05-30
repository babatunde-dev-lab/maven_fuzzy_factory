# Maven Fuzzy Factory (E-Commerce Performance Analysis)

> **Business Question: How did a toy e-commerce business grow from launch to a mature operation over 3 years, and what drove that growth?**

---

## Dataset

| Table              | Rows      | Description                                                        |
| ------------------ | --------- | ------------------------------------------------------------------ |
| website_sessions   | 472,871   | One row per user session with traffic source, device, and campaign |
| website_pageviews  | 1,188,125 | One row per page visited within a session                          |
| orders             | 32,313    | One row per completed order                                        |
| order_items        | 40,025    | One row per item within an order                                   |
| order_item_refunds | 1,731     | One row per refunded item                                          |
| products           | 4         | Product catalogue with launch dates                                |

**Period covered:** March 2012 – March 2015

---

## Tools & Technologies

| Tool                          | Purpose                                        |
| ----------------------------- | ---------------------------------------------- |
| PostgreSQL (pgAdmin) & VsCode | All data analysis joins, aggregations and CTEs |
| Power BI                      | 3-page interactive dashboard                   |

No Python was used in this project. All analytical logic lives in SQL.

---

## Analytical Pipeline

| Stage                   | Business Question                                            | Key Technique                                                             |
| ----------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------- |
| 1 — Traffic Acquisition | Which channels drive sessions and convert to orders?         | LEFT JOIN sessions to orders, GROUP BY source/campaign/device             |
| 2 — Conversion Funnel   | Where do visitors drop off between landing and purchase?     | Conditional aggregation with MAX(CASE WHEN), step-by-step drop-off rates  |
| 3 — Product Performance | Which products drive revenue, and which have quality issues? | JOIN order_items to refunds, self-join for cross-sell analysis            |
| 4 — Channel Trends      | How did the business grow month by month?                    | DATE_TRUNC('month'), monthly aggregation across 3 years                   |
| 5 — Customer Behaviour  | Do repeat visitors behave differently from new ones?         | Window functions for share percentages, CTE-based customer classification |

---

## Key Findings

1. **gsearch nonbrand is the dominant acquisition channel:** Gsearch drove 316,035 sessions and $1.28M in revenue across the period, more than 4x the next channel (bsearch at $269K). Within gsearch, nonbrand desktop alone produced $956K in revenue at an 8.22% conversion rate, making it the single highest-value channel segment.

2. **The biggest funnel drop-off happens at the product page to cart step:** Only 54.83% of sessions that reached a product page proceeded to the cart, representing the steepest single-step loss in the funnel. The next largest drop-off was billing to thank-you at 37.93%, suggesting checkout friction as a secondary issue.

3. **Mobile converts at less than half the rate of desktop:** Desktop sessions reached the thank-you page at a 63.59% rate from billing, while mobile reached only 54.08%. More critically, desktop drove 163,214 sessions to a product page versus mobile's 47,000, meaning mobile is both lower volume and lower converting through the funnel.

4. **The Original Mr. Fuzzy is the revenue engine but has the second-highest refund rate:** It generated $1.21M in revenue (62% of total) across 24,226 units. However, its refund rate of 5.11% represents 1,237 returned units and $61,838 in lost revenue. The Birthday Sugar Panda had the highest refund rate at 6.04%.

5. **The Hudson River Mini Bear is the dominant co-sold product:** It was co-sold 3,126 times alongside The Original Mr. Fuzzy, making it the most common product pairing by a significant margin. All three other products co-sold more frequently with the Mini Bear, suggesting it functions as a natural add-on across the catalogue.

6. **The business tripled its conversion rate over 3 years:** From 3.19% in March 2012 to 8.31% by March 2015, representing consistent improvement in traffic quality and website performance. Monthly revenue grew from $3,000 in the first month to over $130,000 by early 2015.

---

## Recommendations

1. **Protect and scale gsearch nonbrand desktop:** This is the business's primary growth lever. Any budget decisions should prioritise maintaining its share while monitoring conversion rate for quality degradation.

2. **Investigate the product page to cart drop-off:** At 45.17% abandonment this is the single biggest revenue leak in the funnel. A/B testing product page layout, pricing presentation, or adding social proof elements could recover a significant portion of these sessions.

---

## Limitations

1. **No marketing spend data available:** Revenue and conversion rates by channel are reported without cost, so return on ad spend (ROAS) cannot be calculated. Channel efficiency comparisons are based on revenue output only.

2. **Funnel analysis covers all sessions including non-purchasing intent:** Sessions from direct navigation, internal browsing, and account management are included in funnel totals, which may understate true conversion rates for purchase-intent sessions.

---

## Conclusion

Maven Fuzzy Factory grew from a single-product startup generating $3,000 per month in March 2012 to a four-product operation producing over $130,000 per month by early 2015. That growth was driven primarily by gsearch nonbrand traffic and a consistent improvement in site conversion rate from 3.19% to 8.31%.

---

## Author

**Babatunde**
Data Analyst | Agricultural Engineering Graduate

[GitHub](https://github.com/babatunde-dev-lab)

---

## NB

This project was structured to demonstrate SQL as the primary analytical tool. All data transformations, aggregations, funnel logic, and behavioural analysis were performed in PostgreSQL using CTEs and conditional aggregation. Power BI was used solely for visualisation of pre-aggregated SQL exports.
However, in a production environment, some of these exports could be replaced by direct database connections with live refresh.
