

-- 1) Total number of bookings made by each user (COUNT + GROUP BY)
-- Returns user_id and total_bookings (0 users without bookings will be omitted)
SELECT
  u.user_id,
  u.first_name,
  u.last_name,
  COUNT(b.booking_id) AS total_bookings
FROM users u
LEFT JOIN bookings b
  ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_bookings DESC;


-- 2) Rank properties by total number of bookings using a window function
-- We'll compute bookings_per_property then apply ROW_NUMBER() and RANK()
WITH property_bookings AS (
  SELECT
    p.property_id,
    p.name AS property_name,
    COUNT(b.booking_id) AS bookings_count
  FROM properties p
  LEFT JOIN bookings b ON p.property_id = b.property_id
  GROUP BY p.property_id, p.name
)
SELECT
  property_id,
  property_name,
  bookings_count,
  ROW_NUMBER() OVER (ORDER BY bookings_count DESC)       AS row_number_rank,
  RANK()       OVER (ORDER BY bookings_count DESC)       AS rank_with_ties,
  DENSE_RANK() OVER (ORDER BY bookings_count DESC)       AS dense_rank_with_ties
FROM property_bookings
ORDER BY bookings_count DESC, property_id;
