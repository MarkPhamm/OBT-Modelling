--  Selecting all data from a table with an array
SELECT * 
FROM OBT_MODELLING.ARRAY_SCHEMA.orders;

-- Accessing a specific element in an array (zero-based index)
SELECT 
    order_id, 
    product_ids[0] AS first_product
FROM OBT_MODELLING.ARRAY_SCHEMA.orders;

-- Flattening an array into multiple rows using LATERAL FLATTEN
SELECT order_id, value AS product_id
FROM OBT_MODELLING.ARRAY_SCHEMA.orders, 
LATERAL FLATTEN(input => product_ids);

-- Flattening an array into multiple rows using LATERAL FLATTEN
SELECT 
    order_id, 
    ARRAY_SIZE(product_ids) AS num_products
FROM OBT_MODELLING.ARRAY_SCHEMA.orders;

-- Filtering rows where an array contains a specific value
SELECT * 
FROM OBT_MODELLING.ARRAY_SCHEMA.orders
WHERE ARRAY_CONTAINS(101, product_ids);

-- Aggregating arrays using ARRAY_AGG
SELECT 
    customer_id, 
    ARRAY_AGG(order_id) AS all_orders,
    ARRAY_FLATTEN(ARRAY_UNIQUE_AGG(product_ids)) as all_products
FROM OBT_MODELLING.ARRAY_SCHEMA.orders
GROUP BY customer_id;

