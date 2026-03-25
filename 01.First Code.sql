-- Create Database and Schema
CREATE DATABASE LA_DB;

CREATE SCHEMA LA_SCHEMA;

-- Create table and insert record
CREATE OR REPLACE TABLE my_table(
id INTEGER,
name VARCHAR(50),
email VARCHAR(50)
);

-- Inserting records to the table my_table
-- This needs the compute resource (Warehouse)
-- VW (COMPUTE_WH) will be activate automatically

INSERT INTO my_table(id, name, email) VALUES
(1, 'John Smith', 'john@example.com'),
(1, 'Amith', 'amit@example.com'),
(3, 'Bob Johnson', 'bob@example.com');

-- Check table
SELECT * FROM my_table;

-- Describe the table to see the metadata attached to it
DESCRIBE TABLE MY_TABLE;

-- to show all the DBs
SHOW DATABASES;

-- Describe db to see the metadata attached to it
DESCRIBE DATABASE LA_DB;

/* ----------------------------------------------------------------------------------------------------------- */

--******Constraints enforced by snowflake******
--Except NOT NULL snoflake doesn't enforce most of the constraints. In other words, snowflake only enforces NOT NULL


--1.PRIMARY KEY
CREATE OR REPLACE TABLE my_table(
id INTEGER PRIMARY KEY,         -- primary key is not enforced by snowflake eventhough it is specified as primary key
name VARCHAR(50),
email VARCHAR(50)
)

-- id "1" is duplicate here. when we run the below code, it will run without any error as snowflake doesn't enforce primary key constraint unlike other databases
-- we need handle duplicates at the application or ETL level ensuring data integrity
-- So, why even define primary key -- it is more of a guidance
-- Think of snowflake as as high-speed data warehouse that trusts you to manage data quality
INSERT INTO my_table(id, name, email) VALUES
(1, 'John Smith', 'john@example.com'),
(1, 'Amith', 'amit@example.com'),
(3, 'Bob Johnson', 'bob@example.com');

SELECT * FROM my_table; -- checking if id "1" is inserted

--2.NOT NULL - snowflake enforces not null
CREATE OR REPLACE TABLE my_table(
id INT,
name VARCHAR(50) NOT NULL,
email VARCHAR(50)
);

--The below code will throw an error because snowflake enforces not null

INSERT INTO LA_DB.LA_SCHEMA.MY_TABLE (id, name, email) VALUES
(1, 'John Smith', 'john@example.com'),
(2, NULL, 'amit@example.com'),
(3, 'Bob Johnson', 'bob@example.com');

-- Error: DML operation to table MY_TABLE failed on column NAME with error: NULL result in a non-nullable column

/* ----------------------------------------------------------------------------------------------------------- */

/* 
   QUOTING CHEAT SHEET (Snowflake & Standard SQL)
   --------------------------------------------------
   'SINGLE QUOTES' = DATA (Strings/Literals)
    - Use for: 'John', '2023-01-01', 'Active'
    - Think: "Single piece of info"

   "DOUBLE QUOTES" = NAMES (Identifiers/Columns/Tables)
    - Use for: "First Name", "Table With Spaces", "lowercase_name"
    - Rule: Use only if name has spaces or you want case-sensitivity.
    - Think: "Double-sided container for data"

   SQL SERVER NOTE: Use [Square Brackets] for names instead of "Doubles".
*/
