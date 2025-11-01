

-------------------------
-- DROP PREEXISTING INDEXES (idempotent safety)
-------------------------
DROP INDEX IF EXISTS idx_users_role;
DROP INDEX IF EXISTS idx_users_created_at;
DROP INDEX IF EXISTS idx_bookings_user_id;
DROP INDEX IF EXISTS idx_bookings_property_id;
DROP INDEX IF EXISTS idx_bookings_start_date;
DROP INDEX IF EXISTS idx_bookings_status;
DROP INDEX IF EXISTS idx_bookings_user_start_date;
DROP INDEX IF EXISTS idx_bookings_active_start_date;
DROP INDEX IF EXISTS idx_properties_host_id;
DROP INDEX IF EXISTS idx_properties_location;
DROP INDEX IF EXISTS idx_properties_price_per_night;
DROP INDEX IF EXISTS idx_properties_search_tsv;

-------------------------
-- USERS: common filters/joins/order-bys
-------------------------
-- index by role (filter), and created_at for ordering recent signups
CREATE INDEX IF NOT EXISTS idx_users_role
  ON users(role);

CREATE INDEX IF NOT EXISTS idx_users_created_at
  ON users(created_at);

-- Note: unique index on email should already exist if schema enforced UNIQUE(email).
-- If email searches are case-insensitive frequently, consider:
-- CREATE INDEX idx_users_email_lower ON users (lower(email));

-------------------------
-- BOOKINGS: frequent WHERE, JOIN, ORDER BY columns
-------------------------
CREATE INDEX IF NOT EXISTS idx_bookings_user_id
  ON bookings(user_id);

CREATE INDEX IF NOT EXISTS idx_bookings_property_id
  ON bookings(property_id);

CREATE INDEX IF NOT EXISTS idx_bookings_start_date
  ON bookings(start_date);

-- Composite index if queries often filter by user_id AND start_date:
CREATE INDEX IF NOT EXISTS idx_bookings_user_start_date
  ON bookings(user_id, start_date);

-- Index for status filtering (and optionally date): useful if you query confirmed bookings a lot
CREATE INDEX IF NOT EXISTS idx_bookings_status
  ON bookings(status);

-- Partial index for active/confirmed upcoming bookings (saves space & speeds filtering)
CREATE INDEX IF NOT EXISTS idx_bookings_active_start_date
  ON bookings(start_date)
  WHERE status = 'confirmed';

-------------------------
-- PROPERTIES: search, joins, filters (location, price)
-------------------------
CREATE INDEX IF NOT EXISTS idx_properties_host_id
  ON properties(host_id);

CREATE INDEX IF NOT EXISTS idx_properties_location
  ON properties(location);

CREATE INDEX IF NOT EXISTS idx_properties_price_per_night
  ON properties(price_per_night);

-- Full-text search index (tsvector). Requires privilege to create extension if not present.
-- Use when you run text searches across name/description.
-- You may need to run: CREATE EXTENSION IF NOT EXISTS pg_trgm; (or tsearch2 is built-in)
-- Then:
CREATE INDEX IF NOT EXISTS idx_properties_search_tsv
  ON properties
  USING GIN (to_tsvector('english', coalesce(name,'') || ' ' || coalesce(description,'')));

