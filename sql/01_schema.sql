-- ============================================================
-- 01_schema.sql
-- Personal Finance & Spending Analytics Platform
-- ============================================================

-- Create database
CREATE DATABASE IF NOT EXISTS personal_finance;

-- Users dimension table
CREATE TABLE personal_finance.users
(
    user_id        UInt32,
    name           String,
    city           LowCardinality(String),
    income_level   LowCardinality(String),
    monthly_income UInt32,
    age            UInt8,
    has_mortgage   Bool
)
ENGINE = MergeTree()
ORDER BY user_id;

-- Main transactions table
-- Partitioned by month, ordered by user for fast per-user queries
CREATE TABLE personal_finance.transactions
(
    transaction_id   UInt64,
    user_id          UInt32,
    txn_date         Date,
    amount           Decimal(10, 2),
    category         LowCardinality(String),
    subcategory      LowCardinality(String),
    city             LowCardinality(String),
    income_level     LowCardinality(String),
    is_recurring     Bool,
    transaction_type LowCardinality(String)
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(txn_date)
ORDER BY (user_id, txn_date, category)
SETTINGS index_granularity = 8192;
