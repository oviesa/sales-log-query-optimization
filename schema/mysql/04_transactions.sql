CREATE TABLE transactions (
    transaction_id    INT AUTO_INCREMENT PRIMARY KEY,
    property_id        INT NOT NULL,
    agent_id            INT NOT NULL,
    buyer_party_id      INT NOT NULL,
    seller_party_id     INT NOT NULL,
    sale_date            DATE NOT NULL,
    sale_price            DECIMAL(12,2) NOT NULL,
    created_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_sale_price CHECK (sale_price > 0),
    CONSTRAINT chk_diff_parties CHECK (buyer_party_id <> seller_party_id),
    CONSTRAINT fk_txn_property FOREIGN KEY (property_id) REFERENCES properties(property_id),
    CONSTRAINT fk_txn_agent FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
    CONSTRAINT fk_txn_buyer FOREIGN KEY (buyer_party_id) REFERENCES parties(party_id),
    CONSTRAINT fk_txn_seller FOREIGN KEY (seller_party_id) REFERENCES parties(party_id)
) ENGINE=InnoDB COMMENT='One row per property sale. Intentionally unindexed on FK columns and sale_date for the audit phase.';
