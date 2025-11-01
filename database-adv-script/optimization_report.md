# optimization_report.md

## Objective
Refactor a complex booking query to improve performance, measure before/after using `EXPLAIN ANALYZE`, and apply practical optimizations and indexes.

---

## 1) Baseline query summary
- Baseline query joined `bookings` → `users` → `properties` and `payments` with a LEFT JOIN.
- Problems often observed:
  - **Row multiplication** when a booking has multiple payments (LEFT JOIN payments produces multiple rows per booking).
  - **Selecting many columns** (unnecessary I/O).
  - **ORDER BY** on `bookings.created_at` without an index → sequential scan + sort.
  - No early filtering: database must join large tables before applying LIMIT/ORDER.

---

## 2) Key inefficiencies to look for in EXPLAIN output
- `Seq Scan` on large tables instead of `Index Scan`.
- Large **actual time**, high **I/O** and many **buffers** read.
- `Hash Join`/`Nested Loop` with large build side due to lack of proper indexes.
- Large **Rows Removed by Filter** or repeated rows due to joining non-aggregated payments.

---

## 3) Refactoring actions applied
1. **Limit the working set early** using a CTE (`recent_bookings`) that filters bookings to a recent window and/or pages the data (helps planners choose index scans).
2. **Avoid join multiplicity** by retrieving the latest payment per booking using a `LATERAL` subquery (returns single row per booking).
3. **Select only necessary columns** rather than `SELECT *`.
4. **Recommend and create indexes** (see next section) so the planner can use index scans and avoid sorting large sets.

---

## 4) Recommended indexes (run these before the optimized EXPLAIN)
Run these in psql (or your DB client). They are idempotent (`IF NOT EXISTS`) for safety.

```sql
-- bookings: used in WHERE and ORDER BY and joins
CREATE INDEX IF NOT EXISTS idx_bookings_user_id       ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id   ON bookings(property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_start_date    ON bookings(start_date);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at    ON bookings(created_at);

-- payments: used to fetch latest payment per booking (index on booking_id + payment_date)
CREATE INDEX IF NOT EXISTS idx_payments_booking_date  ON payments(booking_id, payment_date DESC);

-- users/properties: typical join keys
CREATE INDEX IF NOT EXISTS idx_users_user_id          ON users(user_id);
CREATE INDEX IF NOT EXISTS idx_properties_property_id ON properties(property_id);
CREATE INDEX IF NOT EXISTS idx_properties_location    ON properties(location);
