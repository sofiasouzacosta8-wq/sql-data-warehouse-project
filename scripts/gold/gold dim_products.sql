CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id AS product_id, --rename the columns 
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL; -- Filtra apenas os produtos atuais, sem versões históricas

SELECT * FROM gold.dim_products;

--DIFERENÇA ENTRE CREATE VIEW E INSERT 
--view não armazena nenhum dado, é apenas uma consulta salva
--o banco guarda apenas a definicao da query
--quando as tabelas silver forem alteradas, as views do gold schema já irao apresentar as mudancas
--por serem consultas salvas
--gold layer é chamada de "presentation layer"
--gold nao é um lugar pra armazenar dados, e sim apresentar os dados
