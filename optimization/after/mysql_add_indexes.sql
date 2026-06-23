-- ============================================================
-- after/mysql_add_indexes.sql
--
-- NOTE: InnoDB auto-indexes foreign key columns, so agent_id,
-- buyer_party_id, seller_party_id, and property_id on
-- transactions may ALREADY have indexes from the FK constraints
-- in schema/mysql/04_transactions.sql -- this is a key difference
-- from Postgres, where FK columns are NOT auto-indexed. Check
-- with `SHOW INDEX FROM transactions;` before assuming you need
-- to add these.
--
-- sale_date and sale_price are NOT foreign keys, so they
-- definitely need explicit indexes added here.
-- ============================================================

-- Confirm existing indexes first (run this and inspect output):
SHOW INDEX FROM transactions;

-- These two are NOT covered by any FK constraint -- definitely needed:
CREATE INDEX idx_transactions_sale_date ON transactions(sale_date);
CREATE INDEX idx_transactions_sale_price ON transactions(sale_price);

-- If SHOW INDEX above did NOT show agent_id/buyer_party_id/seller_party_id/
-- property_id already indexed (depends on your MySQL version/config),
-- uncomment and run these:
-- CREATE INDEX idx_transactions_agent_id ON transactions(agent_id);
-- CREATE INDEX idx_transactions_buyer_party_id ON transactions(buyer_party_id);
-- CREATE INDEX idx_transactions_seller_party_id ON transactions(seller_party_id);
-- CREATE INDEX idx_transactions_property_id ON transactions(property_id);

SELECT 'Strategic indexes added to MySQL.' AS status;
