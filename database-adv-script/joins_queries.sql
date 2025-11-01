

-- 1) INNER JOIN: retrieve all bookings and the users who made them
-- Returns booking fields plus user fields; only bookings that have a matching user.
SELECT
  b.booking_id,
  b.property_id,
  b.start_date,
  b.end_date,
  b.status AS booking_status,
  u.user_id AS user_id,
  u.first_name,
  u.last_name,
  u.email
FROM bookings b
INNER JOIN users u
  ON b.user_id = u.user_id
ORDER BY b.created_at DESC;


-- 2) LEFT JOIN: retrieve all properties and their reviews (includes properties with no reviews)
-- Returns one row per review; properties with no reviews will have NULL review_* fields.
SELECT
  p.property_id,
  p.name AS property_name,
  p.location,
  r.review_id,
  r.user_id   AS reviewer_id,
  r.rating,
  r.comment,
  r.created_at AS review_created_at
FROM properties p
LEFT JOIN reviews r
  ON p.property_id = r.property_id
ORDER BY p.property_id, r.created_at ASC;




-- 3) FULL OUTER JOIN: retrieve all users and all bookings, even if unmatched
-- Note: FULL OUTER JOIN returns rows where a user has no bookings and bookings without a linked user.
-- Use COALESCE to prefer user fields when present.
SELECT
  COALESCE(u.user_id, NULL)             AS user_id,
  u.first_name,
  u.last_name,
  b.booking_id,
  b.property_id,
  b.start_date,
  b.end_date,
  b.status AS booking_status
FROM users u
FULL OUTER JOIN bookings b
  ON u.user_id = b.user_id
ORDER BY COALESCE(u.user_id::text, b.booking_id::text);
