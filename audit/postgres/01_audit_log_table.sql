-- ============================================================
-- audit/postgres/01_audit_log_table.sql
--
-- A generic audit log table -- designed to capture mutations
-- from ANY sensitive table, not just transaction_payments,
-- using a single reusable structure. old_data/new_data store
-- the full row as JSON, which means this design doesn't need
-- to change even if transaction_payments' columns change later.
-- ============================================================

CREATE TABLE audit_log (
    audit_id     BIGSERIAL PRIMARY KEY,
    table_name   VARCHAR(100) NOT NULL,
    operation    VARCHAR(10) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    row_id       INT NOT NULL,
    old_data     JSONB,              -- NULL on INSERT (nothing existed before)
    new_data     JSONB,              -- NULL on DELETE (nothing exists after)
    changed_by   VARCHAR(100) NOT NULL DEFAULT CURRENT_USER,
    changed_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Audit logs are queried by table + time range far more often
-- than by audit_id alone -- index for that access pattern.
CREATE INDEX idx_audit_log_table_time ON audit_log(table_name, changed_at);
CREATE INDEX idx_audit_log_row_id ON audit_log(row_id);

COMMENT ON TABLE audit_log IS 'Append-only mutation history for sensitive tables. Populated exclusively by triggers -- never written to directly by application code.';
