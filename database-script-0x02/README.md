# 📘 Database Script 0x02 — Seed Data

## Objective
Provide sample data to test and demonstrate the AirBnB database schema.

## Description
The `seed.sql` script inserts:
- Multiple users (hosts + guests)
- Properties linked to hosts
- Bookings tied to guests
- Payments tied to bookings
- Reviews for completed stays
- Messages between users

## Usage
1. Make sure the database from `schema.sql` already exists.
2. Run the seed script:
   ```sql
   USE airbnb_clone;
   SOURCE path/to/seed.sql;

