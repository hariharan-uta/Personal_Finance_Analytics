-- ============================================================
-- 02_materialized_views.sql
-- Pre-aggregated views for fast dashboard queries
-- ============================================================

-- MV 1: Monthly spend by category
-- Powers the "Monthly Spend by Category" dashboard panel
CREATE MATERIALIZED VIEW personal_finance.mv_monthly_category_spend
ENGINE = SummingMergeTree()
ORDER BY (txn_month, category, income_level)
POPULATE
AS
SELECT
    toStartOfMonth(txn_date) AS txn_month,
    category,
    income_level,
    sum(amount)              AS total_spend,
    count()                  AS txn_count
FROM personal_finance.transactions
WHERE transaction_type = 'debit'
GROUP BY txn_month, category, income_level;

-- MV 2: Subscription tracker
-- Powers the "Subscription Cost Over Time" panel
CREATE MATERIALIZED VIEW personal_finance.mv_subscriptions
ENGINE = SummingMergeTree()
ORDER BY (txn_month, subcategory)
POPULATE
AS
SELECT
    toStartOfMonth(txn_date) AS txn_month,
    subcategory,
    sum(amount)              AS total_cost,
    count()                  AS subscriber_count
FROM personal_finance.transactions
WHERE category = 'Subscriptions'
GROUP BY txn_month, subcategory;

-- MV 3: Savings rate tracker
-- Powers the "Savings Rate by Income Level" panel
CREATE MATERIALIZED VIEW personal_finance.mv_savings_rate
ENGINE = SummingMergeTree()
ORDER BY (txn_month, user_id, income_level)
POPULATE
AS
SELECT
    toStartOfMonth(txn_date)                   AS txn_month,
    user_id,
    income_level,
    sumIf(amount, category = 'Savings')        AS total_saved,
    sumIf(amount, transaction_type = 'credit') AS total_income
FROM personal_finance.transactions
GROUP BY txn_month, user_id, income_level;
