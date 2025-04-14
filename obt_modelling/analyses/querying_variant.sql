-- Select nested fields
SELECT 
  id,
  info:name::STRING AS name,
  info:age::INT AS age
FROM customer_data;

-- Query nested object
SELECT 
  id,
  info:address.city::STRING AS city,
  info:address.zip::STRING AS zip_code
FROM customer_data;

-- FIlter nested fields
SELECT 
    info:address.city::string 
FROM customer_data
WHERE info:age::int > 30