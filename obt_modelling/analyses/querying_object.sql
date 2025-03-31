
SELECT
    id, 
    info:name name,
    info:age age,
    value,
FROM customer,
LATERAL FLATTEN (input => info:city);

SELECT OBJECT_CONSTRUCT('a', 1, 'b', 'BBBB', 'c', NULL);

SELECT OBJECT_CONSTRUCT_KEEP_NULL('a', 1, 'b', 'BBBB', 'c', NULL);

SELECT {};

SELECT {'name':'minh', 'age': 22};

SET my_variable = 10;
SELECT {'key1': $my_variable+1, 'key2': $my_variable+2};

SELECT {*} FROM customer