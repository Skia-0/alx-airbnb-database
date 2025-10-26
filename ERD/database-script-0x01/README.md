# 📘 Database Script 0x01 — Schema Definition

## Objective
Define the SQL schema for the AirBnB-style relational database.

## Description
This script (`schema.sql`) creates all entities (User, Property, Booking, Payment, Review, Message) and defines:
- Primary keys (`UUID`)
- Foreign keys with cascading deletes
- Proper data types
- ENUM constraints for roles, statuses, and payment methods
- Indexes for frequent lookups

## How to Use
1. Open your SQL client (e.g., MySQL, PostgreSQL).
2. Create a new database, e.g.:
   ```sql
   CREATE DATABASE airbnb_clone;

