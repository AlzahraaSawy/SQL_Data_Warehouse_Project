-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.Dim_customer', 'V') IS NOT NULL
    DROP VIEW gold.Dim_customer;
GO

CREATE OR ALTER VIEW gold.Dim_customer AS
SELECT 
ROW_NUMBER() OVER (ORDER BY cst_id ) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_marital_status AS marital_status,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	 ELSE COALESCE(ca.gen , 'n/a')
END AS gender,
ca.bdate AS birthday,
ci.cst_create_date AS create_date

FROM Silver.crm_cust_info ci LEFT JOIN Silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid LEFT JOIN Silver.erp_loc_a101 la
ON ci.cst_key = la.cid;
GO

-- =============================================================================
-- Create Dimension: Gold.Dim_product
-- =============================================================================
IF OBJECT_ID('Gold.Dim_product', 'V') IS NOT NULL
    DROP VIEW Gold.Dim_product;
GO

CREATE OR ALTER VIEW Gold.Dim_product AS
SELECT 
ROW_NUMBER () OVER (ORDER BY pn.prd_start_dt , pn.prd_key) AS product_key,
pn.prd_id AS product_id,
pn.prd_key AS product_number,
pn.prd_nm AS product_name,
pn.cat_id AS category_id, 
ct.cat AS category,
ct.subcat AS subcategory,
ct.maintenance AS maintenance,
pn.prd_cost AS cost,
pn.prd_line AS product_line,
pn.prd_start_dt AS start_date

FROM Silver.crm_prd_info pn
LEFT JOIN Silver.erp_px_cat_g1v2 ct
ON pn.cat_id = ct.id
WHERE prd_end_dt IS NULL; -- Filter out all historical data
GO

-- =============================================================================
-- Create Fact Table: Gold.Fact_sales
-- =============================================================================
IF OBJECT_ID('Gold.Fact_sales', 'V') IS NOT NULL
    DROP VIEW Gold.Fact_sales;
GO

CREATE OR ALTER VIEW Gold.Fact_sales AS

SELECT 
sls_ord_num AS order_number,
pr.product_key AS product_key,
cs.customer_key AS customer_key,
sls_order_dt AS order_date,
sls_ship_dt AS shipping_date,
sls_due_dt AS due_date,
sls_sales AS sales_amount,
sls_quantity AS quantity,
sls_price AS price
FROM Silver.crm_sales_details sd
LEFT JOIN Gold.Dim_product pr
ON sd.sls_prd_key = pr.product_number 
LEFT JOIN Gold.Dim_customer cs
ON cs.customer_id = sd.sls_cust_id;
GO
