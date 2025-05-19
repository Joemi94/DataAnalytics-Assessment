-- selecting the database
USE adashi_staging;

-- Peeking at the tables one after the other
SELECT * FROM users_customuser LIMIT 5;
SELECT * FROM savings_savingsaccount LIMIT 5;

-- modifying existing column in the users-customuser
SET SQL_SAFE_UPDATES = 0; -- temporarily deactivating safe mode

UPDATE users_customuser
SET name = CONCAT(first_name, ' ', last_name)
WHERE name IS NULL OR name = '';


-- ANSWERING QUESTION 4
SELECT 
    u.id AS customer_id,
    u.name,
    
    -- Calculate tenure in months (difference between now and signup)
    TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()) AS tenure_months,
    
    -- Count total transactions for user
    COUNT(s.id) AS total_transactions,
    
    -- Calculate estimated CLV
    CASE 
        WHEN TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()) > 0 THEN
            (COUNT(s.id) / TIMESTAMPDIFF(MONTH, u.created_on, CURDATE())) * 12 * ((SUM(s.amount) / COUNT(s.id)) * 0.001)
        ELSE 0
    END AS estimated_clv

FROM 
    users_customuser u

LEFT JOIN 
    savings_savingsaccount s ON s.owner_id = u.id
    AND s.transaction_date IS NOT NULL          -- Only consider rows with valid transactions

GROUP BY 
    u.id, u.created_on

ORDER BY 
    estimated_clv DESC;

