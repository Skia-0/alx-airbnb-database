# normalization.md

## Objective
Apply normalization principles and show that the AirBnB schema is in Third Normal Form (3NF). Identify any violations, fix the design, and document the steps.

---

## Short conclusion
The schema is 3NF-compliant after removing the single transitive/derived attribute: **`bookings.total_price`**. Pricing should be computed on-demand or captured in a separate snapshot table for immutable historical records.

---

## Analysis (table-by-table)

### users
- PK: `user_id`. All attributes (first_name, last_name, email, role, etc.) depend only on `user_id`.
- 1NF, 2NF, 3NF: **OK**

### properties
- PK: `property_id`. Attributes (name, description, location, price_per_night, host_id) depend only on `property_id`.
- `host_id` is an FK to `users` (not a transitive dependency).
- 1NF, 2NF, 3NF: **OK**

### bookings
- PK: `booking_id`. Attributes: `property_id`, `user_id`, `start_date`, `end_date`, `status`, `created_at`.
- **Issue identified:** `total_price` (if present) is **derived** from `properties.price_per_night * nights` and thus depends on a non-key attribute of another table → **transitive dependency** → violates 3NF.
- **Fix applied:** **Remove `total_price` from `bookings`**. Compute when needed, or store snapshots elsewhere.

### payments
- PK: `payment_id`. Attributes depend on `payment_id`. `booking_id` is FK.
- Business rule: `UNIQUE(booking_id)` enforces one-payment-per-booking (not a normalization issue).
- 1NF, 2NF, 3NF: **OK**

### reviews
- PK: `review_id`. Attributes depend on `review_id`. FKs to `properties` and `users`.
- 1NF, 2NF, 3NF: **OK**

### messages
- PK: `message_id`. `sender_id` and `recipient_id` are FKs to `users`. No transitive dependencies.
- 1NF, 2NF, 3NF: **OK**

---

## Verification of 3NF compliance

The schema created in step 3 already satisfies Third Normal Form.  
Each table has:
- A single primary key identifying each record.
- Attributes that depend only on that key.
- No derived or transitive dependencies.

No changes were required to achieve 3NF, as the schema was designed with normalization in mind from the start.
