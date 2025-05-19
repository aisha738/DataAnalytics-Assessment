-- Select adashi_staging database as the current working database
USE adashi_staging;

-- Active accounts (savings or investments) with no transactions in the last 1 year (365 days) .
SELECT 
    p.id AS plan_id,
    p.owner_id,
    -- Identify the plan type
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'
    END AS type,
    MAX(s.transaction_date) AS last_transaction_date,
    -- Compute inactivity days from last transaction
    DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days
FROM plans_plan p
JOIN savings_savingsaccount s ON p.id = s.plan_id
WHERE s.confirmed_amount > 0
GROUP BY p.id, p.owner_id, type
HAVING inactivity_days > 365;