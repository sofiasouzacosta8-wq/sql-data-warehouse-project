--this table contains location information
--join cid com cst_key
--explorando os dados, comparando os formados de chave

SELECT 
    cid,
    cntry
FROM bronze.erp_loc_a101;

SELECT cst_key FROM silver.crm_cust_info;

--verificando se, sem o hífen, as chaves batem
SELECT 
    REPLACE(cid, '-', '') AS cid, --substituir - por nada
    cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info);

--verficacao da coluna country e busca de inconsistencias
-- Data Standardization & Consistency
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
ORDER BY cntry; 
-----------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
INSERT INTO silver.erp_loc_a101 (cid, cntry)
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE 
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101;
---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
SELECT * FROM silver.erp_loc_a101
LIMIT 10
