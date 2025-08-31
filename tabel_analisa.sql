SELECT * FROM kimia_farma.kf_final_transaction LIMIT 5;
SELECT * FROM kimia_farma.kf_product LIMIT 5;
SELECT * FROM kimia_farma.kf_kantor_cabang LIMIT 5;
SELECT * FROM kimia_farma.kf_inventory LIMIT 5;

CREATE TABLE kimia_farma.kf_analisa AS
SELECT
  t.transaction_id,
  t.date,
  t.branch_id,
  c.branch_name,
  c.kota,
  c.provinsi,
  c.rating AS rating_cabang,
  t.customer_name,
  t.product_id,
  p.product_name,
  t.price AS actual_price,
  t.discount_percentage,
  -- for persentase_gross_laba column
CASE
  WHEN t.price <= 50000 THEN 0.10
  WHEN t.price <= 100000 THEN 0.15
  WHEN t.price <= 300000 THEN 0.20
  WHEN t.price <= 500000 THEN 0.25
  ELSE 0.30
END AS persentase_gross_laba,
-- for nett_sales column
(t.price*(1-t.discount_percentage/100)) AS nett_sales,
-- for nett_profit column
(t.price*(1-t.discount_percentage/100))*
  CASE
    WHEN t.price <= 50000 THEN 0.10
    WHEN t.price <= 100000 THEN 0.15
    WHEN t.price <= 300000 THEN 0.20
    WHEN t.price <= 500000 THEN 0.25
    ELSE 0.30
  END AS nett_profit,
t.rating AS rating_transaksi
FROM `kimia_farma.kf_final_transaction`t
JOIN `kimia_farma.kf_product`p USING(product_id)
JOIN `kimia_farma.kf_kantor_cabang`c USING(branch_id);

-- for top 10 provinces by transactions
SELECT provinsi,
       COUNT(DISTINCT transaction_id) AS total_transaksi,
       SUM(nett_sales) AS total_sales
FROM `kimia_farma.kf_analisa`
GROUP BY provinsi
ORDER BY total_sales DESC
LIMIT 10;

-- for top 10 provinces by sales
SELECT provinsi,
       SUM(nett_sales) AS total_sales
FROM `kimia_farma.kf_analisa`
GROUP BY provinsi
ORDER BY total_sales DESC
LIMIT 10;
