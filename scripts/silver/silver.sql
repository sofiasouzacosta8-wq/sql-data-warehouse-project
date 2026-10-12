---------------------------------SILVER LAYER----------------------------------------------------
--consultar dados da bronzelayer
SELECT * FROM bronze.crm_cust_info
LIMIT 100;

SELECT * FROM bronze.crm_prd_info
LIMIT 100;

SELECT * FROM bronze.crm_sales_details
LIMIT 100;

SELECT * FROM bronze.erp_cust_az12
LIMIT 100;

SELECT * FROM bronze.erp_loc_a101
LIMIT 100;

SELECT * FROM bronze.erp_px_cat_g1v2
LIMIT 100;

--creating silver schema

CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
    cst_id              INT,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date      DATE,
);

DROP TABLE IF EXISTS silver.crm_prd_info; --WE CHANGED THE DATA TYPE later
CREATE TABLE silver.crm_prd_info (
    prd_id       INT,
	cat_id		 VARCHAR(50),
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INT,
    prd_line     VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
    cid    VARCHAR(50),
    bdate  DATE,
    gen    VARCHAR(50),
	dwh_create_date  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
    cid     VARCHAR(50),
    cntry   VARCHAR(50),
	dwh_create_date  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
    id          VARCHAR(50),
    cat         VARCHAR(50),
    subcat      VARCHAR(50),
    maintenance VARCHAR(50),
	dwh_create_date  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--criando coluna de metadado para cada tabela 
--para saber quando os dados foram carregados com TIMESTAMP
--função que retorna a hora e data do momento
ALTER TABLE silver.crm_cust_info      ADD COLUMN dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE silver.crm_prd_info       ADD COLUMN dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE silver.crm_sales_details  ADD COLUMN dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE silver.erp_cust_az12      ADD COLUMN dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE silver.erp_loc_a101       ADD COLUMN dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE silver.erp_px_cat_g1v2    ADD COLUMN dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

--checking the quality of our data
--detecting quality issues  
--then we will star writing the transformation 
SELECT
    cst_id,
    COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1; --alguns ids da chave primaria aparecem mais de uma vez
--primary key should be unique 

SELECT *
FROM bronze.crm_cust_info
WHERE cst_id = 29466; --checking the newest record (registro)

--racking these dates 
SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id = 29466; --the first one the newest record 


SELECT *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
) t --subconsulta
WHERE flag_last != 1; --checking the data we don't need because are causing duplicates
--it shows the numbers ≥ 2

--check unwated spaces
-- Expectation: No Results
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname); --"cut"empty spaces

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

--gender: low cardanality (column has low unique values)
-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info; 


SELECT DISTINCT crm_cust_info.cst_mar_status FROM bronze.crm_cust_info;
--we want the full name of M and F (male and female) --> rule for our project
--user upper just if we have lowercase values

--resolver problema na tabela cust info: 
ALTER TABLE bronze.crm_cust_info
RENAME COLUMN cst_material_status TO cst_marital_status;



