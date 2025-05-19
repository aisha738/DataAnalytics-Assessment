-- Select adashi_staging database as the current working database
USE adashi_staging;

-- Customer Lifetime Value (CLV) Estimation
WITH txn_summary AS (
    SELECT 
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        -- Calculate tenure in months since the user joined
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
        -- Count total transactions
        COUNT(s.id) AS total_transactions,
        -- Average transaction value (converted to naira)
        AVG(s.confirmed_amount) / 100 AS avg_transaction_value,
        -- Set assumed profit rate
        0.001 AS profit_rate
    FROM users_customuser u
    JOIN savings_savingsaccount s ON u.id = s.owner_id
    WHERE s.confirmed_amount > 0
    GROUP BY u.id, name, u.date_joined
),
clv_calc AS (
    SELECT 
        customer_id,
        name,
        tenure_months,
        total_transactions,
        -- Estimate CLV using transaction frequency and profit margin
        ROUND((total_transactions / tenure_months) * 12 * (avg_transaction_value * profit_rate), 2) AS estimated_clv
    FROM txn_summary
    WHERE tenure_months > 0
)
SELECT *
FROM clv_calc
ORDER BY estimated_clv DESC;