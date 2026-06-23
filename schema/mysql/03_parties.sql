CREATE TABLE parties (
    party_id    INT AUTO_INCREMENT PRIMARY KEY,
    full_name   VARCHAR(150) NOT NULL,
    email       VARCHAR(120) NOT NULL UNIQUE,
    phone       VARCHAR(20) NOT NULL,
    party_type  VARCHAR(20) NOT NULL DEFAULT 'individual',
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_party_type CHECK (party_type IN ('individual', 'company'))
) ENGINE=InnoDB COMMENT='Anyone who can buy or sell property. Role is per-transaction, not stored here.';
