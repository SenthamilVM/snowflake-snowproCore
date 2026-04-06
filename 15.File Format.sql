-- file format - Defines how data is structured and interpreted during loading and unloading process.
-- creating a separate file format will help to reuse it again.

--Use DB and schema
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

--Use role and warehouse
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- creating file formats
-- We can use the file format in three places
-- 1.COPY INTO    |  2.Creating Stage  |  3.Creating Table

-- Without creating separate file format
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE
FILE_FORMAT = (TYPE = 'CSV', SKIP_HEADER = 1);

-- file format definition
CREATE OR REPLACE FILE FORMAT my_csv_ff
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null')
    EMPTY_FIELD_AS_NULL = TRUE
    COMPRESSION = NONE;

-- check data from table
SELECT * FROM CUSTOMERS_NAMED;

-- use file format
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE
FILE_FORMAT = my_csv_ff
FORCE = TRUE;


SELECT * FROM CUSTOMERS_NAMED LIMIT 10;

-- FF for JSON
CREATE OR REPLACE FILE FORMAT my_json_ff
    TYPE = JSON;

-- FF for PARQUET
CREATE OR REPLACE FILE FORMAT my_parquet_ff
    TYPE = PARQUET
    COMPRESSION = SNAPPY;

-- display file formats created
SHOW FILE FORMATS;

-- Alter file formats
ALTER FILE FORMAT IF EXISTS my_csv_ff RENAME TO my_csv_ff_new;

ALTER FILE FORMAT IF EXISTS my_csv_ff_new SET FIELD_DELIMITER = '|';

-- check if the FF is renamed
SHOW FILE FORMATS;

-- describe FF
DESCRIBE FILE FORMAT my_csv_ff_new;

-- DESC FILE FORMAT my_csv_ff_new; //can be written like this as well

-- Drop FF
DROP FILE FORMAT my_csv_ff_new;

-- Recreating my_csv_ff file format
CREATE OR REPLACE FILE FORMAT my_csv_ff
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null')
    EMPTY_FIELD_AS_NULL = TRUE
    COMPRESSION = NONE;

-- Using file formats
-- 1.in COPY INTO command
-- COPY INTO mytable
-- FROM @internal_named_stage
-- FILE_FORMAT = my_csv_ff;

-- CREATE STAGE my_int_stage
--     FILE_FORMAT = my_csv_ff;

-- CREATE TABLE my_table
--     USING TEMPLATE (
--         SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
--         WITHIN GROUP (ORDER BY ORDER_ID)
--             FROM TABLE(
--                 INFER_SCHEMA(
--                     LOCATION => '@mystage'
--                     FILE_FORMAT = 'my_csv_ff'
--                             )
--                         )
--                     );

-- Order of Precedence
/*
1. COPY INTO Statement
2. Stage Definition
3. Table Definition

Eg. Stage @my_stage has a file format as CSV.
Let's say we have a table which is supposed to handle JSON data but doesn't specifically 
state a file format at the table definition level.

If, we are running
COPY INTO my_table @my_stage,
the command will use CSV as the file format since stage precedes in the order
Likewise, COPY INTO command has the highest precedence.

Specify directly in the COPY INTO Command
COPY INTO my_table @my_stage FILE FORMAT = (TYPE = 'JSON');
*/



