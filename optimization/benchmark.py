"""
benchmark.py

Runs each of the 5 representative queries against PostgreSQL,
BEFORE and AFTER indexes/restructuring are applied, and reports
the actual percentage latency improvement. This produces the
real, defensible number behind a claim like "reduced latency by
over 40%" -- not a guess.

Credentials are read from the PG_PASSWORD environment variable,
not hardcoded, so real passwords never end up committed to Git.
Set it before running (PowerShell):
    $env:PG_PASSWORD = "your_postgres_password"

Usage:
    1. Load schema + data, run BEFORE benchmark:
       python benchmark.py --phase before
    2. Apply optimization/after/postgres_add_indexes.sql
    3. Run AFTER benchmark:
       python benchmark.py --phase after
    4. Compare the two output files in results/
"""

import argparse
import json
import os
import time
from pathlib import Path
from sqlalchemy import create_engine, text

PG_PASSWORD = os.environ.get("PG_PASSWORD", "")
PG_CONN_STRING = f"postgresql+psycopg2://postgres:{PG_PASSWORD}@localhost:5432/sales_log"
N_RUNS = 5  # run each query 5x and average -- reduces noise from caching/OS variance

QUERIES = {
    "q1_agent_lookup": """
        SELECT t.transaction_id, t.sale_date, t.sale_price, p.address
        FROM transactions t
        JOIN properties p ON p.property_id = t.property_id
        WHERE t.agent_id = 23
    """,
    "q2_date_range": """
        SELECT transaction_id, sale_date, sale_price
        FROM transactions
        WHERE sale_date BETWEEN '2026-01-01' AND '2026-03-31'
        ORDER BY sale_date
    """,
    "q3_party_history_or": """
        SELECT t.transaction_id, t.sale_date, t.sale_price
        FROM transactions t
        WHERE t.buyer_party_id = 1500 OR t.seller_party_id = 1500
    """,
    "q4_high_value_join": """
        SELECT t.transaction_id, t.sale_price, tp.payment_status
        FROM transactions t
        JOIN transaction_payments tp ON tp.transaction_id = t.transaction_id
        WHERE t.sale_price > 500000
        ORDER BY t.sale_price DESC
    """,
    "q5_agent_leaderboard": """
        SELECT a.agent_id, COUNT(*) AS deal_count, SUM(t.sale_price) AS total_volume
        FROM transactions t
        JOIN agents a ON a.agent_id = t.agent_id
        GROUP BY a.agent_id
        ORDER BY total_volume DESC
        LIMIT 10
    """,
}

# Query 3's restructured version, used only in the "after" phase
QUERY_3_RESTRUCTURED = """
    SELECT transaction_id, sale_date, sale_price FROM transactions WHERE buyer_party_id = 1500
    UNION ALL
    SELECT transaction_id, sale_date, sale_price FROM transactions WHERE seller_party_id = 1500
"""


def time_query(engine, sql: str, n_runs: int = N_RUNS) -> float:
    """Runs a query n_runs times, returns the average wall-clock time in ms."""
    durations = []
    with engine.connect() as conn:
        for _ in range(n_runs):
            start = time.perf_counter()
            conn.execute(text(sql)).fetchall()
            durations.append((time.perf_counter() - start) * 1000)
    return sum(durations) / len(durations)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--phase", choices=["before", "after"], required=True)
    args = parser.parse_args()

    engine = create_engine(PG_CONN_STRING)
    results = {}

    for name, sql in QUERIES.items():
        query_to_run = sql
        if args.phase == "after" and name == "q3_party_history_or":
            query_to_run = QUERY_3_RESTRUCTURED
        avg_ms = time_query(engine, query_to_run)
        results[name] = round(avg_ms, 2)
        print(f"  {name}: {avg_ms:.2f} ms (avg of {N_RUNS} runs)")

    Path("results").mkdir(exist_ok=True)
    out_path = f"results/{args.phase}_benchmark.json"
    with open(out_path, "w") as f:
        json.dump(results, f, indent=2)
    print(f"\nResults written to {out_path}")

    # If both before/after results exist, print the comparison
    before_path = Path("results/before_benchmark.json")
    after_path = Path("results/after_benchmark.json")
    if before_path.exists() and after_path.exists():
        before = json.loads(before_path.read_text())
        after = json.loads(after_path.read_text())
        print("\n=== BEFORE vs AFTER ===")
        total_before, total_after = 0, 0
        for name in before:
            b, a = before[name], after.get(name)
            if a is None:
                continue
            pct = ((b - a) / b) * 100
            total_before += b
            total_after += a
            print(f"  {name}: {b:.2f}ms -> {a:.2f}ms  ({pct:+.1f}%)")
        overall_pct = ((total_before - total_after) / total_before) * 100
        print(f"\n  OVERALL latency reduction: {overall_pct:.1f}%")


if __name__ == "__main__":
    main()