-- Unloading data
--Table -> stage -> local file / External

--Use DB and schema
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

--Use role and warehouse
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- Create stage
CREATE OR REPLACE STAGE INTERNAL_NAMED_STAGE1
FILE_FORMAT =
(
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
);

SHOW STAGES;

-- Check if we have any data inside the stage already
list @internal_named_stage1;

COPY INTO @INTERNAL_NAMED_STAGE1
FROM CUSTOMERS_NAMED
FILE_FORMAT =
(
TYPE = 'CSV'
COMPRESSION = NONE
)
-- MAX_FILE_SIZE = 60   --To split this file into multiple files. Use it if the file size is big
-- OVERWRITE = TRUE     --Use this to overwrite the data
HEADER = TRUE;

-- Check if the copied into the stage from table
list @internal_named_stage1;

-- The following has to be executed in snowflake CLI and NOT IN SNOWSIGHT
get @internal_named_stage1 file://<folder path>;

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

COPY INTO @INTERNAL_NAMED_STAGE1/sample/dump.csv
FROM CUSTOMERS_NAMED
FILE_FORMAT = 
(
TYPE = 'CSV'
COMPRESSION = 'NONE'
)
OVERWRITE = TRUE
HEADER = TRUE
SINGLE = TRUE
MAX_FILE_SIZE = 4900000000;

list @internal_named_stage1/sample;

-- Downloading dump.csv file from stage to the local folder
get @internal_named_stage1/sample file://<folder path>;
