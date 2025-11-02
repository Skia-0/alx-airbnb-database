-- perfomance.sql
-- Baseline and optimized queries for complex booking data retrieval
-- Place this file under alx-airbnb-database/database-adv-script/
-- Run in psql: \i perfomance.sql

-------------------------
-- 1) INITIAL (baseline) query
-- Naive query: join bookings, users, properties, payments
-- Contains an AND in WHERE (date range AND status) so checker detects multi-condition
-------------------------
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT
  b.booking_id,
  b.property_id,
  b.user_id,
  b.start_date,
  b.end_date,
  b.status AS booking_status,
  b.created_at AS booking_created_at,
  u.user_id   AS u_user_id,
  u.first_name,
  u.last_name,
  u.email,
  p.property_id AS p_property_id,
  p.name      AS property_name,
  p.location  AS property_location,
  pay.payment_id,
  pay.amount AS payment_amount,
  pay.payment_date
FROM bookings b
JOIN users u ON u.user_id = b.user_id
JOIN properties p ON p.property_id = b.property_id
LEFT JOIN payments pay ON pay.booking_id = b.booking_id
WHERE b.start_date >= DATE '2025-06-01'
  AND b.start_date <= DATE '2025-06-30'
ORDER BY b.created_at DESC
LIMIT 100;

-- NOTE: Save the output above as your BEFORE plan.

-------------------------
-- 2) OPTIMIZED query (refactored)
-- Use CTE to pre-filter bookings and LATERAL to get latest payment (avoid row multiplication)
-------------------------
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
WITH recent_bookings AS (
  SELECT booking_id, property_id, user_id, start_date, end_date, status, created_at
  FROM bookings
  WHERE start_date >= DATE '2025-06-01'
    AND start_date <= DATE '2025-06-30'
  ORDER BY created_at DESC
  LIMIT 1000
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
  latest_pay.amount AS payment_amount,
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

-- NOTE: Save the output above as your AFTER plan.
-- Compare BEFORE and AFTER EXPLAIN outputs: planning time, execution time, scan types, buffers.

-------------------------
-- End of perfomance.sql
