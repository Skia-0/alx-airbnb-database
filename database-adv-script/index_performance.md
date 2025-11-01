# Indexing: database-indexing

## Purpose
Create indexes to speed up high-usage queries on `users`, `bookings`, and `properties`. Provide a repeatable process to measure performance before/after.

## Files
- `database_index.sql` — index creation script with examples for EXPLAIN/ANALYZE.

## Which columns were indexed and why
- users: `role`, `created_at` — used for filters and listing recent users.
- bookings: `user_id`, `property_id`, `start_date`, `status`, composite `user_id,start_date`, partial index on `start_date WHERE status='confirmed'` — used in joins, availability checks and reporting.
- properties: `host_id`, `location`, `price_per_night`, and a GIN tsvector index on `name || description` — speeds filters, geosearch-like queries and full-text search.

## How to measure performance (step-by-step)
1. **Baseline**: run one or more problem queries with:
   ```sql
   EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
   <your SQL query here>;
