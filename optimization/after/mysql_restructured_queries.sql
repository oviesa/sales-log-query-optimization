-- ============================================================
-- after/mysql_restructured_queries.sql
-- Same restructuring logic as the Postgres version -- see that
-- file's comments for the full reasoning on Query 3.
-- ============================================================

EXPLAIN ANALYZE
SELECT t.transaction_id, t.sale_date, t.sale_price, p.address
FROM transactions t
JOIN properties p ON p.property_id = t.property_id
WHERE t.agent_id = 23;

EXPLAIN ANALYZE
SELECT transaction_id, sale_date, sale_price
FROM transactions
WHERE sale_date BETWEEN '2026-01-01' AND '2026-03-31'
ORDER BY sale_date;

-- Restructured OR -> UNION ALL (see postgres version for full rationale)
EXPLAIN ANALYZE
SELECT transaction_id, sale_date, sale_price, 'buyer' AS role
FROM transactions
WHERE buyer_party_id = 1500
UNION ALL
SELECT transaction_id, sale_date, sale_price, 'seller' AS role
FROM transactions
WHERE seller_party_id = 1500;

EXPLAIN ANALYZE
SELECT t.transaction_id, t.sale_price, tp.payment_status, tp.financed_amount
FROM transactions t
JOIN transaction_payments tp ON tp.transaction_id = t.transaction_id
WHERE t.sale_price > 500000
ORDER BY t.sale_price DESC;

EXPLAIN ANALYZE
SELECT a.agent_id, a.first_name, a.last_name,
       COUNT(*) AS deal_count, SUM(t.sale_price) AS total_volume
FROM transactions t
JOIN agents a ON a.agent_id = t.agent_id
GROUP BY a.agent_id, a.first_name, a.last_name
ORDER BY total_volume DESC
LIMIT 10;
