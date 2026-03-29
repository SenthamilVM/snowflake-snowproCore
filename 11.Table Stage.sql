-- Table Stage; Will be auto created

--Use DB and schema
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

--Use role and warehouse
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

--Create CUSTOMERS_TABLE table
CREATE TABLE CUSTOMERS_TABLE 
(
CUSTOMER INT NOT NULL,
FIRST_NAME VARCHAR(25) NOT NULL,
LAST_NAME VARCHAR(25) NOT NULL,
"REGION" VARCHAR(15) NOT NULL, --REGION IS A KEY WORD. Hence used ""
EMAIL VARCHAR(50) NOT NULL,
GENDER VARCHAR(10) NOT NULL,
"ORDER" INT NOT NULL --ORDER IS A KEY WORD. Hence used ""
);

/*
-- The following has to be executed in SNOWFLAKE CLI

-- Login to snowsql in snowflake CLI
-- snowsql -a [Account Identifier] -u [User Name]

--Use DB and schema
-- USE DATABASE LA_DB;
-- USE SCHEMA LA_SCHEMA;

-- --Use role and warehouse
-- USE ROLE ACCOUNTADMIN;
-- USE WAREHOUSE COMPUTE_WH;

-- to list files in user stage
list @%Customers_table;

-- Use <folder path> without spaces to avoid errors

put file://<folder path>\MOCK.csv @%/customers_table/staged AUTO_COMPRESS = FALSE;

PUT FILE://<folder path>\MOCK1.csv
@%/CUSTOMERS_TABLE/STAGED AUTO_COMPRESS = FALSE;

PUT FILE://<folder path>\MOCK1.csv
@%/CUSTOMERS_TABLE/STAGED AUTO_COMPRESS = FALSE OVERWRITE = TRUE;

COPY INTO CUSTOMERS_TABLE
FROM @%CUSTOMERS_TABLE/STAGED
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1) PURGE = TRUE;

*/