-- ============================================================
-- Table: properties
-- NOTE: This schema is intentionally built WITHOUT extra indexes
-- beyond the primary key. The whole point of this project is to
-- audit a database that was deployed without performance tuning,
-- then prove the value of adding indexes. Do not add indexes here
-- -- that happens later, deliberately, in optimization/after/.
-- ============================================================

CREATE TABLE properties (
    property_id     SERIAL PRIMARY KEY,
    address         VARCHAR(200) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    state           VARCHAR(2) NOT NULL,
    zip_code        VARCHAR(10) NOT NULL,
    property_type   VARCHAR(30) NOT NULL
                        CHECK (property_type IN ('single_family', 'condo', 'townhouse', 'multi_family', 'land')),
    square_footage  INT NOT NULL CHECK (square_footage > 0),
    listing_price   NUMERIC(12,2) NOT NULL CHECK (listing_price > 0),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE properties IS 'Real estate property master record. Intentionally unindexed beyond PK for this project''s audit phase.';
