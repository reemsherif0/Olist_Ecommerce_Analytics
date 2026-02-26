--1
select top (100)* 
from olist_customers
--2
select top (100)* 
from olist_geolocation
--3
select top (100)* 
from olist_order_items
--4
select top (100)* 
from olist_order_payments
--5
select top (100)* 
from olist_order_reviews
--6
select top (100)* 
from olist_orders
--7
select top (100)* 
from olist_products
--8
select top (100)* 
from olist_sellers
--9
select top (100)* 
from product_category_name_translation

--
CREATE SCHEMA clean
GO

--1
---------------------------------------
-- =============================================
-- VIEW: vw_customers
-- PURPOSE: Clean and standardize customer data
-- DETAILS:
-- 1. Trim spaces from all ID fields.
-- 2. Ensure ZIP codes are 5 characters, padded with zeros if needed.
-- 3. Replace empty city/state values with 'Unknown'.
-- =============================================
CREATE VIEW vw_customers AS  
SELECT  
    TRIM(CAST(customer_id AS VARCHAR(50))) AS customer_id,  
    TRIM(CAST(customer_unique_id AS VARCHAR(50))) AS customer_unique_id,  
    RIGHT('00000' + TRIM(ISNULL(CAST(customer_zip_code_prefix AS VARCHAR(10)), '')), 5) AS customer_zip_code_prefix_clean,  
    ISNULL(NULLIF(TRIM(customer_city), ''), 'Unknown') AS customer_city,  
    ISNULL(NULLIF(TRIM(customer_state), ''), 'Unknown') AS customer_state  
FROM olist_customers;  
GO

--2    
-- =============================================
-- VIEW: vw_geolocation
-- PURPOSE: Clean and convert geolocation data for analysis
-- DETAILS:
-- 1. Replace null ZIP codes with 0.
-- 2. Convert latitude and longitude to FLOAT.
-- 3. Replace empty city/state with 'Unknown'.
-- =============================================
CREATE VIEW vw_geolocation AS  
SELECT  
    ISNULL(geolocation_zip_code_prefix, 0) AS geolocation_zip_code_prefix,  
    TRY_CONVERT(FLOAT, geolocation_lat) AS geolocation_lat,  
    TRY_CONVERT(FLOAT, geolocation_lng) AS geolocation_lng,  
    ISNULL(NULLIF(TRIM(geolocation_city), ''), 'Unknown') AS geolocation_city,  
    ISNULL(NULLIF(TRIM(geolocation_state), ''), 'Unknown') AS geolocation_state  
FROM olist_geolocation;  
GO

--3    
-- =============================================
-- VIEW: vw_order_items
-- PURPOSE: Clean and standardize order item details
-- DETAILS:
-- 1. Trim all string fields.
-- 2. Replace null numeric fields with 0.
-- 3. Convert shipping limit date and numeric fields to proper types.
-- =============================================
CREATE VIEW vw_order_items AS  
SELECT  
    TRIM(order_id) AS order_id,  
    ISNULL(order_item_id, 0) AS order_item_id,  
    TRIM(product_id) AS product_id,  
    TRIM(seller_id) AS seller_id,  
    TRY_CONVERT(DATE, shipping_limit_date) AS shipping_limit_date,  
    ISNULL(TRY_CONVERT(DECIMAL(10,2), price), 0) AS price,  
    ISNULL(TRY_CONVERT(DECIMAL(10,2), freight_value), 0) AS freight_value  
FROM olist_order_items;  

--4
-- =============================================
-- VIEW: vw_order_payments
-- PURPOSE: Clean and standardize order payment information
-- DETAILS:
-- 1. Trim string fields and replace empty payment_type with 'Unknown'.
-- 2. Replace null numeric fields with 0.
-- 3. Ensure payment_value is in DECIMAL format.
-- =============================================
CREATE VIEW vw_order_payments AS  
SELECT  
    TRIM(order_id) AS order_id,  
    ISNULL(payment_sequential, 0) AS payment_sequential,  
    ISNULL(NULLIF(TRIM(payment_type), ''), 'Unknown') AS payment_type,  
    ISNULL(payment_installments, 0) AS payment_installments,  
    ISNULL(TRY_CONVERT(DECIMAL(10,2), payment_value), 0) AS payment_value  
FROM olist_order_payments;  

--5
-- =============================================
-- VIEW: vw_order_reviews
-- PURPOSE: Clean and prepare order review data
-- DETAILS:
-- 1. Trim string fields and replace empty comments/titles with defaults.
-- 2. Replace null review scores with 0.
-- 3. Convert review creation and answer dates to DATE type.
-- =============================================
CREATE VIEW vw_order_reviews AS  
SELECT  
    TRIM(review_id) AS review_id,  
    TRIM(order_id) AS order_id,  
    ISNULL(review_score, 0) AS review_score,  
    ISNULL(NULLIF(TRIM(review_comment_title), ''), 'No Title') AS review_comment_title,  
    ISNULL(NULLIF(TRIM(review_comment_message), ''), 'No Comment') AS review_comment_message,  
    TRY_CONVERT(DATE, review_creation_date) AS review_creation_date,  
    TRY_CONVERT(DATE, review_answer_timestamp) AS review_answer_timestamp  
FROM olist_order_reviews;  

--6
-- =============================================
-- VIEW: vw_orders
-- PURPOSE: Clean and standardize order information
-- DETAILS:
-- 1. Trim string fields and replace empty order_status with 'Unknown'.
-- 2. Convert all order-related timestamps to DATE type.
-- =============================================
CREATE VIEW vw_orders AS  
SELECT  
    TRIM(order_id) AS order_id,  
    TRIM(customer_id) AS customer_id,  
    ISNULL(NULLIF(TRIM(order_status), ''), 'Unknown') AS order_status,  
    TRY_CONVERT(DATE, order_purchase_timestamp) AS order_purchase_timestamp,  
    TRY_CONVERT(DATE, order_approved_at) AS order_approved_at,  
    TRY_CONVERT(DATE, order_delivered_carrier_date) AS order_delivered_carrier_date,  
    TRY_CONVERT(DATE, order_delivered_customer_date) AS order_delivered_customer_date,  
    TRY_CONVERT(DATE, order_estimated_delivery_date) AS order_estimated_delivery_date  
FROM olist_orders;  

--7
-- =============================================
-- VIEW: vw_products
-- PURPOSE: Clean and standardize product data
-- DETAILS:
-- 1. Replace empty product category with 'Unknown'.
-- 2. Replace null numeric fields with 0.
-- =============================================
CREATE VIEW vw_products AS  
SELECT  
    ISNULL(NULLIF(TRIM(product_category_name), ''), 'Unknown') AS product_category_name,  
    ISNULL(product_name_lenght, 0) AS product_name_lenght,  
    ISNULL(product_description_lenght, 0) AS product_description_lenght,  
    ISNULL(product_photos_qty, 0) AS product_photos_qty,  
    ISNULL(product_weight_g, 0) AS product_weight_g,  
    ISNULL(product_length_cm, 0) AS product_length_cm,  
    ISNULL(product_height_cm, 0) AS product_height_cm,  
    ISNULL(product_width_cm, 0) AS product_width_cm  
FROM olist_products;  

--8
-- =============================================
-- VIEW: vw_sellers
-- PURPOSE: Clean and standardize seller data
-- DETAILS:
-- 1. Format ZIP codes as 5-digit strings.
-- 2. Capitalize first letter of city and set default to 'Unknown' if empty.
-- 3. Trim state field and set default to 'Unknown' if empty.
-- =============================================
CREATE VIEW vw_sellers AS  
SELECT  
    seller_id,  
    FORMAT(CAST(seller_zip_code_prefix AS INT), '00000') AS seller_zip_code_prefix,  
    ISNULL(UPPER(SUBSTRING(TRIM(seller_city),1,1)) + LOWER(SUBSTRING(TRIM(seller_city),2,LEN(TRIM(seller_city)))), 'Unknown') AS seller_city,  
    ISNULL(TRIM(seller_state), 'Unknown') AS seller_state  
FROM olist_sellers;  

--9
-- =============================================
-- VIEW: vw_category_translation
-- PURPOSE: Prepare product category translations
-- DETAILS:
-- 1. Trim both original and English category names.
-- =============================================
CREATE VIEW vw_category_translation AS  
SELECT  
    TRIM(product_category_name) AS product_category_name,  
    TRIM(product_category_name_english) AS product_category_name_english  
FROM product_category_name_translation;


