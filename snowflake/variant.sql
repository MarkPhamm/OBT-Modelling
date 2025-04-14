CREATE SCHEMA VARIANT_SCHEMA;
USE VARIANT_SCHEMA;

CREATE OR REPLACE TABLE customer_data (
    id INT,
    info VARIANT
);
INSERT INTO customer_data (id, info)
VALUES 
  (1, PARSE_JSON('{"name": "Alice", "age": 30, "address": {"city": "Dallas", "zip": "75201"}}')),
  (2, PARSE_JSON('{"name": "Bob", "age": 25, "address": {"city": "Austin", "zip": "73301"}}')),
  (3, PARSE_JSON('{"name": "Charlie", "age": 35, "address": {"city": "Houston", "zip": "77001"}}'));

