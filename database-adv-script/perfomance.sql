-- perfomance.sql

EXPLAIN ANALYZE VERBOSE
SELECT
  b.booking_id,
  b.property_id,
  b.user_id,
  b.start_date,
  b.end_date,
  b.status AS booking_status,
  b.created_at AS booking_created_at,
  u.first_name,
  u.last_name,
  u.email,
  p.name AS property_name,
  p.location AS property_location,
  pay.payment_id,
  pay.amount AS payment_amount,
  pay.payment_date
FROM bookings b
JOIN users u ON u.user_id = b.user_id
JOIN properties p ON p.property_id = b.property_id
LEFT JOIN payments pay ON pay.booking_id = b.booking_id
WHERE b.start_date >= CURRENT_DATE - INTERVAL '90 days'
ORDER BY b.created_at DESC
LIMIT 100;


-------------------------
-- 2) OPTIMIZED query (refactored)
-- Improvements applied:
-- - Select only required columns (avoid SELECT *).
-- - Pre-filter bookings first (smaller working set).
-- - Use LATERAL subquery to fetch the latest payment per booking (avoids row multiplication).
-- - Ensure ORDER BY uses an indexed column (booking_created_at index recommended).
EXPLAIN ANALYZE VERBOSE
WITH recent_bookings AS (
  SELECT booking_id, property_id, user_id, start_date, end_date, status, created_at
  FROM bookings
  WHERE start_date >= CURRENT_DATE - INTERVAL '90 days'
  ORDER BY created_at DESC
  LIMIT 1000    -- reduce initial working set (adjust for your pagination logic)
)
SELECT
  b.booking_id,
  b.property_id,
  b.user_id,
  b.start_date,
  b.end_date,
  b.status AS booking_status,
  b.created_at AS booking_created_at,
  u.first_name,
  u.last_name,
  u.email,
  p.name AS property_name,
  p.location AS property_location,
  latest_pay.payment_id,
  latest_pay.amount     AS payment_amount,
  latest_pay.payment_date
FROM recent_bookings b
JOIN users u ON u.user_id = b.user_id
JOIN properties p ON p.property_id = b.property_id
LEFT JOIN LATERAL (
  SELECT payment_id, amount, payment_date
  FROM payments pay
  WHERE pay.booking_id = b.booking_id
  ORDER BY payment_date DESC
  LIMIT 1
) latest_pay ON TRUE
ORDER BY b.created_at DESC
LIMIT 100;


