-- Create tables for our transaction monitoring system
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    amount DECIMAL(10,2),
    transaction_type VARCHAR(50),
    transaction_date TIMESTAMP,
    status VARCHAR(20),
    ip_address VARCHAR(45),
    device_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transaction_details (
    detail_id SERIAL PRIMARY KEY,
    transaction_id INTEGER REFERENCES transactions(transaction_id),
    merchant_name VARCHAR(100),
    merchant_category VARCHAR(50),
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
