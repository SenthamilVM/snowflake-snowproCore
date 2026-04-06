/*
A stream is a snowflake object type that provides change data capture(CDC) capabilities to track the delta of changes 
in a table, including inserts and data manipulation language(DML) changes, 
so action can be taken using the changed data.
*/

--Use DB and schema
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

--Use role and warehouse
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;


-- Create Source table
CREATE OR REPLACE TABLE RAW_DATA (
  ID INT,
  NAME VARCHAR(50),
  AGE INT
);

-- Create Target table
CREATE OR REPLACE TABLE PROCESSED_DATA (
  ID INT,
  NAME VARCHAR(50),
  AGE INT
);

SHOW TABLES LIKE '%raw%'; //notice change_tracking is off

-- Insert data in source

INSERT INTO RAW_DATA (ID, NAME, AGE) VALUES 
(1, 'John', 25),
(2, 'Mary', 30),
(3, 'Peter', 40),
(4, 'Jane', 35);

-- display the source data
SELECT * FROM RAW_DATA;

-- one time load to target table
INSERT INTO PROCESSED_DATA SELECT * FROM RAW_DATA;

-- display the target table
SELECT * FROM PROCESSED_DATA;

CREATE OR REPLACE STREAM raw_data_stream ON TABLE RAW_DATA;

-- show all streams
SHOW STREAMS;

-- check if the change_tracking is turned on
SHOW TABLES LIKE '%raw%'; //change tracking is ON automatically when we create a stream on top of the table

-- show specific stream
DESCRIBE STREAM raw_data_stream; //stale_after date is 2026-04-08 11:51:43.134 -0700 (14 days from today)

-- check database parameters
SHOW PARAMETERS IN DATABASE;
-- DATA_RETENTION_TIME_IN_DAYS - 1 DAY
-- MAX_DATA_EXTENSION_TIME_IN_DAYS - 14 DAYS

-- display stream data
SELECT * FROM raw_data_stream;

-- inserting new records in source table
INSERT INTO RAW_DATA (ID, NAME, AGE)
VALUES (5, 'Mike', 45);

-- Check if it is inserted into raw_data table
SELECT * FROM RAW_DATA;

-- display stream data
SELECT * FROM raw_data_stream;  //we have the data inserted tracked in the stream

-- INSERT Stream -- inserting data from stream to target table
INSERT INTO PROCESSED_DATA(ID, NAME, AGE) SELECT ID, NAME, AGE FROM raw_data_stream;

-- check if the data from stream gets inserted into the target table
SELECT * FROM PROCESSED_DATA;

-- update source table record
UPDATE RAW_DATA SET AGE = 27 WHERE ID = 1;

-- Delete a record
DELETE FROM RAW_DATA WHERE ID = 4;

-- Insert a new record
INSERT INTO RAW_DATA (ID, NAME, AGE)
VALUES (6, 'Mike', 65);

-- check if the table has the rows based on the above actions (insert, delete, update)
SELECT * FROM RAW_DATA;

-- check the stream
SELECT * FROM RAW_DATA_STREAM;

-- check the target table
SELECT * FROM PROCESSED_DATA;

-- merge to load data from stream to target
MERGE INTO PROCESSED_DATA p USING RAW_DATA_STREAM s ON p.ID = s.ID
    WHEN MATCHED AND metadata$action = 'DELETE' AND metadata$isupdate = 'FALSE' --deletion
        THEN DELETE
    WHEN MATCHED AND metadata$action = 'INSERT' AND metadata$isupdate = 'TRUE' --update
        THEN UPDATE SET p.NAME = s.NAME, p.AGE = s.AGE
    WHEN NOT MATCHED AND metadata$action  = 'INSERT' AND metadata$isupdate = 'FALSE' --insert
        THEN INSERT (ID, NAME, AGE) VALUES (s.ID, s.NAME, s.AGE);

-- check the target table
SELECT * FROM PROCESSED_DATA;

-- after consuming stream -- it should be empty now
SELECT * FROM RAW_DATA_STREAM;

-- show specific stream
DESCRIBE STREAM raw_data_stream;

-- Append only stream -- if we would like to insert only (incremental load) and NO deletion or updation
-- we can create multiple streams on the same table in case if we have multiple target tables
CREATE OR REPLACE STREAM RAW_DATA_STREAM2 ON TABLE RAW_DATA APPEND_ONLY = TRUE; -- insert_only = TRUE (for external tables)

SELECT * FROM RAW_DATA_STREAM2;

--update source table record
UPDATE RAW_DATA SET AGE = 28 WHERE ID = 1;

-- delete a record
DELETE FROM RAW_DATA WHERE ID = 1;

-- insert a record
INSERT INTO RAW_DATA (ID, NAME, AGE)
VALUES (6, 'Mike', 45); 

-- check the stream now. it should have inserted record only since it is append-only stream
SELECT * FROM RAW_DATA_STREAM2;


    



