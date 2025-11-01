# Partition performance report — bookings (start_date RANGE partitioning)

## Objective
Partition `bookings` by `start_date` (monthly partitions) to improve query performance on date-range queries and reduce I/O for recent-range lookups.

---

## Steps performed
1. Captured baseline plan and timings:
   - Example baseline query used:
     ```
     EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
     SELECT * FROM bookings WHERE start_date BETWEEN '2025-06-01' AND '2025-06-30';
     ```
   - Saved output to `before_explain.txt`.

2. Created partitioned parent table `bookings_partitioned` and monthly partitions (2024-01 through 2025-12), plus default partition for out-of-range data. (See `partitioning.sql`.)

3. Created per-partition indexes on `user_id`, `property_id`, `start_date`, and `created_at DESC`.

4. Migrated data from `bookings` → `bookings_partitioned` (INSERT ... SELECT). Validated row counts and spot-checked records.

5. Swapped tables (renamed old table to `bookings_old`, renamed partitioned table to `bookings`) after validation.

6. Ran `ANALYZE;` to refresh planner statistics.

7. Executed the same test query(s) and saved the AFTER plan to `after_explain.txt`.

---

## Measurements (how to capture & what to compare)
For each test query capture:
- `Planning Time` (ms)
- `Execution Time` / `Actual Total Time` (ms)
- Whether the plan shows **Partition Pruning** (only a subset of partitions scanned)
- Presence of `Index Scan` vs `Seq Scan`
- Buffers: `shared hit` vs `read`

Recommended commands:
```sql
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) <your query>;
SELECT * FROM pg_stat_user_tables WHERE relname LIKE 'bookings%';
SELECT * FROM pg_stat_user_indexes WHERE relname LIKE 'bookings%';




---

### Final guidance (concise)
- Paste `partitioning.sql` and run: first run the BEFORE EXPLAINs, then run the script (or parts of it), migrate data, run `ANALYZE`, and then AFTER EXPLAINs.
- Save `before_explain.txt` and `after_explain.txt` and paste both here — I’ll read them and tell you exactly what changed and what to tune further.

If you want, I can also:
- produce a small script to create yearly partitions instead of monthly,
- or provide a fast-safe migration recipe that uses `pg_dump`/`pg_restore` (if dataset is huge).

Which of those (monthly→yearly or migration via dump) do you want next?
