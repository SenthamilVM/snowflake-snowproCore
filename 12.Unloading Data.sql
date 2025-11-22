USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

SELECT * FROM CUSTOMERS_NAMED;

SHOW STAGES;

-- Create stage
CREATE OR REPLACE STAGE INTERNAL_NAMED_STAGE1
FILE_FORMAT = 
(
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
);


-- copy data into stage from table
COPY INTO @INTERNAL_NAMED_STAGE1
FROM CUSTOMERS_NAMED
FILE_FORMAT = 
(
TYPE = 'CSV'
COMPRESSION = 'NONE'
)
-- MAX_FILE_SIZE = 60 --To split this file into multiple files. Use it if the file size is big
-- OVERWRITE = TRUE --Use this to overwrite the data
HEADER = TRUE;

list @INTERNAL_NAMED_STAGE1;

-- The following has to be executed in snowsql and NOT IN SNOWSIGHT
GET @INTERNAL_NAMED_STAGE1 FILE://D:\Senthamil\Learning\Snowflake SnowPro Core Certification\Udemy Resources\Code+and+Data+Files\Unload;

-- Remove stage files
REMOVE @INTERNAL_NAMED_STAGE1;

-- Use partition by - this will split the file into multiple files according to the parition condition specified.
COPY INTO @INTERNAL_NAMED_STAGE1
FROM CUSTOMERS_NAMED
PARTITION BY REGION
FILE_FORMAT =
(
TYPE = 'CSV',
COMPRESSION = 'NONE'
);

-- list files from stage
list @INTERNAL_NAMED_STAGE1;

-- Get multiples files into a single file
-- By default 16MB is the size of the file but we can get increased, also upto 5GB for cloud

COPY INTO @INTERNAL_NAMED_STAGE/sample/dump.csv
FROM CUSTOMERS_NAMED
FILE_FORMAT =
(
TYPE = 'CSV'
COMPRESSION = 'NONE'
)
OVERWRITE = TRUE
HEADER = TRUE
SINGLE = TRUE --Get output in one single file
MAX_FILE_SIZE = 4900000000;

list @INTERNAL_NAMED_STAGE;