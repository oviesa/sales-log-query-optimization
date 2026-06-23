-- ============================================================
-- audit/mysql/02_audit_triggers.sql
--
-- MySQL requires one trigger PER event type per table -- it has
-- no equivalent to Postgres's single-function-handles-all-events
-- pattern (no TG_OP). This is a genuine engine limitation worth
-- noting: three triggers here do the job one trigger function
-- did in the Postgres version.
--
-- DELIMITER is changed to // temporarily because trigger bodies
-- contain semicolons internally, which would otherwise be
-- misread by the mysql client as the end of the whole statement.
-- ============================================================

DELIMITER //

CREATE TRIGGER trg_audit_payments_insert
AFTER INSERT ON transaction_payments
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_data, new_data, changed_by)
    VALUES (
        'transaction_payments', 'INSERT', NEW.payment_id,
        NULL,
        JSON_OBJECT(
            'payment_id', NEW.payment_id,
            'transaction_id', NEW.transaction_id,
            'deposit_amount', NEW.deposit_amount,
            'financed_amount', NEW.financed_amount,
            'closing_costs', NEW.closing_costs,
            'payment_status', NEW.payment_status
        ),
        CURRENT_USER()
    );
END//

CREATE TRIGGER trg_audit_payments_update
AFTER UPDATE ON transaction_payments
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_data, new_data, changed_by)
    VALUES (
        'transaction_payments', 'UPDATE', NEW.payment_id,
        JSON_OBJECT(
            'payment_id', OLD.payment_id,
            'transaction_id', OLD.transaction_id,
            'deposit_amount', OLD.deposit_amount,
            'financed_amount', OLD.financed_amount,
            'closing_costs', OLD.closing_costs,
            'payment_status', OLD.payment_status
        ),
        JSON_OBJECT(
            'payment_id', NEW.payment_id,
            'transaction_id', NEW.transaction_id,
            'deposit_amount', NEW.deposit_amount,
            'financed_amount', NEW.financed_amount,
            'closing_costs', NEW.closing_costs,
            'payment_status', NEW.payment_status
        ),
        CURRENT_USER()
    );
END//

CREATE TRIGGER trg_audit_payments_delete
AFTER DELETE ON transaction_payments
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_data, new_data, changed_by)
    VALUES (
        'transaction_payments', 'DELETE', OLD.payment_id,
        JSON_OBJECT(
            'payment_id', OLD.payment_id,
            'transaction_id', OLD.transaction_id,
            'deposit_amount', OLD.deposit_amount,
            'financed_amount', OLD.financed_amount,
            'closing_costs', OLD.closing_costs,
            'payment_status', OLD.payment_status
        ),
        NULL,
        CURRENT_USER()
    );
END//

DELIMITER ;
