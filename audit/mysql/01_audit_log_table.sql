-- ============================================================
-- audit/mysql/01_audit_log_table.sql
--
-- MySQL note: JSON type exists (since 5.7.8) but there's no
-- direct equivalent of Postgres's row_to_json(). We build the
-- JSON manually per-trigger using JSON_OBJECT() instead.
-- ============================================================

CREATE TABLE audit_log (
    audit_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    table_name   VARCHAR(100) NOT NULL,
    operation    VARCHAR(10) NOT NULL,
    row_id       INT NOT NULL,
    old_data     JSON,
    new_data     JSON,
    changed_by   VARCHAR(100) NOT NULL,
    changed_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_operation CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),

    INDEX idx_audit_log_table_time (table_name, changed_at),
    INDEX idx_audit_log_row_id (row_id)
) ENGINE=InnoDB COMMENT='Append-only mutation history for sensitive tables.';
