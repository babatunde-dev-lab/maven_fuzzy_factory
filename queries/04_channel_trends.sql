-- Big Question: How has the business grown month by month?
-- Q1: How do monthly sessions and orders trend across 3 years? and How does conversion rate change over time?
SELECT
    DATE_TRUNC('month', ws.created_at) session_months,
    COUNT(DISTINCT o.order_id) total_orders,
    COUNT(DISTINCT ws.website_session_id) sessions_count,
    ROUND(
        (
            COUNT(DISTINCT o.order_id)::numeric / COUNT(DISTINCT ws.website_session_id) * 100
        )
    , 2) conversion_rate,
    ROUND(SUM(o.price_usd), 2) monthly_revenue,
    ROUND(SUM(o.price_usd) - SUM(o.cogs_usd), 2) monthly_profit
FROM   
    website_sessions ws
LEFT JOIN orders o
    ON o.website_session_id = ws.website_session_id
GROUP BY 1
ORDER BY 1;


--@block
-- Q2: Which channels grew and which plateaued? 
-- Monthly sessions per channel to show growth or plateau by source
SELECT
    DATE_TRUNC('month', ws.created_at) session_months,
    ws.utm_source,
    ws.utm_campaign,
    COUNT(DISTINCT o.order_id) total_orders,
    COUNT(DISTINCT ws.website_session_id) total_sessions,
    ROUND(
        (
            COUNT(DISTINCT o.order_id)::numeric / COUNT(DISTINCT ws.website_session_id) * 100
        )
    , 2) conversion_rate
FROM   
    website_sessions ws
LEFT JOIN orders o
    ON o.website_session_id = ws.website_session_id
GROUP BY 1, 2, 3
ORDER BY 1, 2;
