-- Create indexes for better query performance
CREATE INDEX idx_transaction_date ON transactions(transaction_date);
CREATE INDEX idx_customer_transactions ON transactions(customer_id);
CREATE INDEX idx_transaction_amount ON transactions(amount);