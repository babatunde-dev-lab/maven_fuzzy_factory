-- Active: 1775511802954@@127.0.0.1@5432@mazzy_fuzzy_factory
;

--@block
-- Q1: How many sessions and orders does each source/campaign/device combination produce? What is the conversion rate for each? Which channel drives the most revenue and profit?

SELECT 
    w.utm_source,
    w.utm_campaign,
    w.device_type,
    COUNT(DISTINCT w.website_session_id) sessions_count,
    COUNT(DISTINCT o.order_id) orders_count,
    -- Conversion rate % for each
    ROUND(
        (
            COUNT(DISTINCT o.order_id)::numeric / COUNT(DISTINCT w.website_session_id) * 100
        )
    , 2) conversion_rate,
    -- Most revenue and profit Calc
    SUM(o.price_usd) total_revenue,
    SUM(o.price_usd) - SUM(o.cogs_usd) total_profit

FROM 
    website_sessions w
LEFT JOIN orders o
ON 
    w.website_session_id = o.website_session_id
GROUP BY 1, 2, 3
ORDER BY 7 DESC;




