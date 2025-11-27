-- ============================================
-- PART 1: DATA IMPORTATIONN AND CLEANING
-- ============================================

--Staging Dataco--
CREATE TABLE staging_dataco (
    type TEXT,
    days_for_shipping_real INTEGER,
    days_for_shipment_scheduled INTEGER,
    benefit_per_order NUMERIC,
    sales_per_customer NUMERIC,
    delivery_status TEXT,
    late_delivery_risk INTEGER,
    category_id INTEGER,
    category_name TEXT,
    customer_city TEXT,
    customer_country TEXT,
    customer_email TEXT,
    customer_fname TEXT,
    customer_id INTEGER,
    customer_lname TEXT,
    customer_password TEXT,
    customer_segment TEXT,
    customer_state TEXT,
    customer_street TEXT,
    customer_zipcode TEXT,
    department_id INTEGER,
    department_name TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    market TEXT,
    order_city TEXT,
    order_country TEXT,
    order_customer_id INTEGER,
    order_date_dateorders TIMESTAMP,
    order_id INTEGER,
    order_item_cardprod_id INTEGER,
    order_item_discount NUMERIC,
    order_item_discount_rate NUMERIC,
    order_item_id INTEGER,
    order_item_product_price NUMERIC,
    order_item_profit_ratio NUMERIC,
    order_item_quantity INTEGER,
    sales NUMERIC,
    order_item_total NUMERIC,
    order_profit_per_order NUMERIC,
    order_region TEXT,
    order_state TEXT,
    order_status TEXT,
    order_zipcode TEXT,
    product_card_id INTEGER,
    product_category_id INTEGER,
    product_description TEXT,
    product_image TEXT,
    product_name TEXT,
    product_price NUMERIC,
    product_status INTEGER,
    shipping_date_dateorders TIMESTAMP,
    shipping_mode TEXT
);

SELECT *
FROM staging_dataco;

_____________________________________________________________________________________________
---CREATE NORMALIZED TABLES---

-- Customers Table
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    segment TEXT,
    street TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    zipcode TEXT,
    latitude NUMERIC,
    longitude NUMERIC
);

-- Products Table
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT,
    category_id INTEGER,
    category_name TEXT,
    department_id INTEGER,
    department_name TEXT,
    product_price NUMERIC,
    product_description TEXT,
    product_status INTEGER
);

-- Orders Table
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    order_date TIMESTAMP,
    order_status TEXT,
    order_city TEXT,
    order_state TEXT,
    order_country TEXT,
    order_region TEXT,
    market TEXT
);

-- Shipments Table
CREATE TABLE shipments (
    shipment_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    shipping_date TIMESTAMP,
    shipping_mode TEXT,
    days_for_shipping_real INTEGER,
    days_for_shipment_scheduled INTEGER,
    delivery_status TEXT,
    late_delivery_risk INTEGER
);

-- Order Items Table
CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER,
    discount NUMERIC,
    discount_rate NUMERIC,
    product_price NUMERIC,
    sales NUMERIC,
    profit_ratio NUMERIC,
    total NUMERIC,
    benefit_per_order NUMERIC
);


________________________________________________________________________________________________
---POPULATE NORMALIZED TABLES---

-- Insert Customers (distinct only)
INSERT INTO customers
SELECT DISTINCT
    customer_id,
    customer_fname,
    customer_lname,
    customer_email,
    customer_segment,
    customer_street,
    customer_city,
    customer_state,
    customer_country,
    customer_zipcode,
    latitude,
    longitude
FROM staging_dataco
WHERE customer_id IS NOT NULL;

-- Insert Products (distinct only)
INSERT INTO products
SELECT DISTINCT
    product_card_id,
    product_name,
    product_category_id,
    category_name,
    department_id,
    department_name,
    product_price,
    product_description,
    product_status
FROM staging_dataco
WHERE product_card_id IS NOT NULL;


-- Insert Orders (distinct only)
INSERT INTO orders
SELECT DISTINCT
    order_id,
    order_customer_id,
    order_date_dateorders,
    order_status,
    order_city,
    order_state,
    order_country,
    order_region,
    market
FROM staging_dataco
WHERE order_id IS NOT NULL;

-- Insert Shipments
INSERT INTO shipments (order_id, shipping_date, shipping_mode, 
                       days_for_shipping_real, days_for_shipment_scheduled, 
                       delivery_status, late_delivery_risk)
SELECT DISTINCT ON (order_id)
    order_id,
    shipping_date_dateorders,
    shipping_mode,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    delivery_status,
    late_delivery_risk
FROM staging_dataco
WHERE order_id IS NOT NULL;


-- Insert Order Items
INSERT INTO order_items
SELECT
    order_item_id,
    order_id,
    order_item_cardprod_id,
    order_item_quantity,
    order_item_discount,
    order_item_discount_rate,
    order_item_product_price,
    sales,
    order_item_profit_ratio,
    order_item_total,
    benefit_per_order
FROM staging_dataco
WHERE order_item_id IS NOT NULL;

________________________________________________________________________________________

--Create Index
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_shipments_order ON shipments(order_id);
CREATE INDEX idx_shipments_status ON shipments(delivery_status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category_name);



SELECT 'Customers' as table_name, COUNT(*) as record_count FROM customers
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Shipments', COUNT(*) FROM shipments
UNION ALL
SELECT 'Order Items', COUNT(*) FROM order_items;

-- Sample data verification
SELECT 
    o.order_id,
    c.first_name || ' ' || c.last_name as customer_name,
    p.product_name,
    oi.quantity,
    s.shipping_mode,
    s.delivery_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN shipments s ON o.order_id = s.order_id
LIMIT 10;

_______________________________________________________________________________________

-- ============================================
-- PART 2: ANALYSIS QUERIES
-- ============================================


-- 1. DELIVERY PERFORMANCE ANALYSIS

-- Overall delivery performance metrics
SELECT 
    COUNT(*) as total_shipments,
    SUM(CASE WHEN delivery_status = 'Shipping on time' THEN 1 ELSE 0 END) as on_time_deliveries,
    SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) as late_deliveries,
    ROUND(100.0 * SUM(CASE WHEN delivery_status = 'Shipping on time' THEN 1 ELSE 0 END) / COUNT(*), 2) as on_time_percentage,
    ROUND(AVG(days_for_shipping_real), 2) as avg_actual_days,
    ROUND(AVG(days_for_shipment_scheduled), 2) as avg_scheduled_days,
    ROUND(AVG(days_for_shipping_real - days_for_shipment_scheduled), 2) as avg_delay_days
FROM shipments;

-- Delivery performance by shipping mode
SELECT 
    shipping_mode,
    COUNT(*) as total_shipments,
    ROUND(100.0 * SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) / COUNT(*), 2) as late_delivery_rate,
    ROUND(AVG(days_for_shipping_real), 2) as avg_delivery_days,
    ROUND(AVG(days_for_shipping_real - days_for_shipment_scheduled), 2) as avg_delay,
    MIN(days_for_shipping_real) as min_delivery_days,
    MAX(days_for_shipping_real) as max_delivery_days
FROM shipments
GROUP BY shipping_mode
ORDER BY late_delivery_rate DESC;

-- Most unreliable shipping modes (highest variance)
SELECT 
    shipping_mode,
    COUNT(*) as shipment_count,
    ROUND(AVG(days_for_shipping_real), 2) as avg_days,
    ROUND(STDDEV(days_for_shipping_real), 2) as stddev_days,
    ROUND(STDDEV(days_for_shipping_real) / NULLIF(AVG(days_for_shipping_real), 0), 3) as coefficient_of_variation
FROM shipments
GROUP BY shipping_mode
HAVING COUNT(*) > 100
ORDER BY coefficient_of_variation DESC;


-- 2. TEMPORAL ANALYSIS

-- Monthly order trends and performance
SELECT 
    DATE_TRUNC('month', o.order_date) as month,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    ROUND(SUM(oi.sales), 2) as total_sales,
    ROUND(AVG(oi.sales), 2) as avg_order_value,
    ROUND(100.0 * SUM(CASE WHEN s.delivery_status = 'Late delivery' THEN 1 ELSE 0 END) / COUNT(*), 2) as late_delivery_rate
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN shipments s ON o.order_id = s.order_id
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

-- Day of week analysis
SELECT 
    TO_CHAR(order_date, 'Day') as day_of_week,
    EXTRACT(DOW FROM order_date) as day_number,
    COUNT(*) as order_count,
    ROUND(AVG(days_for_shipping_real), 2) as avg_delivery_days,
    ROUND(100.0 * SUM(CASE WHEN s.delivery_status = 'Late delivery' THEN 1 ELSE 0 END) / COUNT(*), 2) as late_rate
FROM orders o
JOIN shipments s ON o.order_id = s.order_id
GROUP BY TO_CHAR(order_date, 'Day'), EXTRACT(DOW FROM order_date)
ORDER BY day_number;

-- Order processing time analysis
SELECT 
    DATE_TRUNC('month', o.order_date) as month,
    COUNT(*) as orders,
    ROUND(AVG(EXTRACT(EPOCH FROM (s.shipping_date - o.order_date)) / 86400), 2) as avg_processing_days,
    ROUND(MIN(EXTRACT(EPOCH FROM (s.shipping_date - o.order_date)) / 86400), 2) as min_processing_days,
    ROUND(MAX(EXTRACT(EPOCH FROM (s.shipping_date - o.order_date)) / 86400), 2) as max_processing_days
FROM orders o
JOIN shipments s ON o.order_id = s.order_id
WHERE s.shipping_date > o.order_date
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;


-- 3. PRODUCT PERFORMANCE ANALYSIS

-- Top performing products by revenue
SELECT 
    p.product_name,
    p.category_name,
    COUNT(DISTINCT oi.order_id) as times_ordered,
    SUM(oi.quantity) as total_units_sold,
    ROUND(SUM(oi.sales), 2) as total_revenue,
    ROUND(AVG(oi.profit_ratio), 4) as avg_profit_ratio,
    ROUND(SUM(oi.sales * oi.profit_ratio), 2) as total_profit
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category_name
ORDER BY total_revenue DESC
LIMIT 20;


-- Category performance analysis
SELECT 
    p.category_name,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT oi.order_id) as order_count,
    SUM(oi.quantity) as total_units,
    ROUND(SUM(oi.sales), 2) as total_sales,
    ROUND(AVG(oi.profit_ratio), 4) as avg_profit_margin,
    ROUND(100.0 * SUM(CASE WHEN s.delivery_status = 'Late delivery' THEN 1 ELSE 0 END) / COUNT(*), 2) as late_delivery_rate
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN shipments s ON oi.order_id = s.order_id
GROUP BY p.category_name
ORDER BY total_sales DESC;

-- Products with highest late delivery risk
SELECT 
    p.product_name,
    p.category_name,
    COUNT(*) as order_count,
    ROUND(100.0 * SUM(CASE WHEN s.late_delivery_risk = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) as risk_percentage,
    ROUND(AVG(s.days_for_shipping_real), 2) as avg_delivery_days,
    ROUND(SUM(oi.sales), 2) as total_sales
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN shipments s ON oi.order_id = s.order_id
GROUP BY p.product_id, p.product_name, p.category_name
HAVING COUNT(*) >= 50
ORDER BY risk_percentage DESC
LIMIT 15;



-- 4. CUSTOMER SEGMENTATION ANALYSIS

-- Customer segment performance
SELECT 
    c.segment,
    COUNT(DISTINCT c.customer_id) as customer_count,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(AVG(oi.sales), 2) as avg_order_value,
    ROUND(SUM(oi.sales), 2) as total_revenue,
    ROUND(SUM(oi.sales) / COUNT(DISTINCT c.customer_id), 2) as revenue_per_customer,
    ROUND(100.0 * SUM(CASE WHEN s.delivery_status = 'Late delivery' THEN 1 ELSE 0 END) / COUNT(*), 2) as late_delivery_rate
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN shipments s ON o.order_id = s.order_id
GROUP BY c.segment
ORDER BY total_revenue DESC;

-- Top customers by revenue
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    c.segment,
    c.city,
    c.country,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(oi.sales), 2) as total_spent,
    ROUND(AVG(oi.sales), 2) as avg_order_value,
    MAX(o.order_date) as last_order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.segment, c.city, c.country
ORDER BY total_spent DESC
LIMIT 20;

-- Customer retention analysis
WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) as order_count,
        MIN(order_date) as first_order,
        MAX(order_date) as last_order
    FROM orders
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One-time'
        WHEN order_count BETWEEN 2 AND 5 THEN 'Occasional (2-5)'
        WHEN order_count BETWEEN 6 AND 10 THEN 'Regular (6-10)'
        ELSE 'Frequent (11+)'
    END as customer_type,
    COUNT(*) as customer_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as percentage
FROM customer_orders
GROUP BY 
    CASE 
        WHEN order_count = 1 THEN 'One-time'
        WHEN order_count BETWEEN 2 AND 5 THEN 'Occasional (2-5)'
        WHEN order_count BETWEEN 6 AND 10 THEN 'Regular (6-10)'
        ELSE 'Frequent (11+)'
    END
ORDER BY MIN(order_count);


-- 5. GEOGRAPHIC ANALYSIS

-- Performance by country
SELECT 
    o.order_country,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    ROUND(SUM(oi.sales), 2) as total_sales,
    ROUND(AVG(oi.sales), 2) as avg_order_value,
    ROUND(AVG(s.days_for_shipping_real), 2) as avg_delivery_days,
    ROUND(100.0 * SUM(CASE WHEN s.delivery_status = 'Late delivery' THEN 1 ELSE 0 END) / COUNT(*), 2) as late_delivery_rate
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN shipments s ON o.order_id = s.order_id
GROUP BY o.order_country
ORDER BY total_sales DESC;

-- Regional analysis
SELECT 
    o.order_region,
    COUNT(DISTINCT o.order_id) as orders,
    ROUND(SUM(oi.sales), 2) as revenue,
    ROUND(AVG(s.days_for_shipping_real), 2) as avg_delivery_days,
    ROUND(100.0 * SUM(CASE WHEN s.delivery_status = 'Late delivery' THEN 1 ELSE 0 END) / COUNT(*), 2) as late_rate,
    STRING_AGG(DISTINCT s.shipping_mode, ', ' ORDER BY s.shipping_mode) as shipping_modes_used
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN shipments s ON o.order_id = s.order_id
GROUP BY o.order_region
ORDER BY revenue DESC;


-- 6. ADVANCED WINDOW FUNCTIONS

-- Running total of sales by month
SELECT 
    DATE_TRUNC('month', o.order_date) as month,
    ROUND(SUM(oi.sales), 2) as monthly_sales,
    ROUND(SUM(SUM(oi.sales)) OVER (ORDER BY DATE_TRUNC('month', o.order_date)), 2) as cumulative_sales,
    ROUND(AVG(SUM(oi.sales)) OVER (ORDER BY DATE_TRUNC('month', o.order_date) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) as three_month_moving_avg
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

-- Rank products by sales within each category
WITH product_sales AS (
    SELECT 
        p.category_name,
        p.product_name,
        ROUND(SUM(oi.sales), 2) as total_sales,
        COUNT(*) as order_count
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.category_name, p.product_name
)
SELECT 
    category_name,
    product_name,
    total_sales,
    order_count,
    RANK() OVER (PARTITION BY category_name ORDER BY total_sales DESC) as sales_rank,
    ROUND(100.0 * total_sales / SUM(total_sales) OVER (PARTITION BY category_name), 2) as pct_of_category_sales
FROM product_sales
WHERE RANK() OVER (PARTITION BY category_name ORDER BY total_sales DESC) <= 5
ORDER BY category_name, sales_rank;

-- Customer purchase patterns with LAG/LEAD
WITH customer_timeline AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name as customer_name,
        o.order_date,
        oi.sales,
        LAG(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) as previous_order_date,
        LEAD(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) as next_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
)
SELECT 
    customer_id,
    customer_name,
    order_date,
    ROUND(sales, 2) as order_value,
    EXTRACT(DAY FROM (order_date - previous_order_date)) as days_since_last_order,
    EXTRACT(DAY FROM (next_order_date - order_date)) as days_until_next_order
FROM customer_timeline
WHERE previous_order_date IS NOT NULL
ORDER BY customer_id, order_date
LIMIT 50;



-- 7. PROFITABILITY ANALYSIS

-- Profit analysis by product and category
SELECT 
    p.category_name,
    COUNT(DISTINCT p.product_id) as products_in_category,
    ROUND(SUM(oi.sales), 2) as total_revenue,
    ROUND(SUM(oi.sales * oi.profit_ratio), 2) as total_profit,
    ROUND(AVG(oi.profit_ratio) * 100, 2) as avg_profit_margin_pct,
    ROUND(SUM(oi.sales * oi.profit_ratio) / NULLIF(SUM(oi.sales), 0) * 100, 2) as actual_profit_margin_pct
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category_name
ORDER BY total_profit DESC;

-- Impact of discounts on profitability
SELECT 
    CASE 
        WHEN discount_rate = 0 THEN 'No Discount'
        WHEN discount_rate <= 0.1 THEN '1-10%'
        WHEN discount_rate <= 0.2 THEN '11-20%'
        WHEN discount_rate <= 0.3 THEN '21-30%'
        ELSE '31%+'
    END as discount_tier,
    COUNT(*) as order_count,
    ROUND(AVG(sales), 2) as avg_order_value,
    ROUND(AVG(profit_ratio) * 100, 2) as avg_profit_margin,
    ROUND(SUM(sales), 2) as total_revenue,
    ROUND(SUM(sales * profit_ratio), 2) as total_profit
FROM order_items
GROUP BY 
    CASE 
        WHEN discount_rate = 0 THEN 'No Discount'
        WHEN discount_rate <= 0.1 THEN '1-10%'
        WHEN discount_rate <= 0.2 THEN '11-20%'
        WHEN discount_rate <= 0.3 THEN '21-30%'
        ELSE '31%+'
    END
ORDER BY MIN(discount_rate);


-- 8. PROBLEM IDENTIFICATION

-- Orders with significant delays
SELECT 
    o.order_id,
    o.order_date,
    s.shipping_date,
    s.shipping_mode,
    s.days_for_shipment_scheduled as scheduled_days,
    s.days_for_shipping_real as actual_days,
    s.days_for_shipping_real - s.days_for_shipment_scheduled as delay_days,
    s.delivery_status,
    ROUND(oi.sales, 2) as order_value,
    c.segment as customer_segment
FROM orders o
JOIN shipments s ON o.order_id = s.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE s.days_for_shipping_real - s.days_for_shipment_scheduled > 5
ORDER BY delay_days DESC
LIMIT 50;

-- High-value customers with late deliveries
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    c.segment,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(CASE WHEN s.delivery_status = 'Late delivery' THEN 1 ELSE 0 END) as late_deliveries,
    ROUND(100.0 * SUM(CASE WHEN s.delivery_status = 'Late delivery' THEN 1 ELSE 0 END) / COUNT(*), 2) as late_rate,
    ROUND(SUM(oi.sales), 2) as total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN shipments s ON o.order_id = s.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.segment
HAVING SUM(oi.sales) > 1000 AND SUM(CASE WHEN s.delivery_status = 'Late delivery' THEN 1 ELSE 0 END) > 0
ORDER BY total_spent DESC;
