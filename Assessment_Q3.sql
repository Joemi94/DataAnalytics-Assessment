-- Selecting the existing database
USE adashi_staging;

-- preview customer table
SELECT *
FROM users_customuser
LIMIT 5;

-- preview plans table
SELECT *
FROM plans_plan
LIMIT 5;
DESCRIBE plans_plan;

-- preview savings table
SELECT *
FROM savings_savingsaccount
LIMIT 5;

-- Define a Common Table Expression (CTE) 'new_table' that processes account activity and plan types
WITH new_table AS (
  
  -- Inner CTE to get the last transaction date per owner and the most recent transaction overall
  WITH CTE AS (
    SELECT 
      owner_id, 
      MAX(DATE(transaction_date)) AS last_transaction,   -- Last transaction date per owner
      (
        SELECT MAX(DATE(transaction_date))                -- Most recent transaction date in entire table
        FROM savings_savingsaccount
      ) AS most_recent_date
    FROM savings_savingsaccount
    GROUP BY owner_id
  )

  -- Join the above CTE with plan details to classify account types and calculate inactivity
  SELECT 
    p.owner_id,
    id,
    type,
    last_transaction AS last_transaction_date,
    -- Calculate inactivity in days: difference between most recent date and last transaction date
    DATEDIFF(most_recent_date, last_transaction) AS inactivity_days
  FROM CTE AS c
  JOIN (
    SELECT 
      owner_id,
      id,
      -- Classify plan types based on flags in the plans_plan table
      CASE 
        WHEN is_a_fund = 1 THEN 'Investment' 
        WHEN is_regular_savings = 1 THEN 'Savings'
        ELSE 'Others' 
      END AS type
    FROM plans_plan
  ) AS p
  ON c.owner_id = p.owner_id
)

-- Final selection filtering out 'Others' type accounts
SELECT *
FROM new_table
WHERE type != 'Others';
