--Reference https://docs.snowflake.com/en/user-guide/data-load-transform

--Use DB and schema
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

--Use role and warehouse
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

list @internal_named_stage;

-- Select columns from stage
SELECT t.$1, t.$2, t.$4 FROM @internal_named_stage/data_0_0_0.csv t;

SELECT t.$1, CONCAT(t.$2, ' ', t.$3), t.$4, t.$7 FROM @internal_named_stage/data_0_0_0.csv t;


-- Create new table
CREATE OR REPLACE TABLE new_table2(
CUSTOMER VARCHAR,
FULL_NAME VARCHAR,
REGION VARCHAR,
EMAIL VARCHAR,
GENDER VARCHAR,
"ORDER" INTEGER
);

-- load only for selected columns and reorder
COPY INTO new_table2 (CUSTOMER, FULL_NAME, REGION, GENDER, EMAIL) --reordering columns
FROM (SELECT t.$1, CONCAT(t.$2, ' ', t.$3), t.$4, t.$6, t.$5 FROM @internal_named_stage/data_0_0_0.csv t)
FILE_FORMAT =
(
TYPE = 'CSV'
SKIP_HEADER = 1
);
-- Use it when you load the data once again to force load duplicate data into the same table as it will store metadata for 64 days
-- FORCE = TRUE;

-- Check the loaded data in new_table2
SELECT * FROM NEW_TABLE2;

-- TRUNCATE NEW_TABLE2;

-- either truncate or create or replace table with decimal column
CREATE OR REPLACE TABLE new_table2(
CUSTOMER VARCHAR,
FULL_NAME VARCHAR,
REGION VARCHAR,
EMAIL VARCHAR,
GENDER VARCHAR,
"ORDER" DECIMAL(15,3),
EXTRA_COL BINARY
);

-- load only for column casting to decimal, converting to binary
COPY INTO NEW_TABLE2 (CUSTOMER, FULL_NAME, REGION, EMAIL, GENDER, "ORDER", EXTRA_COL)
FROM (
SELECT t.$1, CONCAT(t.$2, ' ', t.$3), t.$4, t.$5, t.$6, CAST(t.$7 AS INTEGER), to_binary(t.$4, 'utf-8')
FROM @internal_named_stage/data_0_0_0.csv t
)
FILE_FORMAT =
(
TYPE = 'CSV'
SKIP_HEADER = 1
);
-- FORCE = TRUE;

-- Check the loaded data in new_table2
SELECT * FROM NEW_TABLE2;


-- load only for auto increment
CREATE OR REPLACE TABLE new_table2(
INDEX NUMBER AUTOINCREMENT START 2 INCREMENT 10,
CUSTOMER VARCHAR,
FULL_NAME VARCHAR,
REGION VARCHAR,
EMAIL VARCHAR,
GENDER VARCHAR,
"ORDER" DECIMAL(15,3),
EXTRA_COL BINARY
);

COPY INTO NEW_TABLE2 (CUSTOMER, FULL_NAME, REGION, EMAIL, GENDER, "ORDER", EXTRA_COL)
FROM (
SELECT t.$1, CONCAT(t.$2, ' ', t.$3), t.$4, t.$5, t.$6, CAST(t.$7 AS INTEGER), to_binary(t.$4, 'utf-8')
FROM @internal_named_stage/data_0_0_0.csv t
)
FILE_FORMAT =
(
TYPE = 'CSV'
SKIP_HEADER = 1
);
-- FORCE = TRUE;

-- Check the loaded data in new_table2
SELECT * FROM NEW_TABLE2;   //Index column has been added



-- load only for auto increment starting from 1, increment 1
CREATE OR REPLACE TABLE new_table2(
INDEX NUMBER AUTOINCREMENT START 1 INCREMENT 1,
CUSTOMER VARCHAR,
FULL_NAME VARCHAR (8),  // restricting fullname length to 8 characters
REGION VARCHAR,
EMAIL VARCHAR,
GENDER VARCHAR,
"ORDER" DECIMAL(15,3),
EXTRA_COL BINARY
);

-- truncating text strings that exceed the target column length
COPY INTO NEW_TABLE2 (CUSTOMER, FULL_NAME, REGION, EMAIL, GENDER, "ORDER", EXTRA_COL)
FROM (
SELECT t.$1, CONCAT(t.$2, ' ', t.$3), t.$4, t.$5, t.$6, CAST(t.$7 AS INTEGER), to_binary(t.$4, 'utf-8')
FROM @internal_named_stage/data_0_0_0.csv t
)
FILE_FORMAT =
(
TYPE = 'CSV'
SKIP_HEADER = 1
)
TRUNCATECOLUMNS = TRUE; //By default, it will be FALSE. It will through an error if the len is more than 8 for FULL_NAME (VARCHAR(8))
-- FORCE = TRUE;


-- Check the loaded data in new_table2
SELECT * FROM NEW_TABLE2;   //Here, Full_name will be truncated only to 8 characters





