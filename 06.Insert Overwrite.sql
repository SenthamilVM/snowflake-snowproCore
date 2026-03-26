-- INSERT OVERWRITE
-- This deletes the existing records in the target table before inserting new values

--Use DB and schema
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

--Use role and warehouse
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

--Create employee table
CREATE OR REPLACE TABLE EMPLOYEES
(
ID INT,
NAME VARCHAR(25),
DEPARTMENT VARCHAR(35)
);

INSERT INTO EMPLOYEES (ID, NAME, DEPARTMENT)
VALUES
(1, 'John Doe', 'Engineering'),
(2, 'Jane Doe', 'Sales');

-- This will overwrite the existing data in employees table with the new data from the select statement
INSERT OVERWRITE INTO EMPLOYEES
SELECT ID, NAME, DEPARTMENT FROM EMPLOYEES WHERE DEPARTMENT = 'Engineering';

SELECT * FROM EMPLOYEES;

-- Note: INSERT will insert a new record into the table. INSERT OVERWRITE will overwrite the existing record in the table.