# sql-data-warehouse-project
Builiding a modern data warehouse with PgAdmin, including ETL processes, data modeling and analytics

Neste projeto construi um datawarehouse em PostgreSQL seguindo a arquitetura em camadas Bronze, Silver e Gold a partir de duas fontes de dados em CSV: CRM (crm_cust_info, crm_prd_info, crm_sales_details) e ERP (erp_cust_az12, erp_loc_a101, erp_px_cat_g1v2).

A camada Bronze carrega os dados brutos das 6 tabelas de origem, exatamente como vêm dos arquivos CSV, sem nenhuma transformação.

A camada Silver limpa e padroniza esses dados remove duplicatas e espaços indevidos, padroniza códigos e valores categóricos (gênero, país, linha de produto), valida e corrige datas e valores numéricos inconsistentes, e aplica regras de negócio (como recalcular vendas quando o valor original está incorreto).

A camada Gold é a camada de apresentação ("presentation layer"), feita com views, não em tabelas, que sempre apresentam os dados mais atuais do silver, organizadas em star model: gold.dim_customers (dimensão de clientes, unindo CRM e ERP), gold.dim_products (dimensão de produtos, com categoria/subcategoria do ERP) e gold.fact_sales (tabela fato com as vendas, ligada às duas dimensões pelas surrogate keys).
