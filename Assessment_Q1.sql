-- Select adashi_staging database as the current working database
USE adashi_staging;

 -- Customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits
SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    -- Count distinct savings products per user
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count,
    -- Count distinct investment products per user
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count,
    -- Sum all confirmed amounts (in kobo) and convert to naira
    ROUND(SUM(s.confirmed_amount) / 100, 2) AS total_deposits
FROM users_customuser u
JOIN plans_plan p ON u.id = p.owner_id
JOIN savings_savingsaccount s ON p.id = s.plan_id
WHERE s.confirmed_amount > 0
GROUP BY u.id, name
HAVING savings_count > 0 AND investment_count > 0
ORDER BY total_deposits DESC;





