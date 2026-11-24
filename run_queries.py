"""Run every query in queries/ against flights.db, print a preview and save results as CSV."""
import csv
import sqlite3
from pathlib import Path

HERE = Path(__file__).parent

with sqlite3.connect(HERE / "flights.db") as con:
    for path in sorted((HERE / "queries").glob("*.sql")):
        cur = con.execute(path.read_text(encoding="utf-8"))
        cols = [d[0] for d in cur.description]
        rows = cur.fetchall()
        out = HERE / "results" / f"{path.stem}.csv"
        with open(out, "w", newline="", encoding="utf-8") as f:
            csv.writer(f).writerows([cols, *rows])
        print(f"\n== {path.name}  ({len(rows)} rows)")
        print(" | ".join(cols))
        for r in rows[:12]:
            print(" | ".join(str(v) for v in r))
