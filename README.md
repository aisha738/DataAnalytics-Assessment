<center>
  
  ### SQL Query Explanation & Workflow Challenges
  
</center>

- **IDE:** MySQL Workbench  

- **Initial Setup**  
  1. Downloaded the `adashi_assessment` database SQL script to my local machine.  
  2. I launched MySQL Workbench, established a new connection, imported the SQL script, ran it, and thereby created the `adashi_staging` database.

#### Question 1: High-Value Customers with Multiple Products
The goal here was to identify customers who had both a funded savings plan and a funded investment plan.<br><br>
To achieve this, I used INNER JOINS between three tables: users_customuser, plans_plan, and
savings_savingsaccount. The INNER JOIN ensures I only retrieved records where the relationships existed in all three
tables. Specifically:
- I joined users_customuser and plans_plan on user ID (owner_id)
- Then I joined plans_plan and savings_savingsaccount on plan ID<br><br>
I used conditional aggregation (via COUNT and CASE WHEN) to count savings and investment plans per user.
Finally, I filtered out users who had both savings_count > 0 and investment_count > 0 using HAVING.
I also calculated the total deposits and ordered the results in descending order.

#### Question 2: Transaction Frequency Analysis
In this task, I needed to determine how frequently customers perform transactions so we can segment them. I employed the following steps<br><br>
1. Created an 'all_customers' CTE from users_customuser (WHERE is_active = 1).
2. Calculated transactions_per_customer (count and active_months) from savings_savingsaccount.
3. Left-joined 'all_customers' with transactions_per_customer to capture users with zero transactions.
4. Used GREATEST(..., 1) to avoid division by zero when computing active_months.
5. Computed avg_txn_per_month and categorized each user into High (>=10), Medium (3-9), or Low (<3) Frequency.
6. Defined a base_categories list and left-joined to ensure all three categories appear, even if zero users fall in a group.

#### Question 3: Account Inactivity Alert
For this task, I was to find accounts with no inflow transactions in over a year.<br><br>
- I performed an INNER JOIN between plans_plan and savings_savingsaccount on plan_id, to ensure I'm working only
with linked savings/investment accounts.
- Using MAX(transaction_date), I got the most recent transaction per account.
- Then I used DATEDIFF to compute how many days ago that last transaction occurred.
- In the HAVING clause, I filtered accounts where inactivity_days > 365.

#### Question 4: 
In this final task, I estimated the Customer Lifetime Value (CLV) using a simplified formula.<br><br>
I joined users_customuser with savings_savingsaccount using owner_id.
Using TIMESTAMPDIFF, I calculated the tenure of each customer in months since they joined.
I then calculated:
- Total transactions per customer
- Average transaction value (after converting from kobo to naira)
- CLV = (total_transactions / tenure_months) * 12 * (avg_transaction_value * profit_rate)
Finally, I ordered the customers by CLV in descending order to get the highest value clients

#### Challenges & Resolution
1. Division by Zero in Question 2—Frequency Analysis:
- Customers with a single transaction caused active_months to be zero, skewing averages.
- Resolved with GREATEST(..., 1) to ensure at least one month divisor.
2. While writing and running my SQL queries, I encountered syntax and logical errors from time to time.
- I resolved this by revisiting MySQL documentation and relevant documents online.

  
