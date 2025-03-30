# One Big Table Modelling
One Big Table modeling technique utilizing complex data types in Snowflake, such as ARRAY, OBJECT, MAP, and VARIANT.

## Key Datatypes
* **VARIANT** – Stores semi-structured data like JSON, XML, or key-value pairs.
* **ARRAY** – Stores lists of values (e.g., multiple categories, tags).
* **OBJECT** – Stores nested key-value pairs, similar to a dictionary or JSON object.

## Why OBT Uses Complex Data Types?
* **Minimizes JOINs:** Instead of normalizing data into separate tables (which would require JOINs), complex types allow embedding related information within a row.

* **Efficient for certain workloads:** If a query primarily retrieves and processes nested attributes, it can be faster than joining multiple tables.

## Why Are They Hard to Query?
* **Not SQL-friendly:** Many traditional SQL tools are optimized for flat, tabular structures, making operations on nested data more complicated.
* **Limited index support:** Some databases cannot efficiently index inside STRUCTs or ARRAYS.
* **Query performance trade-offs:** Extracting, filtering, and transforming these types can be slower compared to normalized tables.

# ARRAY (Lists of Values)
An ARRAY stores multiple values of the same type within a single column.

**Example**
``` sql
CREATE TABLE orders (
    order_id INT,
    product_ids ARRAY<INT>
);

SELECT order_id, product
FROM orders, UNNEST(product_ids) AS product;
```

## Creating Array
### ARRAY_CONTRUCT_[COMPACT]

Returns an array constructed from zero, one, or more inputs. With [COMPACT], the constructed array omits any NULL input values.

```sql
ARRAY_CONSTRUCT_[COMPACT]( [ <expr1> ] [ , <expr2> [ , ... ] ] ) 
```

### ARRAY_DISTINCT

Returns a new ARRAY that contains only the distinct elements from the input ARRAY. The function excludes any duplicate elements that are present in the input ARRAY.
```sql
 ARRAY_DISTINCT( <array> ) 
 ```

### ARRAY_COMPACT

Returns a compacted array with missing and null values removed, effectively converting sparse arrays into dense arrays.
```sql
ARRAY_COMPACT( <array1> ) 
```

### ARRAY_[UNIQUE]_AGG

Returns the input values, pivoted into an array. If the input is empty, the function returns an empty array.

```sql
-- Aggregate function

ARRAY_AGG( [ DISTINCT ] <expr1> ) [ WITHIN GROUP ( <orderby_clause> ) ]
-- Window function

ARRAY_AGG( [ DISTINCT ] <expr1> )
  [ WITHIN GROUP ( <orderby_clause> ) ]
  OVER ( [ PARTITION BY <expr2> ] [ ORDER BY <expr3> [ { ASC | DESC } ] ] [ <window_frame> ])
```

## Querying Array
### FLATTEN

Flattens (explodes) compound values into multiple rows.

FLATTEN is a table function that takes a VARIANT, OBJECT, or ARRAY column and produces a lateral view (that is, an inline view that contains correlations to other tables that precede it in the FROM clause).

FLATTEN can be used to convert semi-structured data to a relational representation.

```sql 
FLATTEN( INPUT => <expr> [ , PATH => <constant_expr> ]
                         [ , OUTER => TRUE | FALSE ]
                         [ , RECURSIVE => TRUE | FALSE ]
                         [ , MODE => 'OBJECT' | 'ARRAY' | 'BOTH' ] )
```

### LATERAL 
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

### LATERAL FLATTEN
Combine LATERAL and FLATTEN to explode an array into multiple rows, allowing each element of the array to be represented as a separate row in the result set. This is particularly useful for analyzing data stored in array format, as it enables you to work with individual elements directly. 

The LATERAL keyword allows the FLATTEN function to reference columns from the preceding table, making it possible to correlate each exploded element with its corresponding row. This approach is essential when dealing with complex data structures, as it transforms nested arrays into a more manageable tabular format.

For example, if you have an orders table where each order contains an array of product IDs, using LATERAL FLATTEN will allow you to list each product ID alongside its order ID, facilitating easier analysis and reporting of product sales across different orders.

### ARRAY_CONTAINS

Returns TRUE if the specified value is found in the specified array.
```sql
ARRAY_CONTAINS( <value_expr> , <array> )
```

### ARRAY_FLATTEN
Flattens an ARRAY of ARRAYs into a single ARRAY. The function effectively concatenates the ARRAYs that are elements of the input ARRAY and returns them as a single ARRAY.

```sql 
ARRAY_FLATTEN( <array> )
```

# STRUCT (Nested Objects)
A STRUCT is similar to a dictionary or JSON object, allowing you to group multiple related fields under a single column.

**Example**
``` sql
CREATE TABLE sales (
    order_id INT,
    customer STRUCT<first_name STRING, last_name STRING, email STRING>
);

SELECT customer.first_name, customer.email 
FROM sales;

```

## VARIANT vs STRUCT (OBJECT in Snowflake)

VARIANT and STRUCT (or OBJECT in Snowflake) are similar but have key differences:

| Feature            | VARIANT                                                                 | STRUCT (OBJECT in Snowflake)                                      |
|--------------------|------------------------------------------------------------------------|-------------------------------------------------------------------|
| **Definition**     | A flexible data type that can store any semi-structured data (JSON, XML, Avro, etc.) | A structured data type that holds named fields, like a dictionary or key-value pair |
| **Schema Enforcement** | No strict schema; can store different structures in the same column | Has a defined schema with named fields |
| **Storage**        | Stores data in a single column as raw JSON                            | Stores data as key-value pairs within a single column             |
| **Querying**       | Requires `SELECT column_name:key` syntax to extract values            | Requires `column_name.field_name` syntax for access               |
| **Performance**    | More flexible but may need extra parsing for structured queries       | More structured, making queries more predictable                  |

Challenges:
* Harder to manipulate in traditional SQL workflows.
* Not all databases support direct filtering or indexing on nested fields efficiently.
