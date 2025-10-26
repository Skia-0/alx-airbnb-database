-- AirBnB Database Sample Data

-- Users
INSERT INTO User (user_id, first_name, last_name, email, password_hash, phone_number, role)
VALUES
(UUID(), 'Kwame', 'Mensah', 'kwame@example.com', 'hash1', '233501234567', 'host'),
(UUID(), 'Akua', 'Boateng', 'akua@example.com', 'hash2', '233502345678', 'guest'),
(UUID(), 'Kojo', 'Appiah', 'kojo@example.com', 'hash3', '233503456789', 'guest');

-- Properties
INSERT INTO Property (property_id, host_id, name, description, location, price_per_night)
SELECT UUID(), u.user_id, 'Cozy Accra Apartment', 'Two-bedroom apartment near airport.', 'Accra', 250.00
FROM User u WHERE u.role = 'host' LIMIT 1;

-- Bookings
INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, status)
SELECT UUID(), p.property_id, u.user_id, '2025-11-01', '2025-11-05', 'confirmed'
FROM Property p, User u
WHERE u.role = 'guest' LIMIT 1;

-- Payments
INSERT INTO Payment (payment_id, booking_id, amount, payment_method)
SELECT UUID(), b.booking_id, 1000.00, 'credit_card'
FROM Booking b LIMIT 1;

-- Reviews
INSERT INTO Review (review_id, property_id, user_id, rating, comment)
SELECT UUID(), p.property_id, u.user_id, 5, 'Amazing stay!'
FROM Property p, User u
WHERE u.role = 'guest' LIMIT 1;

-- Messages
INSERT INTO Message (message_id, sender_id, recipient_id, message_body)
SELECT UUID(), u1.user_id, u2.user_id, 'Hello, is the apartment available next weekend?'
FROM User u1, User u2
WHERE u1.role = 'guest' AND u2.role = 'host' LIMIT 1;

