-- Seed data for ClickHouse tier-2 tests
CREATE DATABASE IF NOT EXISTS airform_test;

CREATE TABLE IF NOT EXISTS airform_test.raw_users (
    id Int32,
    first_name String,
    last_name String,
    email String,
    created_at DateTime DEFAULT now(),
    country String,
    revenue Float64 DEFAULT 0
) ENGINE = MergeTree() ORDER BY id;

TRUNCATE TABLE airform_test.raw_users;

INSERT INTO airform_test.raw_users (id, first_name, last_name, email, created_at, country, revenue) VALUES
(1, 'Alice', 'Smith', 'alice@example.com', '2025-01-15 10:00:00', 'US', 49.99),
(2, 'Bob', 'Jones', 'bob@example.com', '2025-01-15 11:00:00', 'UK', 25.00),
(3, 'Charlie', 'Brown', 'charlie@example.com', '2025-01-16 09:00:00', 'DE', 0),
(4, 'Diana', 'Prince', 'diana@example.com', '2025-01-16 14:00:00', 'US', 99.99),
(5, 'Eve', 'Taylor', 'eve@example.com', '2025-01-17 08:00:00', 'JP', 15.00);

CREATE TABLE IF NOT EXISTS airform_test.raw_orders (
    id Int32,
    user_id Int32,
    amount Float64,
    status String,
    ordered_at DateTime DEFAULT now()
) ENGINE = MergeTree() ORDER BY id;

TRUNCATE TABLE airform_test.raw_orders;

INSERT INTO airform_test.raw_orders (id, user_id, amount, status, ordered_at) VALUES
(101, 1, 49.99, 'completed', '2025-01-15 10:10:00'),
(102, 2, 25.00, 'completed', '2025-01-15 11:05:00'),
(103, 4, 99.99, 'completed', '2025-01-16 14:30:00'),
(104, 5, 15.00, 'pending', '2025-01-17 08:15:00'),
(105, 1, 75.00, 'returned', '2025-01-18 09:00:00');
