-- Insert new transactions
CREATE OR REPLACE FUNCTION insert_transaction(
    p_customer_id INTEGER,
    p_amount DECIMAL,
    p_type VARCHAR,
    p_ip VARCHAR,
    p_device_id VARCHAR,
    p_merchant VARCHAR,
    p_category VARCHAR,
    p_location VARCHAR
) RETURNS INTEGER AS $$
DECLARE
    v_transaction_id INTEGER;
BEGIN
    -- Insert transaction
    INSERT INTO transactions (
        customer_id, amount, transaction_type, 
        transaction_date, status, ip_address, device_id
    ) VALUES (
        p_customer_id, p_amount, p_type, 
        CURRENT_TIMESTAMP, 'PENDING', p_ip, p_device_id
    ) RETURNING transaction_id INTO v_transaction_id;

    -- Insert transaction details
    INSERT INTO transaction_details (
        transaction_id, merchant_name, 
        merchant_category, location
    ) VALUES (
        v_transaction_id, p_merchant, 
        p_category, p_location
    );

    RETURN v_transaction_id;
END;
$$ LANGUAGE plpgsql;