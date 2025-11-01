# Performance Monitoring Report

## Objective
Continuously monitor and refine database performance using SQL tools like `EXPLAIN` or `EXPLAIN ANALYZE`.

---

## Step 1: Choose Queries
Pick frequently used queries, e.g.:

```sql
SELECT * FROM bookings WHERE start_date BETWEEN '2025-06-01' AND '2025-06-30';
sql
Copy code
SELECT b.booking_id, u.name, p.name
FROM bookings b
JOIN users u ON b.user_id = u.user_id
JOIN properties p ON b.property_id = p.property_id
WHERE b.start_date >= CURRENT_DATE - INTERVAL '30 days';
Step 2: Baseline (Before Optimization)
Run:

sql
Copy code
EXPLAIN (ANALYZE, BUFFERS)
<your_query_here>;
Note:

Execution time

Scan type (Seq Scan vs Index Scan)

Buffers read

Save output as before_<query>.txt.

Step 3: Identify Bottlenecks
Common issues:

Sequential scan on large tables → missing index

Slow joins → unnecessary data fetched

Large sort cost → missing ORDER BY index

Wrong row estimates → run ANALYZE;

Step 4: Apply Fixes
Examples:

Add Index

sql
Copy code
CREATE INDEX idx_bookings_start_date ON bookings(start_date);
ANALYZE bookings;
Composite Index

sql
Copy code
CREATE INDEX idx_bookings_user_start ON bookings(user_id, start_date);
Partial Index

sql
Copy code
CREATE INDEX idx_confirmed_start ON bookings(start_date)
WHERE status = 'confirmed';
Step 5: Recheck Performance
After change:

sql
Copy code
EXPLAIN (ANALYZE, BUFFERS)
<same_query>;
Save as after_<query>.txt.

Compare “Actual Total Time” and “Scan Type”.

Step 6: Record Results
Query Name	Before (ms)	After (ms)	Scan Type	Notes
Bookings Range	3500	210	Seq → Index	Index + partition improved 90%
User Recent	1800	600	Seq → Index	Reduced buffers by 70%

Step 7: Summary
Observed Improvements:

Reduced query time via proper indexing.

Partitioning boosted date-range queries.

Statistics updated for accurate planning.

Next Steps:

Monitor with pg_stat_statements.

Schedule routine ANALYZE & VACUUM.

Re-review every quarter.
