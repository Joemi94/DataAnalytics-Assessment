-- preview customer table
SELECT *
FROM users_customuser
LIMIT 5;

-- preview plans table
SELECT *
FROM plans_plan
LIMIT 5;

-- preview savings table
SELECT *
FROM savings_savingsaccount
LIMIT 5;

-- Select owner ID, full name (concatenation of first and last name),
-- counts of savings and investments, and total deposits
SELECT 
    pp.owner_id,
    CONCAT(first_name, ' ', last_name) AS name,
    saving_count,
    investment_count,
    total_deposits
FROM users_customuser uc
-- Join with a subquery (pp) that calculates the count of investments and savings per owner
JOIN (
    SELECT 
        owner_id,
        -- Count how many plans are marked as investment funds (is_a_fund=1)
        SUM(CASE WHEN is_a_fund = 1 THEN 1 ELSE 0 END) AS investment_count,
        -- Count how many plans are marked as regular savings (is_regular_savings=1)
        SUM(CASE WHEN is_regular_savings = 1 THEN 1 ELSE 0 END) AS saving_count
    FROM plans_plan
    GROUP BY owner_id
    -- Only include owners who have both investments and savings
    HAVING investment_count > 0 AND saving_count > 0
) AS pp ON uc.id = pp.owner_id
-- Join with another subquery (ssa) that sums the total confirmed deposits per owner
JOIN (
    SELECT 
        owner_id, 
        -- Sum confirmed amounts, dividing by 100 to adjust Naira (e.g., kobo to naira), rounded to 0 decimals
        ROUND(SUM(confirmed_amount) / 100.0, 0) AS total_deposits
    FROM savings_savingsaccount
    GROUP BY owner_id
) AS ssa ON uc.id = ssa.owner_id
ORDER BY total_deposits;
