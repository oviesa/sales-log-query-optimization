-- ============================================================
-- run_all_audit.sql (MySQL)
-- Usage (from inside the mysql shell, connected to sales_log):
--   SOURCE audit/mysql/run_all_audit.sql;
-- ============================================================

SOURCE audit/mysql/01_audit_log_table.sql;
SOURCE audit/mysql/02_audit_triggers.sql;

SELECT 'Audit logging engine installed (MySQL).' AS status;
