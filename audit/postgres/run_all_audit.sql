-- ============================================================
-- run_all_audit.sql (PostgreSQL)
-- Usage: psql -U postgres -d sales_log -f audit/postgres/run_all_audit.sql
-- ============================================================

\i audit/postgres/01_audit_log_table.sql
\i audit/postgres/02_audit_triggers.sql

\echo 'Audit logging engine installed (PostgreSQL).'
