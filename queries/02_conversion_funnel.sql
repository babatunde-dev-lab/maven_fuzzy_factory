--@block
-- Big quetion: Once visitors land, how many make it to purchase?
-- Q1: What percentage of sessions reach each (Page)
WITH session_flags AS (
    SELECT 
        ws.website_session_id,
        ws.device_type,
        -- Set as 1 when page is visited
        MAX(CASE WHEN wp.pageview_url = '/home' THEN 1 ELSE 0 END) see_home,
        MAX(CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END) see_products,
        MAX(CASE WHEN wp.pageview_url IN (
            '/the-original-mr-fuzzy', '/the-forever-love-bear', 
            '/the-birthday-sugar-panda', '/the-hudson-river-mini-bear') THEN 1 ELSE 0 END
        ) see_each_product,
        MAX(CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END) see_cart,
        MAX(CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END) see_shipping,
        MAX(CASE WHEN wp.pageview_url IN ('/billing', '/billing-2') THEN 1 ELSE 0 END) AS see_billing,
        MAX(CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) see_thank_you
    FROM website_sessions ws
    JOIN website_pageviews wp
        ON ws.website_session_id = wp.website_session_id
    GROUP BY 1, 2
    -- GROUP BY 1
)

-- Percent of each flag
SELECT 
    COUNT(*) total_sessions,
    ROUND(SUM(see_home)::numeric / COUNT(*) * 100, 2) percent_home,
    ROUND(SUM(see_products)::numeric / COUNT(*) * 100, 2) percent_products,
    ROUND(SUM(see_each_product)::numeric / COUNT(*) * 100, 2) percent_reach_products,
    ROUND(SUM(see_cart)::numeric / COUNT(*) * 100, 2) percent_cart,
    ROUND(SUM(see_shipping)::numeric / COUNT(*) * 100, 2) percent_shipping,
    ROUND(SUM(see_billing)::numeric / COUNT(*) * 100, 2) percent_billing,
    ROUND(SUM(see_thank_you)::numeric / COUNT(*) * 100, 2) percent_thank_you
FROM session_flags;


--@block
-- Q2: Where is the biggest drop-off point?  

WITH session_flags AS (
    SELECT 
        ws.website_session_id,
        ws.device_type,
        -- Set as 1 when page is visited
        MAX(CASE WHEN wp.pageview_url = '/home' THEN 1 ELSE 0 END) see_home,
        MAX(CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END) see_products,
        MAX(CASE WHEN wp.pageview_url IN (
            '/the-original-mr-fuzzy', '/the-forever-love-bear', 
            '/the-birthday-sugar-panda', '/the-hudson-river-mini-bear') THEN 1 ELSE 0 END
        ) see_each_product,
        MAX(CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END) see_cart,
        MAX(CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END) see_shipping,
        MAX(CASE WHEN wp.pageview_url IN ('/billing', '/billing-2') THEN 1 ELSE 0 END) AS see_billing,
        MAX(CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) see_thank_you
    FROM website_sessions ws
    JOIN website_pageviews wp
        ON ws.website_session_id = wp.website_session_id
    GROUP BY 1, 2
),

flag_counts AS (
    SELECT 
        COUNT(*) reached_sessions,

        SUM(see_home) reached_home,
        SUM(see_products) reached_products,
        SUM(see_each_product) reached_each_products,
        SUM(see_cart) reached_cart,
        SUM(see_shipping) reached_shipping,
        SUM(see_billing) reached_billing,
        SUM(see_thank_you) reached_thank_you
    FROM 
        session_flags
)
-- Drop-off rates are calculated as (previous step - current step) / previous step * 100
SELECT
    reached_home,
    reached_products,
    ABS(ROUND((reached_home - reached_products::numeric) / reached_home * 100, 2)) home_to_products_pct,

    reached_each_products,
    ROUND((reached_products - reached_each_products::numeric) / reached_products * 100, 2) products_to_eachproduct_pct,

    reached_cart,
    ROUND((reached_each_products - reached_cart::numeric) / reached_each_products * 100, 2) page_to_cart_pct,

    reached_shipping,
    ROUND((reached_cart - reached_shipping::numeric) / reached_cart * 100, 2) cart_to_shipping_pct,

    reached_billing,
    ROUND((reached_shipping - reached_billing::numeric) / reached_shipping * 100, 2) shipping_to_billing_pct,

    reached_thank_you,
    ROUND((reached_billing - reached_thank_you::numeric) / reached_billing * 100, 2) billing_to_thankyou_pct
FROM flag_counts;



--@block
-- Q3: Funnel breakdown by device type (desktop vs mobile)
WITH session_flags AS (
    SELECT 
        ws.website_session_id,
        ws.device_type device_type,
        -- Set as 1 when page is visited
        MAX(CASE WHEN wp.pageview_url = '/home' THEN 1 ELSE 0 END) see_home,
        MAX(CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END) see_products,
        MAX(CASE WHEN wp.pageview_url IN (
            '/the-original-mr-fuzzy', '/the-forever-love-bear', 
            '/the-birthday-sugar-panda', '/the-hudson-river-mini-bear') THEN 1 ELSE 0 END
        ) see_each_product,
        MAX(CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END) see_cart,
        MAX(CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END) see_shipping,
        MAX(CASE WHEN wp.pageview_url IN ('/billing', '/billing-2') THEN 1 ELSE 0 END) AS see_billing,
        MAX(CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) see_thank_you
    FROM website_sessions ws
    JOIN website_pageviews wp
        ON ws.website_session_id = wp.website_session_id
    GROUP BY 1, 2
)

SELECT
    device_type,
    COUNT(*) total_sessions,
    SUM(see_home) reached_home,

    SUM(see_products) reached_products,
    ROUND(SUM(see_products)::numeric / SUM(see_home) * 100, 2) home_to_products_pct,

    SUM(see_each_product) reached_product_page,
    ROUND(SUM(see_each_product)::numeric / SUM(see_products) * 100, 2) products_to_eachproduct_pct,

    SUM(see_cart) reached_cart,
    ROUND(SUM(see_cart)::numeric / SUM(see_each_product) * 100, 2) page_to_cart_pct,

    SUM(see_shipping) reached_shipping,
    ROUND(SUM(see_shipping)::numeric / SUM(see_cart) * 100, 2) cart_to_shipping_pct,

    SUM(see_billing) reached_billing,
    ROUND(SUM(see_billing)::numeric / SUM(see_shipping) * 100, 2) shipping_to_billing_pct,

    SUM(see_thank_you) reached_thankyou,
    ROUND(SUM(see_thank_you)::numeric / SUM(see_billing) * 100, 2) billing_to_thankyou_pct
FROM session_flags
GROUP BY 1
ORDER BY 1;