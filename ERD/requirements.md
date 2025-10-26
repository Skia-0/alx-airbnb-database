# requirements.md


### users
- user_id (PK, UUID, indexed)
- first_name (VARCHAR, NOT NULL)
- last_name (VARCHAR, NOT NULL)
- email (VARCHAR, UNIQUE, NOT NULL)
- password_hash (VARCHAR, NOT NULL)
- phone_number (VARCHAR, NULL)
- role (ENUM: guest, host, admin)
- created_at (TIMESTAMPTZ, DEFAULT CURRENT_TIMESTAMP)

### properties
- property_id (PK, UUID, indexed)
- host_id (FK → users.user_id)
- name (VARCHAR, NOT NULL)
- description (TEXT, NOT NULL)
- location (VARCHAR, NOT NULL)
- price_per_night (NUMERIC, NOT NULL)
- created_at (TIMESTAMPTZ, DEFAULT CURRENT_TIMESTAMP)
- updated_at (TIMESTAMPTZ, auto-updated)

### bookings
- booking_id (PK, UUID, indexed)
- property_id (FK → properties.property_id)
- user_id (FK → users.user_id)
- start_date (DATE, NOT NULL)
- end_date (DATE, NOT NULL)
- status (ENUM: pending, confirmed, canceled)
- created_at (TIMESTAMPTZ, DEFAULT CURRENT_TIMESTAMP)


### payments
- payment_id (PK, UUID, indexed)
- booking_id (FK → bookings.booking_id)
- amount (NUMERIC, NOT NULL)
- payment_date (TIMESTAMPTZ, DEFAULT CURRENT_TIMESTAMP)
- payment_method (ENUM: credit_card, paypal, stripe)

### reviews
- review_id (PK, UUID, indexed)
- property_id (FK → properties.property_id)
- user_id (FK → users.user_id)
- rating (INTEGER, CHECK 1–5)
- comment (TEXT, NOT NULL)
- created_at (TIMESTAMPTZ, DEFAULT CURRENT_TIMESTAMP)

### messages
- message_id (PK, UUID, indexed)
- sender_id (FK → users.user_id)
- recipient_id (FK → users.user_id)
- message_body (TEXT, NOT NULL)
- sent_at (TIMESTAMPTZ, DEFAULT CURRENT_TIMESTAMP)

## Relationships
- users → properties : 1-to-many (host owns properties)
- users → bookings : 1-to-many (guest makes bookings)
- properties → bookings : 1-to-many
- bookings → payments : 1-to-1 (business rule; can be changed to 1-to-many)
- users → reviews : 1-to-many
- properties → reviews : 1-to-many
- users → messages : 1-to-many (sender) and 1-to-many (recipient)

## Deliverables (ERD/ folder)
- erd.drawio.xml — editable diagram (diagrams.net)
- erd.svg / erd.png — exported visual
- schema.sql — SQL matching ERD (3NF)
- notes.md — design notes
- normalization.md — normalization analysis and decision

