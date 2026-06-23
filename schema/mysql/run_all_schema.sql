-- ============================================================
-- run_all_schema.sql (MySQL)
-- Usage: mysql -u root -p sales_log < schema/mysql/run_all_schema.sql
-- (MySQL's "source" command works too, run from inside the mysql shell:)
--   SOURCE schema/mysql/run_all_schema.sql;
-- ============================================================

SOURCE schema/mysql/01_properties.sql;
SOURCE schema/mysql/02_agents.sql;
SOURCE schema/mysql/03_parties.sql;
SOURCE schema/mysql/04_transactions.sql;
SOURCE schema/mysql/05_transaction_payments.sql;

SELECT 'MySQL schema (unindexed baseline) created.' AS status;
