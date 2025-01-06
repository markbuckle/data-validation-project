-- Detect unusually large transactions
SELECT t.*, c.name
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
WHERE amount > (
    SELECT AVG(amount) + (3 * STDDEV(amount))
    FROM transactions
    WHERE customer_id = t.customer_id
);

-- Detect rapid succession transactions
WITH time_diff AS (
    SELECT 
        *,
        transaction_date - LAG(transaction_date) 
            OVER (PARTITION BY customer_id ORDER BY transaction_date) 
        AS time_since_last
    FROM transactions
)
SELECT 
    t.*, 
    c.name
FROM time_diff t
JOIN customers c ON t.customer_id = c.customer_id
WHERE time_since_last < INTERVAL '1 minute'
AND amount > 100;

-- Detect transactions from different locations in short timeframe
WITH location_changes AS (
    SELECT 
        t1.*,
        t2.location AS prev_location,
        t2.transaction_date AS prev_date
    FROM transaction_details t1
    JOIN transaction_details t2 
    ON t1.transaction_id > t2.transaction_id
    AND t1.transaction_id IN (
        SELECT transaction_id 
        FROM transactions 
        WHERE customer_id = t2.transaction_id
    )
    WHERE t1.location != t2.location
)
SELECT *
FROM location_changes
WHERE transaction_date - prev_date < INTERVAL '1 hour';