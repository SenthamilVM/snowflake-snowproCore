--Use DB and schema
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

--Use role and warehouse
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- Create a view
CREATE OR REPLACE VIEW CUSTOMER_VIEW AS
SELECT CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE, ADDRESS, CITY, STATE, COUNTRY, JOIN_DATE
FROM CUSTOMER;

SELECT * FROM CUSTOMER_VIEW;

CREATE OR REPLACE VIEW CUSTOMER_LOCATION_VIEW AS
SELECT CUSTOMER_ID, CONCAT(ADDRESS, ' ', CITY, ' ', STATE, ' ', COUNTRY) AS LOCATION, JOIN_DATE
FROM CUSTOMER;

SELECT * FROM CUSTOMER_LOCATION_VIEW;


-- CREATE MATERIALIZED VIEW CALLED CUSTOMER_LOCATION_MV
CREATE OR REPLACE MATERIALIZED VIEW CUSTOMER_LOCATION_MV AS
SELECT CUSTOMER_ID, CONCAT(ADDRESS, ' ', CITY, ' ', STATE, ' ', COUNTRY) AS LOCATION
FROM CUSTOMER
WHERE STATE = 'CA';

SELECT * FROM CUSTOMER_LOCATION_MV;

-- Create a secure materialized view called CUSTOMER_LOCATION_MV_S
CREATE SECURE MATERIALIZED VIEW CUSTOMER_LOCATION_MV_S AS
SELECT CUSTOMER_ID, CONCAT(ADDRESS, ' ', CITY, ' ', STATE, ' ', COUNTRY) AS LOCATION
FROM CUSTOMER
WHERE STATE = 'CA';

SELECT * FROM CUSTOMER_LOCATION_MV_S;

-- Display all views
SHOW VIEWS;

-- WHY SECURE VIEW?
-- THE FOLLOWING WILL EXPLAIN THE NEED OF SECURE VIEW

USE ROLE ACCOUNTADMIN;

-- Grant relevant access on DB to User admin
GRANT USAGE ON DATABASE LA_DB TO USERADMIN;
-- Grant relevant access on schema
GRANT USAGE ON SCHEMA LA_SCHEMA TO USERADMIN;

-- Grant select access on views
GRANT SELECT ON VIEW CUSTOMER_LOCATION_MV TO USERADMIN;
GRANT SELECT ON VIEW CUSTOMER_LOCATION_MV_S TO USERADMIN;

-- Grant warehouse usage to the role.
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO USERADMIN;

-- Change role and check for the neccessary access
USE ROLE USERADMIN;

-- SELECT should work because of the select grant above
SELECT * FROM CUSTOMER_LOCATION_MV;
SELECT * FROM CUSTOMER_LOCATION_MV_S;

-- DDL definition will not be shown for the secured view and that's the important role of secure view.
-- Even if the user has SELECT Grant, they will not be able to see the definition behind the code. This will avoid the code to be visible to the user who has just SELECT Grant.

SELECT GET_DDL('VIEW', 'CUSTOMER_LOCATION_MV');
SELECT GET_DDL('VIEW', 'CUSTOMER_LOCATION_MV_S');

SHOW VIEWS;

--------------------------------------------------------------------------------------------------
--Check why secure materialized view (CUSTOMER_LOCATION_MV_S) is showing ddl. As per the behaviour it should not be shown.
-------------------------------------------------------------------------------------------------------------
-- We need to set the secondary role as None for the session so that DDL will not be visible
-- USE SECONDARY ROLES ALL;    -- activate all roles
-- USE SECONDARY ROLES NONE;   -- only primary role
-- USE SECONDARY ROLES role1, role2;  -- specific roles


