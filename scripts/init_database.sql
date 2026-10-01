/* Create Database and Schemas
Script Purpose:
This script creates a new database named 'DataWarehouse'.
The script sets up three schemas within the database: 'bronze' , 'silver', and 'gold'
*/

CREATE DATABASE datawarehouse; --criação do banco de dados novo

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
