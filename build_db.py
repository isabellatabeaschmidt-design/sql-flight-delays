"""Load the nycflights13 CSV files into a local SQLite database (flights.db).

Uses only the Python standard library. "NA" in the source files becomes NULL.
"""
import csv
import io
import sqlite3
import zipfile
from pathlib import Path

HERE = Path(__file__).parent
DATA = HERE / "data"
DB = HERE / "flights.db"

# Column types per table; everything not listed is TEXT.
NUMERIC = {
    "flights": {"year", "month", "day", "dep_time", "sched_dep_time", "dep_delay", "arr_time",
                "sched_arr_time", "arr_delay", "flight", "air_time", "distance", "hour", "minute"},
    "weather": {"year", "month", "day", "hour", "temp", "dewp", "humid", "wind_dir",
                "wind_speed", "wind_gust", "precip", "pressure", "visib"},
    "planes": {"year", "engines", "seats", "speed"},
    "airports": {"lat", "lon", "alt", "tz"},
    "airlines": set(),
}


def rows_from(name: str):
    if name == "flights":
        with zipfile.ZipFile(DATA / "flights.csv.zip") as z:
            yield from csv.reader(io.TextIOWrapper(z.open("flights.csv"), encoding="utf-8"))
    else:
        with open(DATA / f"{name}.csv", encoding="utf-8") as f:
            yield from csv.reader(f)


def load(con: sqlite3.Connection, name: str) -> int:
    rows = rows_from(name)
    header = next(rows)
    cols = ", ".join(f'"{c}" {"REAL" if c in NUMERIC[name] else "TEXT"}' for c in header)
    con.execute(f'DROP TABLE IF EXISTS "{name}"')
    con.execute(f'CREATE TABLE "{name}" ({cols})')
    marks = ", ".join("?" for _ in header)
    clean = ([None if v in ("NA", "") else v for v in r] for r in rows)
    con.executemany(f'INSERT INTO "{name}" VALUES ({marks})', clean)
    return con.execute(f'SELECT COUNT(*) FROM "{name}"').fetchone()[0]


if __name__ == "__main__":
    DB.unlink(missing_ok=True)
    with sqlite3.connect(DB) as con:
        for table in ["airlines", "airports", "planes", "weather", "flights"]:
            print(f"{table:9s} {load(con, table):>7,d} rows")
        con.execute("CREATE INDEX idx_flights_origin_time ON flights(origin, time_hour)")
        con.execute("CREATE INDEX idx_weather_origin_time ON weather(origin, time_hour)")
    print(f"Saved {DB.name}")
