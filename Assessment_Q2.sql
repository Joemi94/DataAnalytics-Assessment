-- preview customer table
SELECT *
FROM users_customuser
LIMIT 5;

-- preview savings table
SELECT *
FROM savings_savingsaccount
LIMIT 5;

-- Create a Common Table Expression (CTE) to preprocess data
WITH CTE AS (
    SELECT 
        -- Format transaction_date as 'Month-Year' (e.g., 'May-2025')
        DATE_FORMAT(transaction_date, '%M-%Y') AS Monthly, 
        
        -- Identify the customer
        owner_id, 
        
        -- Count number of successful transactions per customer per month
        COUNT(transaction_status) AS transactions,
        
        -- Classify transaction frequency into categories
        CASE 
            WHEN COUNT(transaction_status) <= 2 THEN 'Low Frequency' 
            WHEN COUNT(transaction_status) > 2 AND COUNT(transaction_status) < 10 THEN 'Medium Frequency'
            ELSE 'High Frequency'
        END AS frequency_category
    FROM savings_savingsaccount
    WHERE transaction_status = "success" -- Only include successful transactions
    GROUP BY Monthly, owner_id
)

-- Aggregate results by frequency category
SELECT 
    frequency_category, 
    COUNT(owner_id) AS customer_count,  -- Number of customers in each category
    AVG(transactions) AS avg_transactions_per_month -- Average transactions per customer per month
FROM CTE
GROUP BY frequency_category;
