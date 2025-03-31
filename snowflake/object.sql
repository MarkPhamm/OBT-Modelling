USE OBT_MODELLING;
CREATE SCHEMA OBJECT_SCHEMA

DROP TABLE IF EXISTS customer;
CREATE TABLE customer(
    id INT,
    info OBJECT
);

INSERT INTO customer (id, info)
SELECT 1, OBJECT_CONSTRUCT('name', 'Minh', 'age', 25, 'city', ARRAY_CONSTRUCT('NYC', 'SF', 'BOS')) UNION ALL
SELECT 2, OBJECT_CONSTRUCT('name', 'Alice', 'age', 30, 'city', ARRAY_CONSTRUCT('LA', 'CHI', 'SEA')) UNION ALL
SELECT 3, OBJECT_CONSTRUCT('name', 'Bob', 'age', 28, 'city', ARRAY_CONSTRUCT('MIA', 'DAL', 'DEN')) UNION ALL
SELECT 4, OBJECT_CONSTRUCT('name', 'Emma', 'age', 26, 'city', ARRAY_CONSTRUCT('AUS', 'ATL', 'PHX')) UNION ALL
SELECT 5, OBJECT_CONSTRUCT('name', 'Liam', 'age', 32, 'city', ARRAY_CONSTRUCT('DC', 'LV', 'SD'));