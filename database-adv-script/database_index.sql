-- database_index.sql
-- Idempotent index creation for users, bookings, properties (PostgreSQL / adjust for MySQL)
-- Run this AFTER capturing BEFORE measurements.

-- USERS
CREATE INDEX IF NOT EXISTS idx_users_email_lower ON users (lower(email));
CREATE INDEX IF NOT EXISTS idx_users_role ON users (role);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users (created_at);

-- BOOKINGS
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings (user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON bookings (property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_start_date ON bookings (start_date);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings (created_at);
CREATE INDEX IF NOT EXISTS idx_bookings_status_start ON bookings (status, start_date);

-- PROPERTIES
CREATE INDEX IF NOT EXISTS idx_properties_host_id ON properties (host_id);
CREATE INDEX IF NOT EXISTS idx_properties_location ON properties (location);
CREATE INDEX IF NOT EXISTS idx_properties_price ON properties (price_per_night);

-- Full-text search (Postgres example). Uncomment if your DB supports it and you want FTS:
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- CREATE INDEX IF NOT EXISTS idx_properties_search_tsv ON properties USING GIN (to_tsvector('english', coalesce(name,'') || ' ' || coalesce(description,'')));
