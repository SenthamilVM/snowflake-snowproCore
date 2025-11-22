
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

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

-- The following has to be executed using snowsql

-- to list files in user stage
list @~;

PUT FILE://D:\Senthamil\Learning\Snowflake SnowPro Core Certification\Udemy Resources\Code+and+Data+Files\data\MOCK.csv @~/CUSTOMERS_USER/staged AUTO_COMPRESS = FALSE;

PUT FILE://D:\Senthamil\Learning\Snowflake SnowPro Core Certification\Udemy Resources\Code+and+Data+Files\data\MOCK1.csv @~/CUSTOMERS_USER/staged AUTO_COMPRESS = FALSE;

PUT FILE://D:\Senthamil\Learning\Snowflake SnowPro Core Certification\Udemy Resources\Code+and+Data+Files\data\MOCK1.csv @~/CUSTOMERS_USER/staged AUTO_COMPRESS = FALSE OVERWRITE = TRUE;

COPY INTO CUSTOMERS_USER
FROM @~/CUSTOMERS_USER/STAGED
FILE FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1);

-- To remove data from stage after loading, we need to use purge = true
COPY INTO CUSTOMERS_USER
FROM @~/CUSTOMERS_USER/STAGED
FILE FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1) PURGE = TRUE;

