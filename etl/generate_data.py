"""
generate_data.py

EXTRACT / TRANSFORM step of the ETL pipeline.

This script generates a realistic synthetic dataset of real estate
transactions large enough to expose genuine performance problems in
an unindexed database (the whole premise of this project). It writes
clean, validated CSVs to data/, which load_data.py then loads
(the LOAD step) into both PostgreSQL and MySQL.

Why generate data instead of using a real dataset?
  - Real estate transaction data with buyer/seller financials is
    sensitive and hard to source publicly at volume.
  - Synthetic generation lets us control the data distribution
    (e.g. skewing some agents/cities to have disproportionately
    many transactions), which is what creates realistic, uneven
    query performance characteristics worth optimizing.

Usage:
    python generate_data.py
"""

import pandas as pd
import numpy as np
import random
from datetime import date, timedelta

random.seed(42)
np.random.seed(42)

N_PROPERTIES = 5_000
N_AGENTS = 150
N_PARTIES = 20_000
N_TRANSACTIONS = 50_000

CITIES = [
    ("Austin", "TX"), ("Dallas", "TX"), ("Houston", "TX"),
    ("Denver", "CO"), ("Boulder", "CO"),
    ("Sacramento", "CA"), ("San Diego", "CA"),
    ("Charlotte", "NC"), ("Raleigh", "NC"),
    ("Columbus", "OH"),
]
PROPERTY_TYPES = ["single_family", "condo", "townhouse", "multi_family", "land"]
PARTY_TYPES = ["individual"] * 9 + ["company"]  # 90% individuals, 10% companies


def generate_properties(n: int) -> pd.DataFrame:
    """EXTRACT/TRANSFORM: build the properties table."""
    rows = []
    for i in range(1, n + 1):
        city, state = random.choice(CITIES)
        rows.append({
            "property_id": i,
            "address": f"{random.randint(100, 9999)} {random.choice(['Main', 'Oak', 'Maple', 'Elm', 'Cedar', 'Sunset'])} {random.choice(['St', 'Ave', 'Blvd', 'Dr'])}",
            "city": city,
            "state": state,
            "zip_code": f"{random.randint(10000, 99999)}",
            "property_type": random.choice(PROPERTY_TYPES),
            "square_footage": int(np.clip(np.random.normal(1800, 700), 400, 8000)),
            "listing_price": round(float(np.random.lognormal(mean=12.6, sigma=0.4)), 2),
        })
    return pd.DataFrame(rows)


def generate_agents(n: int) -> pd.DataFrame:
    """EXTRACT/TRANSFORM: build the agents table."""
    first_names = ["James", "Maria", "Robert", "Linda", "David", "Patricia", "John",
                    "Jennifer", "Michael", "Elizabeth", "William", "Susan", "Carlos", "Aisha"]
    last_names = ["Smith", "Johnson", "Williams", "Brown", "Garcia", "Miller", "Davis",
                  "Rodriguez", "Martinez", "Lee", "Walker", "Hall", "Allen", "Young"]
    rows = []
    start_date = date(2015, 1, 1)
    for i in range(1, n + 1):
        fn, ln = random.choice(first_names), random.choice(last_names)
        rows.append({
            "agent_id": i,
            "first_name": fn,
            "last_name": ln,
            "license_number": f"LIC-{100000 + i}",
            "email": f"{fn.lower()}.{ln.lower()}{i}@realty.com",
            "hire_date": (start_date + timedelta(days=random.randint(0, 4000))).isoformat(),
        })
    return pd.DataFrame(rows)


def generate_parties(n: int) -> pd.DataFrame:
    """EXTRACT/TRANSFORM: build the parties table (buyers and sellers, unified)."""
    first_names = ["Alex", "Sam", "Jordan", "Taylor", "Morgan", "Casey", "Riley", "Avery",
                   "Chris", "Pat", "Jamie", "Drew", "Sydney", "Quinn"]
    last_names = ["Anderson", "Thomas", "Jackson", "White", "Harris", "Martin", "Thompson",
                  "Moore", "Clark", "Lewis", "Robinson", "Walker", "Perez", "Hall"]
    rows = []
    for i in range(1, n + 1):
        ptype = random.choice(PARTY_TYPES)
        if ptype == "company":
            name = f"{random.choice(['Summit', 'Horizon', 'Cedar', 'Lakeside', 'Bluepoint'])} {random.choice(['Holdings', 'Properties', 'Investments', 'Group'])} LLC"
        else:
            name = f"{random.choice(first_names)} {random.choice(last_names)}"
        rows.append({
            "party_id": i,
            "full_name": name,
            "email": f"party{i}@example.com",
            "phone": f"{random.randint(200,999)}-{random.randint(200,999)}-{random.randint(1000,9999)}",
            "party_type": ptype,
        })
    return pd.DataFrame(rows)


def generate_transactions(n: int, n_properties: int, n_agents: int, n_parties: int) -> pd.DataFrame:
    """
    EXTRACT/TRANSFORM: build the transactions table.

    Deliberately skews the distribution -- a small subset of agents
    and a date range concentrated in recent years -- because real
    operational data is never uniformly distributed, and uneven
    distributions are exactly what make certain query patterns
    (e.g. "all transactions for agent X" or "all transactions in
    the last 90 days") disproportionately expensive without an
    index, which is the scenario this project is built to expose.
    """
    # Skew: 20% of agents handle ~60% of transactions (the "top performer" pattern)
    top_agents = list(range(1, int(n_agents * 0.2) + 1))
    other_agents = list(range(int(n_agents * 0.2) + 1, n_agents + 1))

    start_date = date(2020, 1, 1)
    end_date = date(2026, 6, 1)
    date_range_days = (end_date - start_date).days

    rows = []
    for i in range(1, n + 1):
        agent_id = random.choice(top_agents) if random.random() < 0.6 else random.choice(other_agents)

        buyer_id = random.randint(1, n_parties)
        seller_id = random.randint(1, n_parties)
        while seller_id == buyer_id:
            seller_id = random.randint(1, n_parties)

        # Skew dates toward more recent activity (more transactions in later years)
        skewed_day_offset = int(np.random.beta(a=2, b=1) * date_range_days)
        sale_date = start_date + timedelta(days=skewed_day_offset)

        rows.append({
            "transaction_id": i,
            "property_id": random.randint(1, n_properties),
            "agent_id": agent_id,
            "buyer_party_id": buyer_id,
            "seller_party_id": seller_id,
            "sale_date": sale_date.isoformat(),
            "sale_price": round(float(np.random.lognormal(mean=12.6, sigma=0.35)), 2),
        })
    return pd.DataFrame(rows)


def generate_transaction_payments(transactions_df: pd.DataFrame) -> pd.DataFrame:
    """EXTRACT/TRANSFORM: build the transaction_payments table from sale prices."""
    rows = []
    for _, txn in transactions_df.iterrows():
        sale_price = txn["sale_price"]
        deposit_pct = np.random.uniform(0.03, 0.20)
        deposit = round(sale_price * deposit_pct, 2)
        financed = round(sale_price - deposit, 2)
        closing_costs = round(sale_price * np.random.uniform(0.02, 0.05), 2)
        status = np.random.choice(
            ["cleared", "pending", "failed"], p=[0.92, 0.06, 0.02]
        )
        rows.append({
            "payment_id": int(txn["transaction_id"]),
            "transaction_id": int(txn["transaction_id"]),
            "deposit_amount": deposit,
            "financed_amount": financed,
            "closing_costs": closing_costs,
            "payment_status": status,
        })
    return pd.DataFrame(rows)


def main():
    print("Generating properties...")
    properties = generate_properties(N_PROPERTIES)

    print("Generating agents...")
    agents = generate_agents(N_AGENTS)

    print("Generating parties...")
    parties = generate_parties(N_PARTIES)

    print("Generating transactions...")
    transactions = generate_transactions(N_TRANSACTIONS, N_PROPERTIES, N_AGENTS, N_PARTIES)

    print("Generating transaction payments...")
    payments = generate_transaction_payments(transactions)

    # ---- Data quality checks (a real ETL pipeline validates before loading) ----
    assert properties["property_id"].is_unique, "Duplicate property_id detected"
    assert agents["license_number"].is_unique, "Duplicate license_number detected"
    assert parties["email"].is_unique, "Duplicate party email detected"
    assert (transactions["buyer_party_id"] != transactions["seller_party_id"]).all(), "Buyer == seller in some row"
    assert (transactions["sale_price"] > 0).all(), "Non-positive sale_price detected"
    print("Data quality checks passed.")

    print("Writing CSVs to data/...")
    properties.to_csv("data/properties.csv", index=False)
    agents.to_csv("data/agents.csv", index=False)
    parties.to_csv("data/parties.csv", index=False)
    transactions.to_csv("data/transactions.csv", index=False)
    payments.to_csv("data/transaction_payments.csv", index=False)

    print(f"Done. Generated {len(properties)} properties, {len(agents)} agents, "
          f"{len(parties)} parties, {len(transactions)} transactions, "
          f"{len(payments)} payment records.")


if __name__ == "__main__":
    main()
