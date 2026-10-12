--gold layer: only data transformation with no load  process
--star schema
--normalmente feita com views: guarda uma consulta
--tabela principal: silver.crm_cust_info
--> Master Table: tudo que vem depois só adiciona colunas a ela
-- nunca remove linhas dela 

--PRIMEIRO JOIN: silver.erp_loc_a101
-->para cada cliente do CRM procure na tabela ERP de clientes um
--registro cujo cid seja igual ao cst_key do CRM.
--quando encontra, traz junto o bdate e gen (gênero)
--informações que o CRM não tem, mas o ERP tem

--SEGUNDO JOIN: silver.erp_loc_a101, alias la
-- ON ci.cst_key = la.cid
--junta pelo mesmo tipo de chave so que dessa vez para trazer 
--country

--Por que não INNER JOIN? 
--se todo registro que estivesse no CRM mas não estivesse no ERP
--seria descartado, perdendo dados

--we took three tables and put in one object
--versao final
CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key, --Surrogate key é uma chave artificial,
	--criada pelo próprio data warehouse, que não existe nos dados originais
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender Info
         ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;

--CRM informations are more accurate 
SELECT DISTINCT
    ci.cst_gndr, 
    ca.gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid
ORDER BY 1, 2; --ordene pelas colunas 
--resultado: divergncia de sexo

--resolver conflito:
SELECT DISTINCT
    ci.cst_gndr,
    ca.gen,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender Info
         ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid
ORDER BY 1, 2;

--testing:
SELECT * FROM gold.dim_customers
LIMIT 100