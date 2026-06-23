CREATE TABLE transaction_payments (
    payment_id        INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id      INT NOT NULL UNIQUE,
    deposit_amount        DECIMAL(12,2) NOT NULL,
    financed_amount        DECIMAL(12,2) NOT NULL,
    closing_costs            DECIMAL(10,2) NOT NULL,
    payment_status            VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at                TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_deposit CHECK (deposit_amount >= 0),
    CONSTRAINT chk_financed CHECK (financed_amount >= 0),
    CONSTRAINT chk_closing CHECK (closing_costs >= 0),
    CONSTRAINT chk_payment_status CHECK (payment_status IN ('pending', 'cleared', 'failed')),
    CONSTRAINT fk_payment_txn FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
) ENGINE=InnoDB COMMENT='Sensitive financial breakdown per transaction. Protected by audit triggers.';
