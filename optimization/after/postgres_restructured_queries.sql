-- ============================================================
-- after/postgres_restructured_queries.sql
--
-- These are the SAME queries as before/postgres_slow_queries.sql,
-- but rewritten to actually take advantage of the new indexes.
-- Query 3 in particular needed restructuring, not just an index --
-- this is the difference between "indexing" and "query
-- restructuring" as two distinct optimization techniques.
-- ============================================================

-- ---- Query 1 (unchanged SQL, now backed by idx_transactions_agent_id) ----
EXPLAIN ANALYZE
SELECT t.transaction_id, t.sale_date, t.sale_price, p.address
FROM transactions t
JOIN properties p ON p.property_id = t.property_id
WHERE t.agent_id = 23;

-- ---- Query 2 (unchanged SQL, now backed by idx_transactions_sale_date) ----
EXPLAIN ANALYZE
SELECT transaction_id, sale_date, sale_price
FROM transactions
WHERE sale_date BETWEEN '2026-01-01' AND '2026-03-31'
ORDER BY sale_date;

-- ---- Query 3: RESTRUCTURED ----
-- The original used "WHERE buyer_party_id = X OR seller_party_id = X".
-- A single index can't efficiently serve an OR across two different
-- columns -- the planner often falls back to a full scan anyway,
-- even with both columns indexed individually.
--
-- The fix: split into two separate indexed lookups (one against
-- buyer_party_id, one against seller_party_id) and combine with
-- UNION ALL. Each half can now use its own index independently,
-- and UNION ALL (not UNION) avoids an unnecessary de-duplication
-- pass, since a transaction_id can't appear in both halves anyway
-- (buyer_party_id <> seller_party_id is already enforced by a
-- CHECK constraint on the table).
EXPLAIN ANALYZE
SELECT transaction_id, sale_date, sale_price, 'buyer' AS role
FROM transactions
WHERE buyer_party_id = 1500
UNION ALL
SELECT transaction_id, sale_date, sale_price, 'seller' AS role
FROM transactions
WHERE seller_party_id = 1500;

-- ---- Query 4 (unchanged SQL, now backed by idx_transactions_sale_price) ----
EXPLAIN ANALYZE
SELECT t.transaction_id, t.sale_price, tp.payment_status, tp.financed_amount
FROM transactions t
JOIN transaction_payments tp ON tp.transaction_id = t.transaction_id
WHERE t.sale_price > 500000
ORDER BY t.sale_price DESC;

-- ---- Query 5 (unchanged SQL, now backed by idx_transactions_agent_id) ----
EXPLAIN ANALYZE
SELECT a.agent_id, a.first_name, a.last_name,
       COUNT(*) AS deal_count, SUM(t.sale_price) AS total_volume
FROM transactions t
JOIN agents a ON a.agent_id = t.agent_id
GROUP BY a.agent_id, a.first_name, a.last_name
ORDER BY total_volume DESC
LIMIT 10;
