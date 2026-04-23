USE Master
GO
--Drop and recreate database 
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
  ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE 
  DROP DATABASE DataWarehouse
END
GO

--Create 'DataWarehouse' Database
CREATE DATABASE DataWarehouse

--Use Database
USE DataWarehouse

--Create Schemas
CREATE SCHEMA Bronze
GO
  
CREATE SCHEMA Silver
GO
  
CREATE SCHEMA Gold
GO
