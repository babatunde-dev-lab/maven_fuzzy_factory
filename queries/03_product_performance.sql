--@block
-- BIG QUESTION: Which products drive the business?
-- Q1: What is the revenue, profit, and margin for each product?

SELECT 
    p.product_id,
    p.product_name,
    COUNT(oi.order_item_id) total_units_sold,
    SUM(oi.price_usd) total_revenue,
    SUM(oi.price_usd - oi.cogs_usd) total_profit,
    -- profit margin: profit / revenue * 100
    ROUND(SUM(oi.price_usd - oi.cogs_usd) / SUM(oi.price_usd) * 100, 2) profit_margin

FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY 1, 2
ORDER BY 4 DESC;


--@block
-- Q2: How does each product's order volume trend monthly?
SELECT 
    DATE_TRUNC('month', oi.created_at) order_month,
    p.product_name,
    COUNT(oi.order_item_id) units_sold,
    SUM(oi.price_usd) monthly_revenue

FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY 1, 2
ORDER BY 1, 2;


--@block
-- Q3: Cross-sell analysis: which products are bought together?
-- Primary item is the main product ordered; co_sell item is the other product
SELECT
    p_primary.product_name primary_product,
    p_co_sold.product_name co_sold_product,
    COUNT(*) times_co_sold
    
FROM order_items primary_items
JOIN order_items co_sold_items
    ON primary_items.order_id = co_sold_items.order_id
    -- is_primary_item being 1 or 0 shows which was the primary product and which was co_sold
    AND primary_items.is_primary_item = 1
    AND co_sold_items.is_primary_item = 0

JOIN products p_primary
    ON primary_items.product_id = p_primary.product_id

JOIN products p_co_sold
    ON co_sold_items.product_id = p_co_sold.product_id
GROUP BY 1, 2
ORDER BY 3 DESC; 


--@block
-- Q4: Which product has the highest refund rate?

SELECT 
    p.product_id,
    p.product_name,
    COUNT(oi.order_item_id) total_units_sold,
    COUNT(ref.order_item_refund_id) total_refunds,
    ROUND(COUNT(ref.order_item_refund_id)::numeric / COUNT(oi.order_item_id) * 100, 2) refund_rate,
    ROUND(SUM(COALESCE(ref.refund_amount_usd, 0)), 2) total_refund_amount
FROM 
    order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN order_item_refunds ref
    ON oi.order_item_id = ref.order_item_id
GROUP BY 1, 2
ORDER BY 5 DESC;
