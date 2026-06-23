-- ============================================================
-- Table: parties
-- Purpose: Unified table for anyone who can be a buyer or seller
-- in a transaction. See README for the normalization reasoning --
-- a "buyer" and "seller" are ROLES a party plays in a specific
-- transaction, not separate kinds of entity. Modeling them
-- separately would duplicate the same person's data across two
-- tables whenever they buy in one deal and sell in another.
-- ============================================================

CREATE TABLE parties (
    party_id    SERIAL PRIMARY KEY,
    full_name   VARCHAR(150) NOT NULL,
    email       VARCHAR(120) NOT NULL UNIQUE,
    phone       VARCHAR(20) NOT NULL,
    party_type  VARCHAR(20) NOT NULL DEFAULT 'individual'
                    CHECK (party_type IN ('individual', 'company')),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE parties IS 'Anyone who can buy or sell property. Role (buyer/seller) is determined per-transaction, not stored here.';
