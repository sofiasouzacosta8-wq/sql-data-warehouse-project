--clean and load crm_prd_info

SELECT * FROM bronze.crm_prd_info;

-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT 
    prd_id,
    COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL; --having serve para filtrar grupos 
--depois que o agrupamento e as contas ja foram feitas



SELECT
prd_id,
prd_key,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, --pega os 5 primeiros 
--caracteres e susbtitui o separador _ por - 
SUBSTRING(prd_key FROM 7) AS prd_key,  --extrai um pedaco da string e retorna a partir
--da 7a posicao
prd_nm,
COALESCE(prd_cost, 0) AS prd_cost, --coalesce é o isnull do sql server 
--se for nulo substituir por 0
CASE 
    WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain' 
    WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
    WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
    WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
    ELSE 'n/a'
END AS prd_line,
prd_start_dt,
prd_end_dt
FROM bronze.crm_prd_info;

------------------------------------------------------------------------------------------
								--VERSÃO FINAL--
------------------------------------------------------------------------------------------
INSERT INTO silver.crm_prd_info(
	prd_id,       
	cat_id,		 
    prd_key,      
    prd_nm,       
    prd_cost,     
    prd_line,     
    prd_start_dt, 
    prd_end_dt   
)
SELECT
prd_id,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, --pega os 5 primeiros 
--caracteres e susbtitui o separador _ por - 
SUBSTRING(prd_key FROM 7) AS prd_key,  --extrai um pedaco da string e retorna a partir
--da 7a posicao
prd_nm,
COALESCE(prd_cost, 0) AS prd_cost, --coalesce é o isnull do sql server 
--se for nulo substituir por 0
CASE 
    WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain' 
    WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
    WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
    WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
    ELSE 'n/a'
END AS prd_line,
CAST(prd_start_dt AS DATE) AS prd_start_dt, --cast converte de timestamp para date,
--removendo hora, apra ficar mais limpo
CAST(
LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE
) - 1 AS prd_end_dt
--para cada linha, olha a coluna prd_start_dt
--separa os dados em grupos, um grupo para cada cada prd_key
--dentro de cada grupo, ordena as linhas pela data de início, da mais antiga pra mais nova
--forma natural ascendente
--over tranforma lead em uma window function
--aplique isso considerando a janela definida ali dentro
FROM bronze.crm_prd_info;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------





WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN ( --seleciona ids que nao estao
-- na coluna do erp
    SELECT DISTINCT id 
    FROM bronze.erp_px_cat_g1v2
);

SELECT DISTINCT id 
FROM bronze.erp_px_cat_g1v2; --selecionar quais id unicos realmente existem nas
--cartegorias do erp

--cleaned product information

