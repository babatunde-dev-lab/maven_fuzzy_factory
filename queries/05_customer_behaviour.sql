-- Big Question: Who are our customers and do they come back?

-- Q1: What share of sessions are from repeat visitors?

SELECT
    CASE WHEN is_repeat_session = 0 THEN 'New' ELSE 'Repeat' END visitor_type,
    COUNT(website_session_id) total_sessions,
    ROUND(COUNT(website_session_id)::numeric /
          SUM(COUNT(website_session_id)) OVER () * 100, 2) session_share_pct
FROM website_sessions
GROUP BY is_repeat_session
ORDER BY is_repeat_session;

--@block
-- Q2: Do repeat visitors convert at a higher rate than new visitors?
SELECT
    CASE WHEN ws.is_repeat_session = 0 THEN 'New' ELSE 'Repeat' END visitor_type,
    COUNT(DISTINCT o.order_id) total_orders,
    COUNT(DISTINCT ws.website_session_id) total_sessions,
    ROUND(
        (
            COUNT(DISTINCT o.order_id)::numeric / COUNT(DISTINCT ws.website_session_id) * 100
        )
    , 2) conversion_rate,
    ROUND(AVG(o.price_usd), 2) avg_order_value
FROM   
    website_sessions ws
LEFT JOIN orders o
    ON o.website_session_id = ws.website_session_id
GROUP BY 1
ORDER BY 1; 


--@block
--  Q3: How many users placed more than one order?
WITH user_order_counts AS (
    SELECT 
        user_id,
        COUNT(*) order_count
    FROM 
        orders
    GROUP BY 1
)

SELECT 
    CASE
        WHEN order_count = 1 THEN 'Single Order'
        WHEN order_count = 2 THEN '2 Orders'
        WHEN order_count = 3 THEN '3 Orders'
        ELSE '4+ Orders'
    END customer_type,
    COUNT(user_id) num_customers,
    ROUND(COUNT(user_id)::numeric / SUM(COUNT(user_id)) OVER () * 100, 2) customer_share_pct
FROM 
    user_order_counts
GROUP BY 1
ORDER BY 2 DESC;


--@block
-- Q4: What is the average order value for single vs multi-order customers? 
WITH user_order_counts AS (
    SELECT 
        user_id,
        COUNT(*) order_count
    FROM 
        orders
    GROUP BY 1
),

customer_classification AS (
    SELECT 
        user_id,
        CASE 
            WHEN order_count = 1 THEN 'Single Order Customer' 
            ELSE 'Multi-Order Customer' 
        END customer_type
    FROM user_order_counts
)

SELECT
    cc.customer_type,
    COUNT(DISTINCT o.order_id) total_orders,
    ROUND(AVG(o.price_usd), 2) avg_order_value,
    ROUND(SUM(o.price_usd), 2) total_revenue
FROM orders o
JOIN customer_classification cc
    ON o.user_id = cc.user_id
GROUP BY 1
ORDER BY 3 DESC;


--@block
-- COMBINING Q3 and Q4 for export

WITH user_order_counts AS (
    SELECT
        user_id,
        COUNT(order_id) order_count
    FROM orders
    GROUP BY user_id
),
customer_classification AS (
    SELECT
        user_id,
        CASE
            WHEN order_count = 1 THEN 'Single Order'
            WHEN order_count = 2 THEN '2 Orders'
            WHEN order_count = 3 THEN '3 Orders'
            ELSE '4+ Orders'
        END customer_type
    FROM user_order_counts
),

-- Q3 result
q3 AS (
    SELECT
        customer_type,
        COUNT(user_id) num_customers,
        ROUND(COUNT(user_id)::NUMERIC /
              SUM(COUNT(user_id)) OVER () * 100, 2) customer_share_pct
    FROM customer_classification
    GROUP BY customer_type
),

-- Q4 result
q4 AS (
    SELECT
        cc.customer_type,
        COUNT(DISTINCT o.order_id) total_orders,
        ROUND(AVG(o.price_usd), 2) avg_order_value,
        ROUND(SUM(o.price_usd), 2) total_revenue
    FROM orders o
    JOIN customer_classification cc
        ON o.user_id = cc.user_id
    GROUP BY cc.customer_type
)

-- Join both on customer_type
SELECT
    q3.customer_type,
    q3.num_customers,
    q3.customer_share_pct,
    q4.total_orders,
    q4.avg_order_value,
    q4.total_revenue
FROM q3
JOIN q4
    ON q3.customer_type = q4.customer_type
ORDER BY q4.total_orders DESC;