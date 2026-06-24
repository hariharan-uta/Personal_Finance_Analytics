import pandas as pd
import numpy as np
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()
random.seed(42)
np.random.seed(42)

# ── Config ──────────────────────────────────────────────────────────────────
NUM_USERS   = 1000
START_DATE  = "2022-01-01"
END_DATE    = "2024-12-31"
INFLATION   = 0.07  # 7% YoY

CITIES = [
    "New York", "Los Angeles", "Chicago", "Houston", "Phoenix",
    "San Francisco", "Seattle", "Austin", "Boston", "Denver"
]

INCOME_LEVELS = {
    "low":    (3000,  5000),
    "medium": (5000, 10000),
    "high":  (10000, 25000),
}

CATEGORIES = {
    "Housing":       {"subs": ["Rent", "Mortgage", "Utilities", "HOA"],              "range": (800,  3500), "freq": 1},
    "Groceries":     {"subs": ["Supermarket", "Costco", "Farmers Market"],           "range": (200,   800), "freq": 4},
    "Dining":        {"subs": ["Restaurant", "Fast Food", "Coffee", "Food Delivery"],"range": (100,   600), "freq": 6},
    "Transport":     {"subs": ["Gas", "Uber/Lyft", "Car Payment", "Parking"],        "range": (100,   700), "freq": 5},
    "Subscriptions": {"subs": ["Netflix", "Spotify", "Amazon Prime", "Hulu", "Gym"], "range": (30,    200), "freq": 1},
    "Healthcare":    {"subs": ["Doctor", "Pharmacy", "Insurance", "Dental"],          "range": (50,    400), "freq": 2},
    "Shopping":      {"subs": ["Amazon", "Clothing", "Electronics", "Home Decor"],   "range": (100,  1000), "freq": 3},
    "Travel":        {"subs": ["Flights", "Hotels", "Vacation Rental", "Car Rental"],"range": (0,    3000), "freq": 0},
    "Savings":       {"subs": ["401k", "Emergency Fund", "Roth IRA", "Investment"],  "range": (200,  2000), "freq": 1},
    "Income":        {"subs": ["Salary", "Bonus", "Freelance", "Side Hustle"],       "range": (3000,12000), "freq": 1},
}

# ── Generate Users ───────────────────────────────────────────────────────────
def generate_users():
    users = []
    weights = [30, 50, 20]
    levels  = list(INCOME_LEVELS.keys())
    for i in range(1, NUM_USERS + 1):
        level = random.choices(levels, weights=weights)[0]
        lo, hi = INCOME_LEVELS[level]
        users.append({
            "user_id":        i,
            "name":           fake.name(),
            "city":           random.choice(CITIES),
            "income_level":   level,
            "monthly_income": random.randint(lo, hi),
            "age":            random.randint(22, 65),
            "has_mortgage":   random.random() > 0.6,
        })
    return pd.DataFrame(users)

# ── Generate Transactions ────────────────────────────────────────────────────
def generate_transactions(users_df):
    rows   = []
    txn_id = 1
    start  = datetime.strptime(START_DATE, "%Y-%m-%d")
    end    = datetime.strptime(END_DATE,   "%Y-%m-%d")

    for _, user in users_df.iterrows():
        current = start
        while current <= end:
            year_mult = 1 + INFLATION * (current.year - 2022)

            for cat, cfg in CATEGORIES.items():
                # Travel: only ~15% of months
                if cat == "Travel" and random.random() > 0.15:
                    continue

                n = cfg["freq"] if cfg["freq"] > 0 else random.randint(1, 3)
                lo, hi = cfg["range"]

                for _ in range(n):
                    amount = round(
                        random.uniform(lo, hi) / max(n, 1) * year_mult, 2
                    )
                    txn_date = current + timedelta(days=random.randint(0, 27))

                    rows.append({
                        "transaction_id":   txn_id,
                        "user_id":          user["user_id"],
                        "txn_date":         txn_date.strftime("%Y-%m-%d"),
                        "amount":           amount,
                        "category":         cat,
                        "subcategory":      random.choice(cfg["subs"]),
                        "city":             user["city"],
                        "income_level":     user["income_level"],
                        "is_recurring":     cat in ["Housing", "Subscriptions", "Savings", "Income"],
                        "transaction_type": "credit" if cat == "Income" else "debit",
                    })
                    txn_id += 1

            # Next month
            current = (current.replace(day=1) + timedelta(days=32)).replace(day=1)

    return pd.DataFrame(rows)

# ── Main ─────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("Generating users...")
    users_df = generate_users()
    users_df.to_csv("users.csv", index=False)
    print(f"  users.csv → {len(users_df):,} rows")

    print("Generating transactions (this takes ~1–2 mins)...")
    txns_df = generate_transactions(users_df)
    txns_df.to_csv("transactions.csv", index=False)
    print(f"  transactions.csv → {len(txns_df):,} rows")

    print("\nDone! Files saved: users.csv, transactions.csv")
    print(txns_df[["transaction_id","user_id","txn_date","amount","category","subcategory","transaction_type"]].head(10).to_string(index=False))
