--Use DB and schema
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

--Use role and warehouse
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- Create new table
CREATE OR REPLACE TABLE NEW_PIPE_TABLE(
CUSTOMER VARCHAR,
FIRST_NAME VARCHAR,
LAST_NAME VARCHAR,
REGION VARCHAR,
EMAIL VARCHAR,
GENDER VARCHAR,
"ORDER" INTEGER
);


LIST @INTERNAL_NAMED_STAGE;

-- create a pipe to copy
CREATE OR REPLACE PIPE MYPIPE
AS
COPY INTO NEW_PIPE_TABLE FROM @INTERNAL_NAMED_STAGE;


-- Template for PIPE (this includes properties for cloud like AWS_SNS_TOPIC etc.)
CREATE [ OR REPLACE ] PIPE [ IF NOT EXISTS ] <name>
  [ AUTO_INGEST = [ TRUE | FALSE ] ]
  [ ERROR_INTEGRATION = <integration_name> ]
  [ AWS_SNS_TOPIC = '<string>' ]
  [ INTEGRATION = '<string>' ]
  [ COMMENT = '<string_literal>' ]
  AS <copy_statement>;


-- check the data in the table
SELECT COUNT(*) FROM NEW_PIPE_TABLE;   //still, there is no data. Because, the pipe is not active/it needs to be refreshed.

-- show all pipes
SHOW PIPES;

-- describe pipe
DESCRIBE PIPE MYPIPE;

-- check pipe status
SELECT SYSTEM$PIPE_STATUS ('MYPIPE');      //It is running. but the file count inside the table is 0
-- this is because, the pipe needs to be activated/refreshed.

-- refresh the pipe
ALTER PIPE MYPIPE REFRESH;

-- check pipe status once again
SELECT SYSTEM$PIPE_STATUS ('MYPIPE');

-- check the count in the table once again
SELECT COUNT(*) FROM NEW_PIPE_TABLE;    //2000 records have been loaded //3000 records


-- TASK:
-- Refresh has to be done manually everytime we load a file. This needs to be scheduled/automated. That's why Task is used.

CREATE OR REPLACE TASK TASK_SAMPLE
SCHEDULE = '1 MINUTE'
-- USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL' --this uses WH size as XSMALL.System will decide otherwise.
AS
ALTER PIPE MYPIPE REFRESH;

DESCRIBE TASK TASK_SAMPLE;  //state is suspended. it needs to be resumed.

-- once the task is resumed, it will continuously run according to the schedule time (1 Minute here)
ALTER TASK TASK_SAMPLE RESUME;

-- Try adding a file to the stage using Snowflake CLI

-- put file://<folder path>/MOCK1.csv @internal_named_stage AUTO_COMPRESS = FALSE;

-- check the count in the table once again after loading Mock1.csv
SELECT COUNT(*) FROM NEW_PIPE_TABLE;    //Now, 3000 records are there in the table

-- the task has to be stopped/dropped for the time being. Otherwise, it will run in every 1 minute interval and keep on running
DROP TASK TASK_SAMPLE;
