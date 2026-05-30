-- 1. products
CREATE TABLE products (
    product_id      INT PRIMARY KEY,
    created_at      TIMESTAMP,
    product_name    VARCHAR(100)
);

-- 2. website_sessions
CREATE TABLE website_sessions (
    website_session_id  INT PRIMARY KEY,
    created_at          TIMESTAMP,
    user_id             INT,
    is_repeat_session   INT,
    utm_source          VARCHAR(50),
    utm_campaign        VARCHAR(50),
    utm_content         VARCHAR(50),
    device_type         VARCHAR(20),
    http_referer        VARCHAR(150)
);

-- 3. website_pageviews
CREATE TABLE website_pageviews (
    website_pageview_id INT PRIMARY KEY,
    created_at          TIMESTAMP,
    website_session_id  INT REFERENCES website_sessions(website_session_id),
    pageview_url        VARCHAR(100)
);

-- 4. orders
CREATE TABLE orders (
    order_id            INT PRIMARY KEY,
    created_at          TIMESTAMP,
    website_session_id  INT REFERENCES website_sessions(website_session_id),
    user_id             INT,
    primary_product_id  INT REFERENCES products(product_id),
    items_purchased     INT,
    price_usd           NUMERIC,
    cogs_usd            NUMERIC
);

-- 5. order_items
CREATE TABLE order_items (
    order_item_id   INT PRIMARY KEY,
    created_at      TIMESTAMP,
    order_id        INT REFERENCES orders(order_id),
    product_id      INT REFERENCES products(product_id),
    is_primary_item INT,
    price_usd       NUMERIC,
    cogs_usd        NUMERIC
);

-- 6. order_item_refunds
CREATE TABLE order_item_refunds (
    order_item_refund_id    INT PRIMARY KEY,
    created_at              TIMESTAMP,
    order_item_id           INT REFERENCES order_items(order_item_id),
    order_id                INT REFERENCES orders(order_id),
    refund_amount_usd       NUMERIC
);