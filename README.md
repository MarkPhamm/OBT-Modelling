# 1. One Big Table Modelling
One Big Table modeling technique utilizing complex data types in Snowflake, such as ARRAY, OBJECT, MAP, and VARIANT.

## 1.1 Key Datatypes
* **VARIANT** – Stores semi-structured data like JSON, XML, or key-value pairs.
* **ARRAY** – Stores lists of values (e.g., multiple categories, tags).
* **OBJECT** – Stores nested key-value pairs, similar to a dictionary or JSON object.

## 1.2 Why OBT Uses Complex Data Types?
* **Minimizes JOINs:** Instead of normalizing data into separate tables (which would require JOINs), complex types allow embedding related information within a row.

* **Efficient for certain workloads:** If a query primarily retrieves and processes nested attributes, it can be faster than joining multiple tables.

## 1.3 Why Are They Hard to Query?
* **Not SQL-friendly:** Many traditional SQL tools are optimized for flat, tabular structures, making operations on nested data more complicated.
* **Limited index support:** Some databases cannot efficiently index inside STRUCTs or ARRAYS.
* **Query performance trade-offs:** Extracting, filtering, and transforming these types can be slower compared to normalized tables.

---

# 2. ARRAY (Lists of Values)
A Snowflake array is similar to an array in many other programming languages. An array contains 0 or more pieces of data. Each element is accessed by specifying its position in the array. Each value in a semi-structured array is of type ```VARIANT```. A ```VARIANT``` value can contain a value of any other data type.

ARRAY constants have the following syntax:
```[<value> [, <value> , ...]]```

Where:
* ```<value>```: The value that is associated with an array element. The value can be a literal or an expression. The value can be any data type.

**Example**
``` sql
CREATE TABLE orders (
    order_id INT,
    product_ids ARRAY<INT>
);

SELECT order_id, product
FROM orders, UNNEST(product_ids) AS product;
```

## 2.1 Creating Array
### 2.1.1 ARRAY_CONTRUCT_[COMPACT]

Returns an array constructed from zero, one, or more inputs. With [COMPACT], the constructed array omits any NULL input values.

```sql
ARRAY_CONSTRUCT_[COMPACT]( [ <expr1> ] [ , <expr2> [ , ... ] ] ) 
```

### 2.1.2 ARRAY_DISTINCT

Returns a new ARRAY that contains only the distinct elements from the input ARRAY. The function excludes any duplicate elements that are present in the input ARRAY.
```sql
 ARRAY_DISTINCT( <array> ) 
 ```

### 2.1.3 ARRAY_COMPACT

Returns a compacted array with missing and null values removed, effectively converting sparse arrays into dense arrays.
```sql
ARRAY_COMPACT( <array1> ) 
```

### 2.1.4 ARRAY_[UNIQUE]_AGG

Returns the input values, pivoted into an array. If the input is empty, the function returns an empty array.

```sql
-- Aggregate function

ARRAY_AGG( [ DISTINCT ] <expr1> ) [ WITHIN GROUP ( <orderby_clause> ) ]
-- Window function

ARRAY_AGG( [ DISTINCT ] <expr1> )
  [ WITHIN GROUP ( <orderby_clause> ) ]
  OVER ( [ PARTITION BY <expr2> ] [ ORDER BY <expr3> [ { ASC | DESC } ] ] [ <window_frame> ])
```

## 2.2 Querying Array
### 2.2.1 FLATTEN

Flattens (explodes) compound values into multiple rows.

FLATTEN is a table function that takes a VARIANT, OBJECT, or ARRAY column and produces a lateral view (that is, an inline view that contains correlations to other tables that precede it in the FROM clause).

FLATTEN can be used to convert semi-structured data to a relational representation.

```sql 
FLATTEN( INPUT => <expr> [ , PATH => <constant_expr> ]
                         [ , OUTER => TRUE | FALSE ]
                         [ , RECURSIVE => TRUE | FALSE ]
                         [ , MODE => 'OBJECT' | 'ARRAY' | 'BOTH' ] )
```

### 2.2.2 LATERAL 
In a FROM clause, the LATERAL keyword allows an inline view to reference columns from a table expression that precedes that inline view.

A lateral join behaves more like a correlated subquery than like most joins. A lateral join behaves as if the server executed a loop similar to the following:

```
for each row in left_hand_table LHT:
    execute right_hand_subquery RHS using the values from the current row in the LHT
```

Unlike the output of a non-lateral join, the output from a lateral join includes only the rows generated from the inline view. The rows on the left-hand side do not need to be joined to the right hand side because the rows on the left-hand side have already been taken into account by being passed into the inline view.

```sql 
SELECT ...
FROM <left_hand_table_expression>, LATERAL ( <inline_view> )
...
```

### 2.2.3 LATERAL FLATTEN
Combine LATERAL and FLATTEN to explode an array into multiple rows, allowing each element of the array to be represented as a separate row in the result set. This is particularly useful for analyzing data stored in array format, as it enables you to work with individual elements directly. 

The LATERAL keyword allows the FLATTEN function to reference columns from the preceding table, making it possible to correlate each exploded element with its corresponding row. This approach is essential when dealing with complex data structures, as it transforms nested arrays into a more manageable tabular format.

For example, if you have an orders table where each order contains an array of product IDs, using LATERAL FLATTEN will allow you to list each product ID alongside its order ID, facilitating easier analysis and reporting of product sales across different orders.

### 2.2.4 ARRAY_CONTAINS

Returns TRUE if the specified value is found in the specified array.
```sql
ARRAY_CONTAINS( <value_expr> , <array> )
```

### 2.2.5 ARRAY_FLATTEN
Flattens an ARRAY of ARRAYs into a single ARRAY. The function effectively concatenates the ARRAYs that are elements of the input ARRAY and returns them as a single ARRAY.

```sql 
ARRAY_FLATTEN( <array> )
```

---

# 3. OBJECT (Key-pair value)
A Snowflake OBJECT value is analogous to a JSON “object”. In other programming languages, the corresponding data type is often called a “dictionary,” “hash,” or “map.” An OBJECT value contains key-value pairs. In Snowflake semi-structured OBJECT data, each key is a ```VARCHAR``` value, and each value is a ```VARIANT``` value.

OBJECT constants have the following syntax:
``` { [<key>: <value> [, <key>: <value> , ...]] } ```

Where: 
    
* ```<key>```: The key in a key-value pair. The key must be a string literal.
* ```<value>```: The value that is associated with the key. The value can be a literal or an expression. The value can be any data type.

**Example**
``` sqlthat
CREATE TABLE customer(
    id INT,
    info OBJECT
);

SELECT 
    id, 
    info:name,
    info:age,
    info:city
FROM customer
```

## 3.1 Creating OBJECT

### 3.1.1 OBJECT_CONSTRUCT[_KEEP_NULL]  
Returns an OBJECT constructed from the arguments.

```sql
SELECT OBJECT_CONSTRUCT('name', 'Alice', 'age', 30);
-- Output: { "name": "Alice", "age": 30 }

SELECT OBJECT_CONSTRUCT_KEEP_NULL('name', NULL, 'city', 'Dallas');
-- Output: { "name": null, "city": "Dallas" }

-- Using wildcard *
SELECT OBJECT_CONSTRUCT(*)
FROM (SELECT 1 AS id, 'Alice' AS name, 30 AS age) t;
-- Output: { "ID": 1, "NAME": "Alice", "AGE": 30 }
```



### 3.1.2 Empty bracket – `{}`  
This is an empty OBJECT value.

```sql
SELECT PARSE_JSON('{}') AS empty_obj;
-- Output: {}
```

### 3.1.3 Key-Value pair `{ 'key1': 'value1' , 'key2': 'value2' }`  
Constructs an OBJECT using literal key-value pairs.

```sql
SELECT PARSE_JSON('{ "language": "SQL", "type": "tutorial" }') AS obj;
-- Output: { "language": "SQL", "type": "tutorial" }
```

### 3.1.4 Key-Value pair with @variable `{ 'key1': c1+1 , 'key2': c1+2 }`  
Uses expressions for the values.

```sql
WITH input AS (
  SELECT 5 AS c1
)
SELECT OBJECT_CONSTRUCT('key1', c1 + 1, 'key2', c1 + 2)
FROM input;
-- Output: { "key1": 6, "key2": 7 }
```

### 3.1.5 Wildcard `*` – `{*}`  
Constructs an OBJECT from all columns in the row using column names as keys.

```sql
SELECT TO_VARIANT(OBJECT_CONSTRUCT(*)) AS full_row_obj
FROM (SELECT 101 AS id, 'Alice' AS name, 'NYC' AS city) t;
-- Output: { "ID": 101, "NAME": "Alice", "CITY": "NYC" }
```

## 3.2 Querying OBJECT

### 3.2.1 Dot Notation

Access values in an `OBJECT` using dot (`:`) notation, where each key is referenced using a colon and the key name.

```sql
SELECT 
    info:name AS name,
    info:age AS age,
    info:address:city AS city
FROM customer;
```

### 3.2.2 Bracket Notation

Alternatively, access keys using bracket notation with quoted key names.

```sql
SELECT 
    info['name'] AS name,
    info['age'] AS age,
    info['address']['zip'] AS zip_code
FROM customer;
```

### 3.2.3 FLATTEN on OBJECT

Use `FLATTEN` to explode an `OBJECT` into key-value pairs as separate rows.

```sql
SELECT 
    c.id,
    f.key,
    f.value
FROM customer c,
LATERAL FLATTEN(INPUT => c.info) f;
```

This is useful when you want to analyze or filter based on dynamic key-value structures within the `OBJECT`.

### 3.2.4 IS_OBJECT

Check whether a `VARIANT` value is an `OBJECT`.

```sql
SELECT 
    id,
    IS_OBJECT(info) AS is_object
FROM customer;
```

### 3.2.5 OBJECT_KEYS

Returns an array of all the keys in the `OBJECT`.

```sql
SELECT 
    id,
    OBJECT_KEYS(info) AS keys
FROM customer;
```

---

# 4. VARIANT (Flexible Data Types)

In Snowflake, a `VARIANT` value is a flexible data type that can hold any other Snowflake-supported type, including `ARRAY`, `OBJECT`, `BOOLEAN`, `DATE`, and more. This makes it ideal for working with semi-structured data like JSON, XML, and AVRO.

## 4.1 Creating VARIANT

To convert a value to the `VARIANT` data type, use any of the following methods:

```sql
CAST(expression AS VARIANT)
TO_VARIANT(expression)
expression::VARIANT
```
**Example**

```sql
-- Using TO_VARIANT
SELECT TO_VARIANT(123) AS variant_number,
       TO_VARIANT('hello') AS variant_string,
       TO_VARIANT(ARRAY_CONSTRUCT(1, 2, 3)) AS variant_array,
       TO_VARIANT(OBJECT_CONSTRUCT('name', 'Alice', 'age', 30)) AS variant_object;
```

## 4.2 Querying VARIANT

Once data is stored as a `VARIANT`, you can access its elements using **colon (`:`)** notation for objects and **brackets (`[]`)** for arrays.

### 4.2.1 Object-style Access
```sql
-- Assume a column named `data` contains VARIANT objects
SELECT 
    data:name AS name,
    data:age AS age
FROM my_table;
```

### 4.2.2 Array-style Access
```sql
-- Access the first element of a VARIANT array
SELECT 
    data[0] AS first_element
FROM my_table;
```

### 4.2.3 Nested Access
```sql
-- Deeply nested object access
SELECT 
    data:address:city AS city
FROM my_table;
```

## 4.3 Parsing JSON into VARIANT

You can parse JSON strings into `VARIANT` using `PARSE_JSON`.

**Example**
```sql
SELECT PARSE_JSON('{"name": "Alice", "age": 30, "address": {"city": "Dallas", "zip": "75201"}}') AS parsed_data;
```

You can then query the result:
```sql
WITH sample AS (
    SELECT PARSE_JSON('{"name": "Alice", "age": 30, "address": {"city": "Dallas", "zip": "75201"}}') AS data
)
SELECT 
    data:name AS name,
    data:address:city AS city
FROM sample;
```



## 4.4 Compare VARIANT vs OBJECT

VARIANT and OBJECT are similar but have key differences:

| Feature               | VARIANT                                                                                 | OBJECT                                                                       |
|-----------------------|------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| **Definition**         | A flexible data type that can store any semi-structured data (JSON, XML, Avro, etc.)    | A structured data type that holds named fields, like a dictionary or map     |
| **Schema Enforcement** | No strict schema; can store different structures in the same column                     | Has a more defined structure with named key-value fields                     |
| **Storage**            | Stores data in a single column as raw semi-structured JSON                              | Stores key-value pairs explicitly within a single column                     |
| **Querying**           | Use `column_name:key` or `column_name['key']` to extract values                         | Same querying syntax as VARIANT; OBJECT is a specific use-case of VARIANT    |
| **Performance**        | More flexible but may require additional parsing and transformation                     | More structured, making queries more consistent and efficient                |


Challenges:
* Harder to manipulate in traditional SQL workflows.
* Not all databases support direct filtering or indexing on nested fields efficiently.
