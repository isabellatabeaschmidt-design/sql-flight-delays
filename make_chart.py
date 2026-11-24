"""Draw the chart for the README from results/05_weather_impact.csv."""
import csv
from pathlib import Path

import matplotlib.pyplot as plt

HERE = Path(__file__).parent
rows = list(csv.DictReader(open(HERE / "results" / "05_weather_impact.csv", encoding="utf-8")))
labels = [r["visibility"].split(": ")[1] for r in rows]
values = [float(r["delayed_over_15_pct"]) for r in rows]
shares = [float(r["share_of_flights_pct"]) for r in rows]

plt.rcParams.update({"font.family": "Helvetica Neue", "font.size": 10})
fig, ax = plt.subplots(figsize=(6.2, 2.6), dpi=200)
colors = ["#d9481c" if i < 2 else "#9aa09c" for i in range(len(values))]  # under 3 miles = poor visibility
bars = ax.barh(labels[::-1], values[::-1], color=colors[::-1], height=0.6)
for b, v, s in zip(bars, values[::-1], shares[::-1]):
    ax.text(b.get_width() + 0.6, b.get_y() + b.get_height() / 2,
            f"{v:.0f}%   ({s:.0f}% of flights)", va="center", fontsize=8.5, color="#1d2321")
ax.set_xlim(0, 50)
ax.set_xlabel("Share of departures delayed by more than 15 minutes", fontsize=8.5, color="#626a66")
ax.set_ylabel("Visibility at departure", fontsize=8.5, color="#626a66")
for side in ["top", "right", "left"]:
    ax.spines[side].set_visible(False)
ax.tick_params(axis="y", length=0)
ax.tick_params(colors="#1d2321", labelsize=8.5)
fig.tight_layout()
fig.savefig(HERE / "results" / "weather_delay.png", facecolor="white")
print("saved results/weather_delay.png")
