-- ============================================================
-- Table: transaction_payments
-- Purpose: The SENSITIVE FINANCIAL table this project's audit
-- engine protects. Holds the financial breakdown of each sale.
-- Every INSERT/UPDATE/DELETE here will be captured by triggers
-- into audit_log (see audit/postgres/).
-- ============================================================

CREATE TABLE transaction_payments (
    payment_id        SERIAL PRIMARY KEY,
    transaction_id      INT NOT NULL UNIQUE REFERENCES transactions(transaction_id),
    deposit_amount        NUMERIC(12,2) NOT NULL CHECK (deposit_amount >= 0),
    financed_amount        NUMERIC(12,2) NOT NULL CHECK (financed_amount >= 0),
    closing_costs            NUMERIC(10,2) NOT NULL CHECK (closing_costs >= 0),
    payment_status            VARCHAR(20) NOT NULL DEFAULT 'pending'
                                CHECK (payment_status IN ('pending', 'cleared', 'failed')),
    created_at                TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at                TIMESTAMP NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE transaction_payments IS 'Sensitive financial breakdown per transaction. Protected by audit triggers -- every mutation is logged.';
