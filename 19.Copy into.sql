/* 

    Copy INTO TABLE Options 

     ON_ERROR = { CONTINUE | SKIP_FILE (DEFAULT IN SNOWPIPE) | SKIP_FILE_<num> | 'SKIP_FILE_<num>%' | ABORT_STATEMENT (DEFAULT IN BULK LOADING) }
     SIZE_LIMIT = <num>
     RETURN_FAILED_ONLY = TRUE | FALSE (DEFAULT)
     MATCH_BY_COLUMN_NAME = CASE_SENSITIVE | CASE_INSENSITIVE | NONE (DEFAULT)
     ENFORCE_LENGTH = TRUE (DEFAULT) | FALSE
     
     TRUNCATECOLUMNS = TRUE | FALSE
     FORCE = TRUE | FALSE
     PURGE = TRUE | FALSE

*/

--Use DB and schema
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

--Use role and warehouse
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- check the data in the named stage
LIST @internal_named_stage;

-- create file format
CREATE OR REPLACE FILE FORMAT my_csv_ff
TYPE = CSV
FIELD_DELIMITER = ','
SKIP_HEADER = 1
NULL_IF = ('NULL', 'null')
EMPTY_FIELD_AS_NULL = true
COMPRESSION = NONE;

-- Create a sample table
CREATE OR REPLACE TABLE CUSTOMERS_NAMED
(
CUSTOMER INT NOT NULL,
FIRST_NAME VARCHAR(20) NOT NULL,
LAST_NAME VARCHAR(20) NOT NULL,
"REGION" VARCHAR(15) NOT NULL, --REGION IS A KEY WORD. Hence used ""
EMAIL VARCHAR(50) NOT NULL,
GENDER VARCHAR(10) NOT NULL,
"ORDER" INT NOT NULL --ORDER IS A KEY WORD. Hence used ""
);

-- ON_ERROR = { CONTINUE | SKIP_FILE (DEFAULT IN SNOWPIPE) | SKIP_FILE_<num> | 'SKIP_FILE_<num>%' | ABORT_STATEMENT (DEFAULT IN BULK LOADING) }

-- Use default copy
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE
FILE_FORMAT = my_csv_ff;

-- check the data
SELECT COUNT(*) FROM CUSTOMERS_NAMED;
-- Clear the data
TRUNCATE CUSTOMERS_NAMED;

//------------------------------------------------------------
-- ABORT STATEMENT IS BY DEFAULT
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE
FILE_FORMAT = my_csv_ff
ON_ERROR = ABORT_STATEMENT; //This is default for bulk loading even if it is not mentioned explicitely

-- check the data
SELECT COUNT(*) FROM CUSTOMERS_NAMED;
-- Clear the data
TRUNCATE CUSTOMERS_NAMED;

//------------------------------------------------------------
-- Use of CONTINUE to ignore the error records
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE
FILE_FORMAT = my_csv_ff
ON_ERROR = CONTINUE;

-- check the data
SELECT COUNT(*) FROM CUSTOMERS_NAMED;
-- Clear the data
TRUNCATE CUSTOMERS_NAMED;

//------------------------------------------------------------
-- SKIP the file if there are errors
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE
FILE_FORMAT = my_csv_ff
ON_ERROR = SKIP_FILE;

-- check the data
SELECT COUNT(*) FROM CUSTOMERS_NAMED;
-- Clear the data
TRUNCATE CUSTOMERS_NAMED;

//------------------------------------------------------------
-- Ignore first 2 error
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE
FILE_FORMAT = my_csv_ff
ON_ERROR = SKIP_FILE_2; //Ignore first 2 errors. 2 is the threshold. If there are 2 errors, the file will be skipped.

-- check the data
SELECT COUNT(*) FROM CUSTOMERS_NAMED;
-- Clear the data
TRUNCATE CUSTOMERS_NAMED;

//------------------------------------------------------------
-- Ignore first 2% error
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE
FILE_FORMAT = my_csv_ff
ON_ERROR = 'SKIP_FILE_2%'; //Ignore first 2% errors. 2% is the threshold.  If there are 2% errors, the file will be skipped. Below 2% will processed

-- check the data
SELECT COUNT(*) FROM CUSTOMERS_NAMED;
-- Clear the data
TRUNCATE CUSTOMERS_NAMED;

//------------------------------------------------------------
-- Size Limit option, First file will always go through even if the size is very low
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE
FILE_FORMAT = my_csv_ff
SIZE_LIMIT = 64;    //first file will always go through

-- Clear the data
TRUNCATE CUSTOMERS_NAMED;


-- Trying with different size
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE
FILE_FORMAT = my_csv_ff
SIZE_LIMIT = 6400000;

-- Clear the data
TRUNCATE CUSTOMERS_NAMED;

//------------------------------------------------------------
-- RETURN_FAILED_ONLY = TRUE | FALSE (DEFAULT)
-- Return Failed file if there is an error in the file while loading
-- the file will name will be shown if there are errors
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE
FILE_FORMAT = my_csv_ff
ON_ERROR = CONTINUE
RETURN_FAILED_ONLY = TRUE;  //By default, it is false

-- Clear the data
TRUNCATE CUSTOMERS_NAMED;

//------------------------------------------------------------
-- MATCH_BY_COLUMN_NAME = CASE_SENSITIVE | CASE_INSENSITIVE | NONE (DEFAULT)
-- Case sensitive options checks columns
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE/MOCK.CSV
FILE_FORMAT = my_csv_ff
MATCH_BY_COLUMN_NAME = CASE_SENSITIVE;

-- Error: SQL compilation error: match_by_column_name option is not supported for file format CSV without PARSE_HEADER = TRUE
-- Because, the file format my_csv_ff skips the headers. So, we need to use PARSE_HEADER = TRUE
-- Creating my_csv_ff2
CREATE OR REPLACE FILE FORMAT my_csv_ff2
TYPE = CSV
FIELD_DELIMITER = ','
-- SKIP_HEADER = 1
NULL_IF = ('NULL', 'null')
EMPTY_FIELD_AS_NULL = TRUE
PARSE_HEADER = TRUE
COMPRESSION = NONE;

-- Using the correct file format now
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE/MOCK1.CSV
FILE_FORMAT = my_csv_ff2
MATCH_BY_COLUMN_NAME = CASE_SENSITIVE;

-- Check if the data is loaded. The data will not be loaded if the column case doesn't match with the data and the table
SELECT COUNT(*) FROM CUSTOMERS_NAMED;

-- Clear the data
TRUNCATE CUSTOMERS_NAMED;

-- Using the case_insensitive
COPY INTO CUSTOMERS_NAMED
FROM @INTERNAL_NAMED_STAGE/MOCK1.CSV
FILE_FORMAT = my_csv_ff2
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

-- Clear the data
TRUNCATE CUSTOMERS_NAMED;

//------------------------------------------------------------

-- Creating table with different length for first_name
CREATE OR REPLACE TABLE LA_DB.LA_SCHEMA.CUSTOMERS_NAMED2 (
CUSTOMER NUMBER(38,0) NOT NULL,
FIRST_NAME VARCHAR(2) NOT NULL,
LAST_NAME VARCHAR(255) NOT NULL,
REGION VARCHAR(255) NOT NULL,
EMAIL VARCHAR(255) NOT NULL,
GENDER VARCHAR(255) NOT NULL,
"order" NUMBER(38,0) NOT NULL
);

-- Check the stage for available files
LIST @INTERNAL_NAMED_STAGE;

-- ENFORCE_LENGTH = TRUE (DEFAULT) | FALSE
COPY INTO CUSTOMERS_NAMED2
FROM @internal_named_stage/MOCK1.csv
FILE_FORMAT = my_csv_ff
ENFORCE_LENGTH = TRUE; //By default it is True

-- ENFORCE_LENGTH = TRUE (DEFAULT) | FALSE
COPY INTO CUSTOMERS_NAMED2
FROM @internal_named_stage/MOCK1.csv
FILE_FORMAT = my_csv_ff
ENFORCE_LENGTH = FALSE;



