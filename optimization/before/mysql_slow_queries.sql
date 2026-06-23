-- ============================================================
-- before/mysql_slow_queries.sql
--
-- Same representative queries as the Postgres version, adapted
-- to MySQL's EXPLAIN syntax. Use EXPLAIN ANALYZE (MySQL 8.0.18+)
-- for real timing data, or EXPLAIN alone for just the plan
-- without execution.
-- ============================================================

-- ---- Query 1: All transactions for a specific agent ----
EXPLAIN ANALYZE
SELECT t.transaction_id, t.sale_date, t.sale_price, p.address
FROM transactions t
JOIN properties p ON p.property_id = t.property_id
WHERE t.agent_id = 23;

-- ---- Query 2: Transactions within a date range ----
EXPLAIN ANALYZE
SELECT transaction_id, sale_date, sale_price
FROM transactions
WHERE sale_date BETWEEN '2026-01-01' AND '2026-03-31'
ORDER BY sale_date;

-- ---- Query 3: A party's full transaction history (buyer OR seller) ----
EXPLAIN ANALYZE
SELECT t.transaction_id, t.sale_date, t.sale_price,
       CASE WHEN t.buyer_party_id = 1500 THEN 'buyer' ELSE 'seller' END AS role
FROM transactions t
WHERE t.buyer_party_id = 1500 OR t.seller_party_id = 1500;

-- ---- Query 4: High-value transactions with payment status ----
EXPLAIN ANALYZE
SELECT t.transaction_id, t.sale_price, tp.payment_status, tp.financed_amount
FROM transactions t
JOIN transaction_payments tp ON tp.transaction_id = t.transaction_id
WHERE t.sale_price > 500000
ORDER BY t.sale_price DESC;

-- ---- Query 5: Agent performance leaderboard ----
EXPLAIN ANALYZE
SELECT a.agent_id, a.first_name, a.last_name,
       COUNT(*) AS deal_count, SUM(t.sale_price) AS total_volume
FROM transactions t
JOIN agents a ON a.agent_id = t.agent_id
GROUP BY a.agent_id, a.first_name, a.last_name
ORDER BY total_volume DESC
LIMIT 10;
