-- Create database and Schema
CREATE DATABASE LA_DB;

CREATE SCHEMA LA_SCHEMA;

-- Create table and insert records
CREATE TABLE IF NOT EXISTS my_table(
id INT,
name VARCHAR(50),
email VARCHAR(100)
);

INSERT INTO LA_DB.LA_SCHEMA.MY_TABLE (id, name, email) VALUES
(1, 'John Smith', 'john@example.com'),
(2, 'Amit', 'amit@example.com'),
(3, 'Bob Johnson', 'bob@example.com');

SELECT * FROM my_table;

-- Describe table to see the metadata attached to it
DESCRIBE TABLE my_table;

SHOW DATABASES;

-- Describe db to see the metadata attached to it
DESCRIBE DATABASE LA_DB;

--******Constraints enforced by snowflake******
--Except NOT NULL snoflake doesn't enforce most of the constraints. In other words, snowflake only enforces NOT NULL

--1.PRIMARY KEY

CREATE OR REPLACE TABLE my_table(
id INT PRIMARY KEY, -- primary key is not enforced by snowflake eventhough it is specified as primary key
name VARCHAR(50),
email VARCHAR(100)
);

--id "1" is duplicate here. when we run the below code, it will run without any error as snowflake doesn't enforce primary key constraint unlike other databases
INSERT INTO LA_DB.LA_SCHEMA.MY_TABLE (id, name, email) VALUES
(1, 'John Smith', 'john@example.com'),
(1, 'Amit', 'amit@example.com'), 
(3, 'Bob Johnson', 'bob@example.com');

SELECT * FROM my_table; -- checking if id "1" is inserted

--2.NOT NULL - snowflake enforces not null

CREATE OR REPLACE TABLE my_table(
id INT,
name VARCHAR(50) NOT NULL, -- NOT NULL constraint is set here
email VARCHAR(100)
);

--The below code will throw an error because snowflake enforces not null
INSERT INTO LA_DB.LA_SCHEMA.MY_TABLE (id, name, email) VALUES
(1, 'John Smith', 'john@example.com'),
(2, NULL, 'amit@example.com'), 
(3, 'Bob Johnson', 'bob@example.com');

--Error: DML operation to table LA_DB.LA_SCHEMA.MY_TABLE failed on column NAME with error: NULL result in a non-nullable column