--explorando os dados comparando com a silver 
--objetivo: comparar o formado do cid (faremos join com o cst_key com a tabela cust)
SELECT 
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12;

SELECT * FROM silver.crm_cust_info;

--retiramos o prefixo "NAS" que temos no cid para fazer join com a cst_key
SELECT
    CASE --estabelece condicoes
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid FROM 4) --se o cid tiver "NAS" 
		--pega a substring a partir da quarta posição removendo o NAS 
		--resultado: mesmo formato da cst_key
        ELSE cid
    END AS cid,
    bdate,
    gen
FROM bronze.erp_cust_az12;

--encontrar datas de nascimento improváveis
-- Identify Out-of-Range Dates
SELECT DISTINCT bdate --seleciona apenas datas unicas
FROM bronze.erp_cust_az12 
WHERE bdate < '1924-01-01' OR bdate > CURRENT_DATE;

-->> a partir daqui criamos a tabela na query silver.sql<<--

--por que terminar com ELSE bdate e END bdate? 
CASE 
    WHEN bdate > CURRENT_DATE THEN NULL
END AS bdate --aqui nao tem instrucao do que fazer com as linhas de dados "boas"
--teoricamente, teria que apagar dados bons tambem.


------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
SELECT
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid FROM 4)
        ELSE cid
    END AS cid,
    CASE 
        WHEN bdate > CURRENT_DATE THEN NULL --se for maior que a data atual, considerar nulo
        ELSE bdate --se não deixar como esta
    END AS bdate,
    CASE  --normalize gender values 
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female' --caixa alta para todos os caracteres
		--retira espacos em branco
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
--por fim: checar a qualidade dos dados 