# Personal Finance & Spending Analytics Platform

A distributed analytics platform built on ClickHouse Cloud that analyzes 
874,772 synthetic personal finance transactions across 1,000 users, 10 US 
cities, and 3 years (2022–2024).

## Project Overview

This project explores distributed database design using ClickHouse Cloud — 
modeling realistic personal finance data to surface spending patterns, 
inflation trends, subscription costs, and savings behavior through an 
interactive Grafana dashboard.

## Architecture

- **Database:** ClickHouse Cloud (MergeTree engine)
- **Partitioning:** Monthly via `toYYYYMM(txn_date)`
- **Ordering:** `(user_id, txn_date, category)` for fast per-user queries
- **Materialized views:** 3 pre-aggregated views for instant dashboard queries
- **Visualization:** Grafana Cloud (8 panels)

## Dataset

| Attribute | Details |
|---|---|
| Users | 1,000 simulated users |
| Transactions | 874,772 rows |
| Time span | 2022 – 2024 |
| Cities | 10 US cities |
| Categories | 10 spending categories |
| Inflation | 7% YoY multiplier applied |

## Materialized Views

| View | Engine | Purpose |
|---|---|---|
| mv_monthly_category_spend | SummingMergeTree | Monthly spend by category |
| mv_subscriptions | SummingMergeTree | Subscription cost tracking |
| mv_savings_rate | SummingMergeTree | Savings rate per user |

## Dashboard Panels

1. Monthly Spend by Category — stacked bar chart
2. Subscription Cost Over Time — time series
3. Savings Rate by Income Level — line chart
4. Year-over-Year Inflation Impact — table
5. City Cost of Living Comparison — bar gauge
6. Paycheck-to-Paycheck Risk Score — pie chart
7. Top Spending Subcategories — horizontal bar
8. Income vs Expense Trend — area chart

## Repository Structure

├── sql/

│   ├── 01_schema.sql

│   ├── 02_materialized_views.sql

│   └── 03_analytics.sql

├── data/

│   └── generate_data.py

└── README.md

## Setup

1. Run `pip install faker pandas numpy` then `python data/generate_data.py`
2. Create the schema using `sql/01_schema.sql` in ClickHouse Cloud SQL Console
3. Upload `users.csv` and `transactions.csv` via ClickHouse Cloud Data sources
4. Create materialized views using `sql/02_materialized_views.sql`
5. Connect Grafana Cloud to ClickHouse and build dashboard panels
