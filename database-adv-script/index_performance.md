# Index performance measurement (full sheet)

## Purpose
Measure query performance **before** and **after** creating indexes using `EXPLAIN ANALYZE` (Postgres) or equivalent. Paste the **exact** EXPLAIN outputs in the slots below.

---

# STEP A — Baseline (BEFORE)

1. Connect to your DB (psql for Postgres). Run the baseline EXPLAIN for each query exactly as shown.

**Command to run for Query 1 (bookings by date range):**
```sql
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT b.booking_id, b.start_date, p.property_id, p.name
FROM bookings b
JOIN properties p ON p.property_id = b.property_id
WHERE b.start_date BETWEEN '2025-06-01' AND '2025-06-30'
ORDER BY b.created_at DESC
LIMIT 100;
