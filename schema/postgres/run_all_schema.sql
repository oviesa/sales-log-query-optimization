-- ============================================================
-- run_all_schema.sql (PostgreSQL)
-- Run in dependency order. This creates the UNINDEXED baseline
-- schema -- indexes get added later in optimization/after/.
-- Usage: psql -U postgres -d sales_log -f schema/postgres/run_all_schema.sql
-- ============================================================

\i schema/postgres/01_properties.sql
\i schema/postgres/02_agents.sql
\i schema/postgres/03_parties.sql
\i schema/postgres/04_transactions.sql
\i schema/postgres/05_transaction_payments.sql

\echo 'PostgreSQL schema (unindexed baseline) created.'
