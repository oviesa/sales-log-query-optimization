-- ============================================================
-- audit/postgres/02_audit_triggers.sql
--
-- One generic trigger FUNCTION, attached to transaction_payments
-- for all three mutation types (INSERT/UPDATE/DELETE). This
-- demonstrates handling multiple trigger events in a single
-- function via TG_OP, rather than writing three separate
-- near-duplicate functions.
-- ============================================================

CREATE OR REPLACE FUNCTION fn_audit_transaction_payments()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, operation, row_id, old_data, new_data)
        VALUES ('transaction_payments', 'INSERT', NEW.payment_id, NULL, row_to_json(NEW)::jsonb);
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, operation, row_id, old_data, new_data)
        VALUES ('transaction_payments', 'UPDATE', NEW.payment_id, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb);
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, operation, row_id, old_data, new_data)
        VALUES ('transaction_payments', 'DELETE', OLD.payment_id, row_to_json(OLD)::jsonb, NULL);
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_transaction_payments
    AFTER INSERT OR UPDATE OR DELETE ON transaction_payments
    FOR EACH ROW
    EXECUTE FUNCTION fn_audit_transaction_payments();

COMMENT ON FUNCTION fn_audit_transaction_payments() IS 'Logs every mutation on transaction_payments into audit_log. AFTER trigger -- runs once the change has already succeeded, since we are recording history, not validating the write.';
