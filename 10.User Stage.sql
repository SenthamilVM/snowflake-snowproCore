-- User Stage; Will be auto created

--Use DB and schema
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

--Use role and warehouse
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

--Create CUSTOMERS_USER table
CREATE TABLE CUSTOMERS_USER 
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
list @~;


-- Use <folder path> without spaces to avoid errors
-- Loading Mock.csv into user stage
put file://<folder path>\MOCK.csv @~/customers_user/staged AUTO_COMPRESS = FALSE;

-- Loading Mock1.csv into user stage
PUT FILE://<folder path>\MOCK1.csv @~/CUSTOMERS_USER/staged AUTO_COMPRESS = FALSE;


PUT FILE://<folder path>\MOCK1.csv @~/CUSTOMERS_USER/staged AUTO_COMPRESS = FALSE OVERWRITE = TRUE;

COPY INTO CUSTOMERS_USER
FROM @~/CUSTOMERS_USER/STAGED
FILE FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1);

-- To remove data from stage after loading, we need to use purge = true
COPY INTO CUSTOMERS_USER
FROM @~/CUSTOMERS_USER/STAGED
FILE FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1) PURGE = TRUE;

*/