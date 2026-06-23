-- ============================================================
-- audit/demo_audit.sql (run against either database -- syntax
-- shown here is PostgreSQL; see notes for MySQL equivalents)
--
-- Proves the audit engine captures every mutation type.
-- ============================================================

-- ---- 1. Pick an existing payment row and update its status ----
-- (use a real payment_id from your loaded data -- e.g. 1)
UPDATE transaction_payments
SET payment_status = 'cleared'
WHERE payment_id = 1;

-- ---- 2. Check the audit log captured it ----
SELECT audit_id, operation, row_id, old_data->>'payment_status' AS old_status,
       new_data->>'payment_status' AS new_status, changed_at
FROM audit_log
WHERE table_name = 'transaction_payments' AND row_id = 1
ORDER BY changed_at DESC
LIMIT 5;
-- Expected: an UPDATE row showing old_status vs new_status, proving
-- both before-and-after states were captured.

-- ---- 3. Try deleting a payment record ----
-- (pick a payment_id that won't break a foreign key elsewhere --
--  in this schema transaction_payments has no children, so any
--  payment_id is safe to delete for this demo)
DELETE FROM transaction_payments WHERE payment_id = 2;

-- ---- 4. Confirm the DELETE was logged with the full old row preserved ----
SELECT audit_id, operation, row_id, old_data, changed_at
FROM audit_log
WHERE table_name = 'transaction_payments' AND row_id = 2 AND operation = 'DELETE';
-- Expected: one row, old_data containing the full deleted record
-- (deposit_amount, financed_amount, etc.) even though the original
-- row is now gone from transaction_payments entirely. This is the
-- "full audit visibility" the resume bullet refers to -- the data
-- survives in the log even after deletion from the live table.

-- MySQL equivalent for step 2 (no ->> operator; use JSON_EXTRACT):
-- SELECT audit_id, operation, row_id,
--        JSON_EXTRACT(old_data, '$.payment_status') AS old_status,
--        JSON_EXTRACT(new_data, '$.payment_status') AS new_status, changed_at
-- FROM audit_log
-- WHERE table_name = 'transaction_payments' AND row_id = 1
-- ORDER BY changed_at DESC LIMIT 5;
