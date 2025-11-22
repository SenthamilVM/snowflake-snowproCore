USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

--Create CUSTOMERS table
CREATE TABLE CUSTOMERS 
(
CUSTOMER INT NOT NULL,
FIRST_NAME VARCHAR(25) NOT NULL,
LAST_NAME VARCHAR(25) NOT NULL,
"REGION" VARCHAR(15) NOT NULL, --REGION IS A KEY WORD. Hence used ""
EMAIL VARCHAR(50) NOT NULL,
GENDER VARCHAR(10) NOT NULL,
"ORDER" INT NOT NULL --ORDER IS A KEY WORD. Hence used ""
);

SELECT COUNT(*) FROM CUSTOMERS;

-- If we try to load Mock.csv (which is already loaded from stage to table) again to CUSTOMERS table from stage, it will load 0 rows.
/*MOCK.csv
LA_DB.LA_SCHEMA.CUSTOMERS
0 of 0 rows were successfully inserted into the table.
File was loaded before.
*/
--Because stage keeps tracks of the data till 64 days.

--The below statement will prove this
COPY INTO "LA_DB"."LA_SCHEMA"."CUSTOMERS"
FROM '@"LA_DB"."LA_SCHEMA"."CUST_STAGE"/MOCK.csv'
-- (
--     SELECT $1, $2, $3, $4, $5, $6, $7
--     FROM '@"LA_DB"."LA_SCHEMA"."CUST_STAGE"'
-- )
-- FILES = ('MOCK.csv')
FILE_FORMAT = (
    TYPE=CSV,
    SKIP_HEADER=1,
    FIELD_DELIMITER=',',
    TRIM_SPACE=TRUE,
    FIELD_OPTIONALLY_ENCLOSED_BY='"',
    REPLACE_INVALID_CHARACTERS=TRUE,
    DATE_FORMAT=AUTO,
    TIME_FORMAT=AUTO,
    TIMESTAMP_FORMAT=AUTO
)
ON_ERROR=ABORT_STATEMENT;

-- output: Copy executed with 0 files processed.

-- To Force upload
COPY INTO "LA_DB"."LA_SCHEMA"."CUSTOMERS"
FROM '@"LA_DB"."LA_SCHEMA"."CUST_STAGE"/MOCK.csv'
-- (
--     SELECT $1, $2, $3, $4, $5, $6, $7
--     FROM '@"LA_DB"."LA_SCHEMA"."CUST_STAGE"'
-- )
-- FILES = ('MOCK.csv')
FILE_FORMAT = (
    TYPE=CSV,
    SKIP_HEADER=1,
    FIELD_DELIMITER=',',
    TRIM_SPACE=TRUE,
    FIELD_OPTIONALLY_ENCLOSED_BY='"',
    REPLACE_INVALID_CHARACTERS=TRUE,
    DATE_FORMAT=AUTO,
    TIME_FORMAT=AUTO,
    TIMESTAMP_FORMAT=AUTO
)
ON_ERROR=ABORT_STATEMENT
FORCE = TRUE;

--Now 1000 rows from Mock.csv have been added.
SELECT COUNT(*) FROM CUSTOMERS;
