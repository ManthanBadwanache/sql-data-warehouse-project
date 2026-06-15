# /*
Purpose:
This script initializes the data warehouse by creating the database and the
required schemas for the Medallion Architecture (Bronze, Silver, and Gold).

Schemas:

* bronze : Stores raw data ingested from source systems.
* silver : Stores cleansed and transformed data.
* gold   : Stores business-ready data for reporting and analytics.

Warning:

* Execute the CREATE DATABASE statement only once.
* PostgreSQL does not support CREATE DATABASE IF NOT EXISTS.
* If the database already exists, PostgreSQL will return an error.
* After creating the database, connect to the 'datawarehouse' database before
  executing the schema creation statements.

===============================================================================
*/

-- Create the data warehouse database.
CREATE DATABASE datawarehouse;

-- Connect to the 'datawarehouse' database before executing the statements below.

-- Create the Bronze schema for raw source data.
CREATE SCHEMA IF NOT EXISTS bronze;

-- Create the Silver schema for cleansed and transformed data.
CREATE SCHEMA IF NOT EXISTS silver;

-- Create the Gold schema for business-ready data.
CREATE SCHEMA IF NOT EXISTS gold;
