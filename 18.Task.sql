-- tasks: A task is used to automatic the data loading/unloading process (scheduled refresh) - to automate the snowpipe

--Use DB and schema
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

--Use role and warehouse
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- create TASK with User Managed Warehouse
CREATE OR REPLACE TASK TASK_DEMO_U
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '1 MINUTE'
AS
INSERT INTO my_table (ID, NAME, EMAIL) VALUES
(100, 'User Managed', 'john@example.com');


-- create task for Snowflake Managed Warehouse (Serverless)
CREATE OR REPLACE TASK TASK_DEMO_S
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'  --Default is Medium (check using SHOW PARAMETERS IN DATABASE)
    SCHEDULE = '1 MINUTE'
AS
    INSERT INTO my_table (ID, NAME, EMAIL) VALUES
    (100, 'Serverless', 'john@example.com');

-- Check the default values
SHOW PARAMETERS IN DATABASE;

-- Show all tasks
SHOW TASKS; -- notice, for serverless, there is no warehouse tagged.

-- Now, we need to activate these tasks. currently it is suspended
ALTER TASK TASK_DEMO_U RESUME;
ALTER TASK TASK_DEMO_S RESUME;

-- Show all tasks -- check the state - now it is started
SHOW TASKS;

-- check history of all tasks and check the status of the tasks (scheduled/executing/succeeded/suspended)
SELECT * FROM TABLE (INFORMATION_SCHEMA.TASK_HISTORY());

SELECT * FROM my_table;

-- you can alter the initial warehouse.
ALTER TASK TASK_DEMO_S SET USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'SMALL';
-- ERROR: Unable to update graph with root task LA_DB.LA_SCHEMA.TASK_DEMO_S since that root task is not suspended.

-- The task needs to be suspended to alter the tasks
ALTER TASK TASK_DEMO_U SUSPEND;
ALTER TASK TASK_DEMO_S SUSPEND;

-- After suspending the task, we can alter
ALTER TASK TASK_DEMO_S SET USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'SMALL';

-- describe specific task
DESCRIBE TASK TASK_DEMO_U;
DESCRIBE TASK TASK_DEMO_S;
-- both the tasks have been suspended

-- to do ON-DEMAND refresh of the task without automating (resuming it)
EXECUTE TASK TASK_DEMO_U;

-- drop task
DROP TASK IF EXISTS TASK_DEMO_S;

-- Create TASK_DEMO_S again if it is dropped already
CREATE OR REPLACE TASK TASK_DEMO_S
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'  --Default is Medium (check using SHOW PARAMETERS IN DATABASE)
    SCHEDULE = '1 MINUTE'
AS
    INSERT INTO my_table (ID, NAME, EMAIL) VALUES
    (100, 'Serverless', 'john@example.com');

-- dependent tasks
CREATE OR REPLACE TASK TASK_DEMO_2
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
    -- SCHEDULE = '1 MINUTE' --not required since it is a dependent task
    AFTER TASK_DEMO_S                   --The task should be suspended before using it. if it is active, we cannot use it. We can resume after using it.
AS
INSERT INTO my_table (ID, NAME, EMAIL) VALUES
(100, 'Dependent', 'john@example.com');

ALTER TASK TASK_DEMO_2 RESUME;

DESCRIBE TASK TASK_DEMO_S; -- THE TASK IS SUSPENDED
ALTER TASK TASK_DEMO_S RESUME; --THE TASK IS RESUMED HERE IN ORDER TO USE IT

-- checking if both the tasks have been resumed/started
SHOW TASKS; --it is started


-- check if the tasks have been succeeded/executing etc.
SELECT * FROM TABLE (INFORMATION_SCHEMA.TASK_HISTORY());

-- check if the data is inserted in the table
SELECT * FROM my_table;

//-------------------------------------------------------------------

-- Combining Stream and Tasks

-- check if the stream has any data
SELECT * FROM raw_data_stream;

-- Inserting new record in source table
INSERT INTO raw_data (ID, NAME, AGE) VALUES
(10, 'Learn', 45);

-- checking if new record is added to the stream
SELECT * FROM raw_data_stream;

-- creating task to ingest data from stream to target table (processed_data)
CREATE OR REPLACE TASK TASK_STREAM
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
    SCHEDULE = '1 MINUTE'
WHEN SYSTEM$STREAM_HAS_DATA ('raw_data_stream')
AS
INSERT INTO processed_data(ID, NAME, AGE) SELECT ID, NAME, AGE FROM raw_data_stream;


-- checking the task
DESCRIBE TASK TASK_STREAM;

-- resume task
ALTER TASK TASK_STREAM RESUME;

-- checking history of all tasks
SELECT * FROM TABLE (INFORMATION_SCHEMA.TASK_HISTORY());

SHOW TASKS;

SELECT * FROM processed_data;

-- check which tasks are running and suspend
SHOW TASKS;

-- suspend all tasks to avoid running this unneccessarily
ALTER TASK TASK_DEMO_S SUSPEND;
ALTER TASK TASK_DEMO_2 SUSPEND; --to suspend this, we need to suspend the root task which is TASK_DEMO_S first
ALTER TASK TASK_STREAM SUSPEND;
