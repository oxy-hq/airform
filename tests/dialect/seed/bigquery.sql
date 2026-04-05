-- Seed data for BigQuery tier-3 tests
-- Note: dataset must be created manually or via bq mk before running
CREATE OR REPLACE TABLE analytics.raw_users (
    id INT64,
    first_name STRING NOT NULL,
    last_name STRING NOT NULL,
    email STRING NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    country STRING,
    revenue NUMERIC DEFAULT 0
);

INSERT INTO analytics.raw_users (id, first_name, last_name, email, created_at, country, revenue) VALUES
(1, 'Alice', 'Smith', 'alice@example.com', '2025-01-15 10:00:00', 'US', 49.99),
(2, 'Bob', 'Jones', 'bob@example.com', '2025-01-15 11:00:00', 'UK', 25.00),
(3, 'Charlie', 'Brown', 'charlie@example.com', '2025-01-16 09:00:00', 'DE', 0),
(4, 'Diana', 'Prince', 'diana@example.com', '2025-01-16 14:00:00', 'US', 99.99),
(5, 'Eve', 'Taylor', 'eve@example.com', '2025-01-17 08:00:00', 'JP', 15.00);

CREATE OR REPLACE TABLE analytics.raw_orders (
    id INT64,
    user_id INT64 NOT NULL,
    amount NUMERIC NOT NULL,
    status STRING NOT NULL,
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO analytics.raw_orders (id, user_id, amount, status, ordered_at) VALUES
(101, 1, 49.99, 'completed', '2025-01-15 10:10:00'),
(102, 2, 25.00, 'completed', '2025-01-15 11:05:00'),
(103, 4, 99.99, 'completed', '2025-01-16 14:30:00'),
(104, 5, 15.00, 'pending', '2025-01-17 08:15:00'),
(105, 1, 75.00, 'returned', '2025-01-18 09:00:00');
