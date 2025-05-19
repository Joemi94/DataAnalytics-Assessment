# DataAnalytics-Assessment

# 💼 Financial Data Analysis with SQL

## 📘 Overview

This project contains SQL queries that analyze user financial data from savings and investment products. The queries answer three distinct business questions designed to provide actionable insights into user behavior and engagement.

---

## 📊 Per-Question Explanations

---

### **Question 1 – High-Value Customers with Multiple Products**

#### 🎯 Objective:
Retrieve users who have both **investment** and **regular savings** plans, including the count of each and their **total confirmed deposits**.

#### 🛠️ Approach:

1. **Plan Aggregation**:
   - Use conditional aggregation (`SUM(CASE WHEN...)`) to count investment and savings plans per user.

2. **Deposit Aggregation**:
   - Filter confirmed transactions and sum deposit amounts per user, converting them to standard units if needed.

3. **Filter & Join**:
   - Select only users with at least **one investment and one savings plan**.
   - Join with user details for a complete output.

#### 🧩 SQL Summary:
- Multiple CTEs aggregate plan counts and confirmed deposits.
- Final result filters users who meet the dual-plan condition and merges their data for reporting.

#### 🧪 Sample Expected Output:

| user_id | investment_count | savings_count | total_deposits |
|---------|------------------|----------------|----------------|
| 101     | 2                | 1              | 25000.00       |

#### 🚧 Challenges:

- **Conditional aggregation**: Handling multiple plan types in one query.
- **Filter logic**: Filtering only users with both types.
- **Joining aggregates**: Ensuring correct joins between CTEs.

---

### **Question 2 – Transaction Frequency Analysis**

#### 📖 Scenario:
The finance team wants to segment users by how frequently they transact to identify high-activity customers and low-engagement users.

#### 🎯 Task:
Calculate the average number of **successful transactions** per customer per month and classify them into:

- **High Frequency** (≥ 10 transactions/month)
- **Medium Frequency** (3–9 transactions/month)
- **Low Frequency** (≤ 2 transactions/month)

#### 🧾 Tables Used:
- `users_customuser`
- `savings_savingsaccount`

#### 🛠️ Approach:

1. **Monthly Grouping**:
   - Use `DATE_FORMAT(transaction_date, '%M-%Y')` to group transactions by `owner_id` and month.

2. **Filter for Success**:
   - Only count transactions where `transaction_status = 'success'`.

3. **Classify Frequency**:
   - Use a `CASE` statement to bucket customer-months based on transaction count.

4. **Aggregate Results**:
   - Count customers and calculate the average number of transactions in each category.

#### 🧩 SQL Summary:
- CTE computes per-month transaction counts per user.
- Outer query aggregates frequency category stats.

#### 🧪 Sample Expected Output:

| frequency_category | customer_count | avg_transactions_per_month |
|--------------------|----------------|-----------------------------|
| High Frequency     | 250            | 15.2                        |
| Medium Frequency   | 1200           | 5.5                         |
| Low Frequency      | 430            | 1.8                         |

#### 🚧 Challenges:

- **Date grouping**: Ensuring all transactions align by month-year.
- **Frequency classification**: Categorizing inside a grouped query.
- **Correct aggregation**: Avoiding miscounts in the final aggregation.

---

### **Question 3 – Account Inactivity Alert**

#### 📖 Scenario:
The business team wants to detect **inactive account holders** who haven’t transacted recently. This can support engagement strategies for dormant users.

#### 🎯 Task:
Determine the **last transaction date per account owner**, calculate **days of inactivity**, and classify accounts as either **Investment**, **Savings**, or **Others**.

#### 🧾 Tables Used:
- `savings_savingsaccount`
- `plans_plan`

#### 🛠️ Approach:

1. **Last transaction per user**:
   - Use `MAX(transaction_date)` grouped by `owner_id` in a CTE.

2. **Most recent system-wide transaction**:
   - A subquery computes the latest transaction across all users for reference.

3. **Plan classification**:
   - Join with `plans_plan`.
   - Use a `CASE` statement:
     - `'Investment'` if `is_a_fund = 1`
     - `'Savings'` if `is_regular_savings = 1`
     - `'Others'` otherwise

4. **Inactivity calculation**:
   - Use `DATEDIFF(most_recent_date, last_transaction)` to compute inactivity in days.

5. **Filter valid accounts**:
   - Exclude `'Others'` to focus only on investment and savings products.

#### 🧩 SQL Summary:
- Nested CTEs calculate user-level and global transaction dates.
- Join logic aligns accounts with plan types.
- Inactivity is derived using `DATEDIFF()` and filtered by classification.

#### 🧪 Sample Expected Output:

| owner_id | id | type       | last_transaction_date | inactivity_days |
|----------|----|------------|------------------------|-----------------|
| 101      | 45 | Savings    | 2024-10-11             | 189             |
| 102      | 33 | Investment | 2023-12-01             | 294             |

#### 🚧 Challenges:

**Challenge 1: Aggregates with plan-level joins**  
- **Description**: Maintaining aggregate logic while pulling plan-level info.  
- **Resolution**: Solved via CTEs and clean joins using `owner_id`.

**Challenge 2: Dynamic reference date**  
- **Description**: Needed the most recent transaction date dynamically.  
- **Resolution**: Used scalar subquery for system-wide max date.

**Challenge 3: Classification logic**  
- **Description**: Classifying overlapping/missing flag values was tricky.  
- **Resolution**: Structured `CASE` statement to prioritize and default to `'Others'`.

---

## 🧰 How to Use

1. Set up your MySQL environment with the required tables:
   - `savings_savingsaccount`
   - `plans_plan`
   - `users_customuser`

2. Run the queries sequentially per business question.

3. Use outputs for:
   - Customer segmentation
   - Engagement targeting
   - Dormancy monitoring
   - Business strategy insights
#### Question 4 – Estimating Customer Lifetime Value (CLV)
####📖 Scenario:
The Marketing Team wants to estimate Customer Lifetime Value (CLV) using a simplified model based on how long an account has been active (tenure) and how often the user transacts.

####🎯 Task:
For each customer:

Calculate account tenure in months (from signup).

Count total transactions and sum transaction values.

Compute CLV using the formula:
CLV = (total_transactions / tenure_in_months) * 12 * avg_profit_per_transaction
where profit per transaction = 0.1% of the transaction value.

#### 🧾 Tables Used:
users_customuser

savings_savingsaccount

#### 🛠️ Approach:
Join users with transactions:

Use LEFT JOIN to associate each user (users_customuser) with their transactions (savings_savingsaccount) via owner_id.

Tenure Calculation:

Compute tenure in months using TIMESTAMPDIFF(MONTH, signup_date, current_date).

Transaction Aggregation:

Use COUNT() for total number of transactions.

Use SUM(amount) to get the total transaction value.

Profit Estimation:

Assume profit per transaction = 0.001 × average transaction value.

Calculate avg_profit_per_transaction as SUM(amount) / COUNT(*) * 0.001.

CLV Formula Application:

Insert values into the given CLV formula.

Use CASE statements to avoid divide-by-zero errors (e.g., tenure = 0).

Sorting:

Order users by estimated_clv in descending order to rank most valuable customers.

#### 🧩 SQL Summary:
GROUP BY ensures customer-level aggregation.

LEFT JOIN ensures even users without transactions are considered.

DATEDIFF() and TIMESTAMPDIFF() help derive tenure and inactivity.

Profit and CLV metrics are computed using simple mathematical expressions within SQL.
#### 🚧 Challenges:
Challenge 1: Division by zero for tenure

Description: Users with 0-month tenure (e.g., just signed up) could trigger divide-by-zero errors in the CLV formula.

Resolution: Wrapped CLV logic in a CASE statement to prevent calculations when tenure equals 0.

Challenge 2: Users with no transactions

Description: Users with zero transactions must still appear in the result set (with zero CLV), but aggregate functions can return NULL or incorrect results.

Resolution: Used LEFT JOIN to preserve all users and COALESCE to default NULL sums/counts to zero.

Challenge 3: Profit calculation logic

Description: Translating the "0.1% profit per transaction" into an SQL-computable formula required clarity on using transaction value, not count.

Resolution: Calculated average transaction value (SUM / COUNT) and multiplied by 0.001 to estimate profit.

#### 🧰 How to Use
Prepare your MySQL environment with the required tables:

users_customuser (with a valid signup date column, e.g., created_on)

savings_savingsaccount (with valid owner_id, transaction_date, and amount)

Run the CLV estimation query to generate a per-user customer value model.

Use outputs for:

CLV-based customer segmentation

LTV modeling for marketing spend

Retention strategies based on tenure vs. activity

Identifying high-value customers for upselling or loyalty campaigns
