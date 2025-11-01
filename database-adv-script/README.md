# database-adv-script

## Purpose
Practice advanced SQL JOINs for the AirBnB database.

## Files
- `joins_queries.sql` — contains three queries:
  1. **INNER JOIN** — retrieves all bookings and the users who made them.
  2. **LEFT JOIN** — lists all properties and their reviews (includes properties with no reviews).
  3. **FULL OUTER JOIN** — lists all users and all bookings, even if not linked to each other.

## How to Run (PostgreSQL)
1. Ensure your AirBnB database is set up and all tables exist (`users`, `properties`, `bookings`, `reviews`, etc.).
2. Open **psql** or any SQL client connected to your database.
3. Execute the file or paste the queries manually:
   ```sql
   \i path/to/database-adv-script/joins_queries.sql




## Subqueries Practice

### Files
- `subqueries.sql` — contains two types of subqueries:
  1. **Non-correlated subquery:** Finds properties with an average rating greater than 4.0.
  2. **Correlated subquery:** Finds users who have made more than 3 bookings.

### Notes
- These queries depend on the `reviews`, `properties`, `users`, and `bookings` tables.
- Works in PostgreSQL and MySQL with minimal syntax adjustments.
