-- partitioning.sql

-- 1) Create new partitioned parent table (same columns as existing bookings)
-- Adjust column definitions to match your current bookings table exactly.
BEGIN;

-- If a partitioned table already exists, skip creation (safety).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = 'bookings_partitioned' AND n.nspname = 'public'
  ) THEN
    CREATE TABLE bookings_partitioned (
      booking_id UUID NOT NULL,
      property_id UUID NOT NULL,
      user_id UUID NOT NULL,
      start_date DATE NOT NULL,
      end_date DATE NOT NULL,
      status TEXT,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
      -- add any other columns from your bookings table here
      PRIMARY KEY (booking_id, start_date)  -- composite PK is optional; adjust as needed
    ) PARTITION BY RANGE (start_date);
  END IF;
END$$;

-- 2) Create monthly partitions for a range of dates (adjust start/end as needed)
-- This block creates partitions from 2024-01-01 up to 2026-01-01 (change to cover your data)
DO $$
DECLARE
  start_month DATE := DATE '2024-01-01';
  end_month   DATE := DATE '2026-01-01';
  m DATE;
  part_name TEXT;
BEGIN
  m := start_month;
  WHILE m < end_month LOOP
    part_name := format('bookings_p_%s', to_char(m, 'YYYY_MM'));
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = part_name) THEN
      EXECUTE format($sql$
        CREATE TABLE %I PARTITION OF bookings_partitioned
        FOR VALUES FROM (%L) TO (%L)
      $sql$, part_name, m::text, (m + INTERVAL '1 month')::date::text);
    END IF;
    m := m + INTERVAL '1 month';
  END LOOP;

  -- default partition for future/older dates (optional)
  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'bookings_p_default') THEN
    EXECUTE 'CREATE TABLE bookings_p_default PARTITION OF bookings_partitioned DEFAULT';
  END IF;
END$$;

-- 3) Create indexes on each partition (composite/indexes useful for your queries)
-- Create indexes for typical lookups: user_id, property_id, start_date
-- Note: index must be created on each partition; create for existing ones via dynamic SQL
DO $$
DECLARE
  r RECORD;
  idx_sql TEXT;
BEGIN
  FOR r IN
    SELECT relname FROM pg_class
    WHERE relname LIKE 'bookings_p_%'
  LOOP
    -- index on user_id
    idx_sql := format('CREATE INDEX IF NOT EXISTS idx_%s_user_id ON %I (user_id);', r.relname, r.relname);
    EXECUTE idx_sql;
    -- index on property_id
    idx_sql := format('CREATE INDEX IF NOT EXISTS idx_%s_property_id ON %I (property_id);', r.relname, r.relname);
    EXECUTE idx_sql;
    -- index on start_date (may be redundant since partition key but helpful for some plans)
    idx_sql := format('CREATE INDEX IF NOT EXISTS idx_%s_start_date ON %I (start_date);', r.relname, r.relname);
    EXECUTE idx_sql;
    -- index on created_at for ordering recent
    idx_sql := format('CREATE INDEX IF NOT EXISTS idx_%s_created_at ON %I (created_at DESC);', r.relname, r.relname);
    EXECUTE idx_sql;
  END LOOP;
END$$;

COMMIT;

-- 4) DATA MIGRATION: copy existing data from bookings into partitions
-- Approach: insert into bookings_partitioned SELECT * FROM bookings;
-- Use transaction and test on small dataset first.

-- Important: ensure column order and names match between bookings and bookings_partitioned.
-- Example migration (run when ready):
-- INSERT INTO bookings_partitioned (booking_id, property_id, user_id, start_date, end_date, status, created_at)
-- SELECT booking_id, property_id, user_id, start_date, end_date, status, created_at FROM bookings;

-- If any rows fail due to range / constraint, investigate and handle (e.g., move to default partition).

-- 5) After data copied and validated:
-- - Drop or rename the old bookings table (do this only after backup and validation)
--   ALTER TABLE bookings RENAME TO bookings_old;
--   ALTER TABLE bookings_partitioned RENAME TO bookings;
-- - Recreate foreign keys referencing bookings (you may need to re-add FKs against partitions or parent table)
-- - Recreate triggers, sequences, permissions as needed.

-- 6) Test queries (AFTER migration) - run these EXPLAIN ANALYZE to measure improvement
-- Example: fetch bookings within a month (should do partition pruning)
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT b.booking_id, b.user_id, b.property_id, b.start_date, p.name
FROM bookings_partitioned b
JOIN properties p ON p.property_id = b.property_id
WHERE b.start_date BETWEEN '2025-06-01' AND '2025-06-30';

-- Compare the output of the above AFTER with the BEFORE run on the old table.
-- Check for "Partition Pruning" in the plan and for index scans instead of seq scans.

-- 7) Optional: function to add new monthly partition (for future automation)
CREATE OR REPLACE FUNCTION create_bookings_month_partition(p_month DATE) RETURNS void AS $$
DECLARE
  part_name TEXT := format('bookings_p_%s', to_char(p_month, 'YYYY_MM'));
BEGIN
  EXECUTE format('CREATE TABLE IF NOT EXISTS %I PARTITION OF bookings_partitioned FOR VALUES FROM (%L) TO (%L)',
                 part_name, p_month::text, (p_month + INTERVAL ''1 month'')::date::text);
  -- create indexes on the new partition
  EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_user_id ON %I (user_id);', part_name, part_name);
  EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_property_id ON %I (property_id);', part_name, part_name);
  EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_start_date ON %I (start_date);', part_name, part_name);
  EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_created_at ON %I (created_at DESC);', part_name, part_name);
END;
$$ LANGUAGE plpgsql;


