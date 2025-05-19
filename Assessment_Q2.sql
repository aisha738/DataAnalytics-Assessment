-- Select adashi_staging database as the current working database
USE adashi_staging;

 -- Segment customers based on transaction frequency
WITH
-- Generate base list of all active customers
all_customers AS (
    SELECT id AS owner_id
    FROM users_customuser
    WHERE is_active = 1
),
-- Count successful transactions and compute activity span
transactions_per_customer AS (
    SELECT 
        s.owner_id,
        COUNT(*) AS total_transactions,
        GREATEST(DATEDIFF(MAX(s.transaction_date), MIN(s.transaction_date)) / 30.0, 1) AS active_months
    FROM savings_savingsaccount s
    WHERE s.transaction_status = 'successful'
    GROUP BY s.owner_id
),
-- Ensure every customer appears, defaulting missing to zero
customer_activity AS (
    SELECT
        ac.owner_id,
        COALESCE(tpc.total_transactions, 0) AS total_transactions,
        COALESCE(tpc.active_months, 1) AS active_months
    FROM all_customers ac
    LEFT JOIN transactions_per_customer tpc ON ac.owner_id = tpc.owner_id
),
-- Compute average transactions per month for each customer
monthly_avg AS (
    SELECT 
        owner_id,
        total_transactions / active_months AS avg_txn_per_month
    FROM customer_activity
),
-- Categorize each customer
categorized AS (
    SELECT 
        owner_id,
        CASE 
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_txn_per_month
    FROM monthly_avg
),
-- Define all possible frequency categories
base_categories AS (
    SELECT 'High Frequency' AS frequency_category
    UNION ALL
    SELECT 'Medium Frequency'
    UNION ALL
    SELECT 'Low Frequency'
)
-- Final aggregation, preserving all categories
SELECT 
    b.frequency_category,
    COUNT(c.owner_id) AS customer_count,  -- count of customers in each category
    ROUND(AVG(c.avg_txn_per_month), 2) AS avg_transactions_per_month
FROM base_categories b
LEFT JOIN categorized c ON b.frequency_category = c.frequency_category
GROUP BY b.frequency_category
ORDER BY FIELD(b.frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');