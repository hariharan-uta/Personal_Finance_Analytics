-- ============================================================
-- 03_analytics.sql
-- Key analytical queries for the dashboard
-- ============================================================

-- Query 1: Year-over-Year inflation impact by category
SELECT
    category,
    round(avgIf(amount, toYear(txn_date) = 2022), 2) AS avg_2022,
    round(avgIf(amount, toYear(txn_date) = 2023), 2) AS avg_2023,
    round(avgIf(amount, toYear(txn_date) = 2024), 2) AS avg_2024,
    round((avgIf(amount, toYear(txn_date) = 2024)
         - avgIf(amount, toYear(txn_date) = 2022))
         / avgIf(amount, toYear(txn_date) = 2022) * 100, 1) AS pct_change
FROM personal_finance.transactions
WHERE transaction_type = 'debit'
GROUP BY category
ORDER BY pct_change DESC;

-- Query 2: Savings rate by income level
SELECT
    income_level,
    round(avg(total_saved / nullIf(total_income, 0) * 100), 1) AS avg_savings_rate_pct
FROM personal_finance.mv_savings_rate
GROUP BY income_level
ORDER BY avg_savings_rate_pct DESC;

-- Query 3: Subscription cost by platform
SELECT
    subcategory,
    round(avg(total_cost), 2)  AS avg_monthly_cost,
    sum(subscriber_count)      AS total_subscriptions
FROM personal_finance.mv_subscriptions
GROUP BY subcategory
ORDER BY avg_monthly_cost DESC;

-- Query 4: City cost of living comparison
SELECT
    city,
    round(avgIf(amount, category = 'Housing'), 0)   AS avg_housing,
    round(avgIf(amount, category = 'Groceries'), 0) AS avg_groceries,
    round(avgIf(amount, category = 'Dining'), 0)    AS avg_dining,
    round(avgIf(amount, category = 'Transport'), 0) AS avg_transport
FROM personal_finance.transactions
WHERE transaction_type = 'debit'
GROUP BY city
ORDER BY avg_housing DESC;

-- Query 5: Paycheck-to-paycheck risk score
SELECT
    financial_health,
    count(DISTINCT user_id) AS user_count
FROM (
    SELECT
        user_id,
        CASE
            WHEN avg(total_saved / nullIf(total_income, 0)) < 0.05 THEN 'High Risk'
            WHEN avg(total_saved / nullIf(total_income, 0)) < 0.15 THEN 'Medium Risk'
            ELSE 'Healthy'
        END AS financial_health
    FROM personal_finance.mv_savings_rate
    GROUP BY user_id
)
GROUP BY financial_health
ORDER BY user_count DESC;
