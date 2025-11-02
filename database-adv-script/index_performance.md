# Index performance measurement

## Objective
Measure query performance **before** and **after** adding indexes using `EXPLAIN`/`EXPLAIN ANALYZE` and record the results.

---

## Files
- `database_index.sql` — index creation script (idempotent).
- This file (`index_performance.md`) — measurement instructions and result template.

---

## Measurement workflow (exact commands)

### 1) Pick the queries you want to measure
Example queries (copy & paste to run):

**Q1 — Bookings by user**
```sql
SELECT * FROM bookings WHERE user_id = '<SOME_USER_UUID>';
