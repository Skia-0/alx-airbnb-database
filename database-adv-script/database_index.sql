-- database_index.sql
-- Full sheet: BEFORE EXPLAIN ANALYZE, index creation, ANALYZE, AFTER EXPLAIN ANALYZE
-- Paste this file into alx-airbnb-database/database-adv-script/database_index.sql

-- ========== SECTION: BEFORE (baseline measurements) ==========
-- Run these first (they will display BEFORE plans when this file is executed)

-- Query 1: bookings in a date range (baseline)
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT b.booking_id, b.start_date, p.property_id, p.name
FROM bookings b
JOIN properties p ON p.property_id = b.property_id
WHERE b.start_date BETWEEN '2025-06-01' AND '2025-06-30'
ORDER BY b.created_at DESC
LIMIT 100;

-- Query 2: bookings by a user (replace the UUID as needed)
-- If you don't have a specific UUID, use a real id from your DB or keep example to run
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM bookings
WHERE user_id = '00000000-0000-0000-0000-000000000000';

-- Query 3: properties by location and price
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM properties
WHERE location = 'Accra' AND price_per_night <= 300;

-- ========== SECTION: CREATE INDEXES ==========
-- Create indexes (idempotent) — adjust names if your DB is MySQL (remove lower() use)
CREATE INDEX IF NOT EXISTS idx_users_email_lower ON users (lower(email));
CREATE INDEX IF NOT EXISTS idx_users_role ON users (role);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users (created_at);

CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings (user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON bookings (property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_start_date ON bookings (start_date);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings (created_at);
CREATE INDEX IF NOT EXISTS idx_bookings_status_start ON bookings (status, start_date);

CREATE INDEX IF NOT EXISTS idx_properties_host_id ON properties (host_id);
CREATE INDEX IF NOT EXISTS idx_properties_location ON properties (location);
CREATE INDEX IF NOT EXISTS idx_properties_price ON properties (price_per_night);

-- Update planner statistics
ANALYZE;

-- ========== SECTION: AFTER (post-index measurements) ==========
-- Re-run the exact same EXPLAIN ANALYZE queries to capture AFTER outcome

-- Query 1: bookings in a date range (after indexes)
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT b.booking_id, b.start_date, p.property_id, p.name
FROM bookings b
JOIN properties p ON p.property_id = b.property_id
WHERE b.start_date BETWEEN '2025-06-01' AND '2025-06-30'
ORDER BY b.created_at DESC
LIMIT 100;

-- Query 2: bookings by a user (after indexes)
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM bookings
WHERE user_id = '00000000-0000-0000-0000-000000000000';

-- Query 3: properties by location and price (after indexes)
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM properties
WHERE location = 'Accra' AND price_per_night <= 300;

-- End of file
