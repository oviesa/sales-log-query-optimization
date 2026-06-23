-- ============================================================
-- before/postgres_slow_queries.sql
--
-- Representative "real-world" queries a real estate analytics
-- dashboard would actually run, executed against the UNINDEXED
-- baseline schema. EXPLAIN ANALYZE reveals the execution plan
-- Postgres actually chose -- look for "Seq Scan" (sequential /
-- full table scan) on large tables, which is the smoking gun
-- for a missing index.
--
-- Run each EXPLAIN ANALYZE individually and save the output --
-- you'll compare it against optimization/after/ later.
-- ============================================================

-- ---- Query 1: All transactions for a specific agent ----
-- Common dashboard query: "show me agent #23's deal history."
-- Without an index on agent_id, Postgres must scan all 50,000
-- transaction rows to find the matches.
EXPLAIN ANALYZE
SELECT t.transaction_id, t.sale_date, t.sale_price, p.address
FROM transactions t
JOIN properties p ON p.property_id = t.property_id
WHERE t.agent_id = 23;

-- ---- Query 2: Transactions within a date range ----
-- Common dashboard query: "show Q1 2026 activity."
-- Without an index on sale_date, this is also a full scan.
EXPLAIN ANALYZE
SELECT transaction_id, sale_date, sale_price
FROM transactions
WHERE sale_date BETWEEN '2026-01-01' AND '2026-03-31'
ORDER BY sale_date;

-- ---- Query 3: A party's full transaction history (buyer OR seller) ----
-- This is the worst-case pattern: an OR condition across two
-- unindexed FK columns, which usually defeats simple indexing
-- strategies and is a great "restructuring" case study.
EXPLAIN ANALYZE
SELECT t.transaction_id, t.sale_date, t.sale_price,
       CASE WHEN t.buyer_party_id = 1500 THEN 'buyer' ELSE 'seller' END AS role
FROM transactions t
WHERE t.buyer_party_id = 1500 OR t.seller_party_id = 1500;

-- ---- Query 4: High-value transactions with payment status ----
-- Joins the sensitive financial table; without indexes on
-- sale_price or the join column, this is a full scan plus a
-- nested loop or hash join over the whole payments table too.
EXPLAIN ANALYZE
SELECT t.transaction_id, t.sale_price, tp.payment_status, tp.financed_amount
FROM transactions t
JOIN transaction_payments tp ON tp.transaction_id = t.transaction_id
WHERE t.sale_price > 500000
ORDER BY t.sale_price DESC;

-- ---- Query 5: Agent performance leaderboard ----
-- Aggregation query: total sales volume per agent, common on any
-- internal reporting dashboard. GROUP BY over an unindexed FK
-- forces a full scan + hash aggregate over all 50,000 rows.
EXPLAIN ANALYZE
SELECT a.agent_id, a.first_name, a.last_name,
       COUNT(*) AS deal_count, SUM(t.sale_price) AS total_volume
FROM transactions t
JOIN agents a ON a.agent_id = t.agent_id
GROUP BY a.agent_id, a.first_name, a.last_name
ORDER BY total_volume DESC
LIMIT 10;
