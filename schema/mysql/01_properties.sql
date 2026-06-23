-- ============================================================
-- Table: properties (MySQL version)
-- Key differences from Postgres syntax:
--   - AUTO_INCREMENT instead of SERIAL
--   - ENGINE=InnoDB explicitly (needed for foreign key support
--     and triggers -- MySQL's default MyISAM engine doesn't
--     support either)
--   - Table/column comments use COMMENT '...' inline, not a
--     separate COMMENT ON statement
-- ============================================================

CREATE TABLE properties (
    property_id     INT AUTO_INCREMENT PRIMARY KEY,
    address         VARCHAR(200) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    state           VARCHAR(2) NOT NULL,
    zip_code        VARCHAR(10) NOT NULL,
    property_type   VARCHAR(30) NOT NULL,
    square_footage  INT NOT NULL,
    listing_price   DECIMAL(12,2) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_property_type CHECK (property_type IN ('single_family', 'condo', 'townhouse', 'multi_family', 'land')),
    CONSTRAINT chk_square_footage CHECK (square_footage > 0),
    CONSTRAINT chk_listing_price CHECK (listing_price > 0)
) ENGINE=InnoDB COMMENT='Real estate property master record. Intentionally unindexed beyond PK for this project''s audit phase.';
