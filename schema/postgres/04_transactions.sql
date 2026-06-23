-- ============================================================
-- Table: transactions
-- The core fact table -- one row per property sale.
-- NOTE: intentionally no indexes on the FK columns here yet.
-- In a real unindexed system, queries filtering/joining on
-- buyer_party_id, seller_party_id, agent_id, property_id, or
-- sale_date will be forced into full table scans. That's the
-- bottleneck this project audits and then fixes.
-- ============================================================

CREATE TABLE transactions (
    transaction_id    SERIAL PRIMARY KEY,
    property_id        INT NOT NULL REFERENCES properties(property_id),
    agent_id            INT NOT NULL REFERENCES agents(agent_id),
    buyer_party_id      INT NOT NULL REFERENCES parties(party_id),
    seller_party_id     INT NOT NULL REFERENCES parties(party_id),
    sale_date            DATE NOT NULL,
    sale_price            NUMERIC(12,2) NOT NULL CHECK (sale_price > 0),
    created_at            TIMESTAMP NOT NULL DEFAULT NOW(),

    CHECK (buyer_party_id <> seller_party_id)
);

COMMENT ON TABLE transactions IS 'One row per property sale. Intentionally unindexed on FK columns and sale_date for the audit phase of this project.';
