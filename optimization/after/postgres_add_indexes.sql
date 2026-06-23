-- ============================================================
-- after/postgres_add_indexes.sql
--
-- Each index here is justified by a SPECIFIC query from
-- before/postgres_slow_queries.sql -- not added speculatively.
-- "Index everything" is a beginner mistake: every index speeds
-- up reads but slows down writes (INSERT/UPDATE/DELETE must
-- maintain it) and consumes storage. Good indexing is targeted.
-- ============================================================

-- Justifies Query 1 (filter by agent_id) and Query 5 (GROUP BY agent_id)
CREATE INDEX idx_transactions_agent_id ON transactions(agent_id);

-- Justifies Query 2 (range filter + ORDER BY on sale_date).
-- A single index serves both the WHERE and the ORDER BY here,
-- since B-tree indexes are naturally sorted.
CREATE INDEX idx_transactions_sale_date ON transactions(sale_date);

-- Justifies Query 3 (lookups by buyer_party_id or seller_party_id).
-- Two separate indexes, not one combined index -- because the
-- query restructuring (see below) looks each one up independently.
CREATE INDEX idx_transactions_buyer_party_id ON transactions(buyer_party_id);
CREATE INDEX idx_transactions_seller_party_id ON transactions(seller_party_id);

-- Justifies Query 4 (filter + sort by sale_price).
CREATE INDEX idx_transactions_sale_price ON transactions(sale_price);

-- Justifies Query 4's join from transaction_payments back to transactions.
-- transaction_id is already UNIQUE (and thus indexed) from the schema,
-- so no new index needed here -- worth noting in the README that we
-- checked rather than blindly added one.

-- Justifies Query 1's join from transactions to properties.
-- property_id is the PRIMARY KEY on properties (already indexed),
-- but transactions.property_id itself has no index yet, and several
-- dashboard queries filter by property too -- add it for completeness.
CREATE INDEX idx_transactions_property_id ON transactions(property_id);

\echo 'Strategic indexes added to PostgreSQL.'
