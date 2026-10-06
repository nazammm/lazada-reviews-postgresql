"""Build the README charts from the query results in results/."""

from pathlib import Path

import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import numpy as np
import pandas as pd

import chart_style as cs

ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "results"
IMAGES = ROOT / "images"
SOURCE = "Source: Lazada Indonesian Reviews (Kaggle, scraped 2 Oct 2019). Queries in sql/analysis."


def listing_overlap() -> None:
    df = pd.read_csv(RESULTS / "02_listing_overlap.csv")
    x = np.arange(len(df))
    width = 0.38
    fig, ax = plt.subplots(figsize=(8, 4.2))
    ax.bar(x - width / 2, df["raw_rows"], width, color=cs.NEUTRAL, label="Rows in the raw CSV")
    ax.bar(x + width / 2, df["unique_reviews"], width, color=cs.SERIES[0], label="Unique reviews")
    ax.set_xticks(x, [f"{p} page{'s' if p > 1 else ''}" for p in df["listing_pages"]])
    ax.set_xlabel("Number of listing pages the item appeared on")
    ax.yaxis.set_major_formatter(mtick.FuncFormatter(lambda v, _: f"{v / 1000:.0f}k"))
    ax.legend(loc="upper right")
    cs.titles(fig, "The same review was scraped once per listing page",
              "203,787 rows hold 80,092 unique reviews; items on five pages appear five times",
              SOURCE)
    cs.save(fig, IMAGES / "01_listing_overlap.png")


def quarterly_trend() -> None:
    df = pd.read_csv(RESULTS / "04_quarterly_trend.csv", parse_dates=["quarter"])
    labels = [f"{d.year} Q{(d.month - 1) // 3 + 1}" for d in df["quarter"]]
    x = np.arange(len(df))
    fig, (top, bottom) = plt.subplots(2, 1, figsize=(9, 5.6), sharex=True,
                                      gridspec_kw={"height_ratios": [1.4, 1], "hspace": 0.25})
    top.plot(x, df["negative_pct"], color=cs.NEUTRAL, lw=1.5, marker="o", ms=4, label="Quarter")
    top.plot(x, df["negative_pct_4q_avg"], color=cs.SERIES[0], lw=2.2, label="4-quarter average")
    top.set_ylabel("1-2 star reviews")
    top.yaxis.set_major_formatter(mtick.PercentFormatter(decimals=0))
    top.set_ylim(0, 13)
    top.legend(loc="upper left", ncol=2)
    peak = df["negative_pct"].idxmax()
    top.annotate(f"{df.loc[peak, 'negative_pct']:.1f}%", (x[peak], df.loc[peak, "negative_pct"]),
                 xytext=(0, 8), textcoords="offset points", ha="center", fontsize=9, color=cs.INK)
    bottom.bar(x, df["reviews"], color=cs.SERIES[0], width=0.7)
    bottom.set_ylabel("Reviews")
    bottom.yaxis.set_major_formatter(mtick.FuncFormatter(lambda v, _: f"{v / 1000:.0f}k"))
    bottom.set_xticks(x, labels, rotation=45, ha="right")
    cs.titles(fig, "Negative reviews peaked in late 2017, then halved",
              "Share of 1-2 star reviews by purchase quarter (quarters with 300+ reviews)",
              SOURCE)
    cs.save(fig, IMAGES / "02_quarterly_trend.png")


def product_types() -> None:
    df = pd.read_csv(RESULTS / "05_product_type_scorecard.csv")
    df = df.sort_values("negative_pct")
    fig, ax = plt.subplots(figsize=(8, 3.6))
    colors = [cs.NEUTRAL if t == "Unclassified" else cs.SERIES[0] for t in df["product_type"]]
    ax.barh(df["product_type"], df["negative_pct"], color=colors, height=0.6)
    for y, (v, n) in enumerate(zip(df["negative_pct"], df["reviews"])):
        ax.text(v + 0.15, y, f"{v:.1f}%  ({n:,} reviews)", va="center", fontsize=9, color=cs.INK)
    ax.grid(axis="y", visible=False)
    ax.grid(axis="x", visible=True)
    ax.xaxis.set_major_formatter(mtick.PercentFormatter(decimals=0))
    ax.set_xlim(0, 11)
    cs.titles(fig, "Flash drives draw the most 1-2 star reviews",
              "Share of negative reviews by product type, inferred from review text",
              SOURCE)
    cs.save(fig, IMAGES / "03_product_types.png")


def complaint_themes() -> None:
    df = pd.read_csv(RESULTS / "06_complaint_themes.csv")
    types = ["Flash drive", "TV", "Laptop", "External hard drive"]
    themes = (df[df["product_type"].isin(types)]
              .groupby("theme")["reviews_mentioning"].sum()
              .sort_values(ascending=False).index.tolist())
    grid = (df.pivot_table(index="theme", columns="product_type", values="pct_of_negative")
              .reindex(index=themes, columns=types).fillna(0))
    fig, ax = plt.subplots(figsize=(8.4, 4.2))
    cmap = plt.matplotlib.colors.LinearSegmentedColormap.from_list("blues", cs.BLUES)
    im = ax.imshow(grid.values, cmap=cmap, vmin=0, vmax=max(25, grid.values.max()), aspect="auto")
    ax.set_xticks(range(len(types)), types)
    ax.set_yticks(range(len(themes)), themes)
    ax.grid(False)
    for i in range(grid.shape[0]):
        for j in range(grid.shape[1]):
            v = grid.values[i, j]
            ax.text(j, i, f"{v:.0f}%", ha="center", va="center", fontsize=9,
                    color="white" if v >= 14 else cs.INK)
    for spine in ax.spines.values():
        spine.set_visible(False)
    cs.titles(fig, "Broken units are the main complaint for every product type",
              "Share of 1-2 star reviews that mention each theme (keyword match, Indonesian)",
              SOURCE)
    cs.save(fig, IMAGES / "04_complaint_themes.png")


def helpful_votes() -> None:
    df = pd.read_csv(RESULTS / "09_helpful_votes.csv")
    fig, ax = plt.subplots(figsize=(7.5, 3.8))
    colors = [cs.SERIES[0] if r == 1 else cs.NEUTRAL for r in df["rating"]]
    ax.bar(df["rating"].astype(str) + " star", df["avg_likes"], color=colors, width=0.6)
    for x, v in enumerate(df["avg_likes"]):
        ax.text(x, v + 0.06, f"{v:.2f}", ha="center", fontsize=9, color=cs.INK)
    ax.set_ylabel("Average likes per review")
    one_star = df.loc[df["rating"] == 1].iloc[0]
    cs.titles(fig, "Shoppers up-vote 1-star reviews far more than praise",
              f"1-star reviews are {one_star['reviews'] / df['reviews'].sum():.0%} of written reviews "
              f"but collect {one_star['pct_of_all_likes']:.0f}% of all likes",
              SOURCE)
    cs.save(fig, IMAGES / "05_helpful_votes.png")


if __name__ == "__main__":
    cs.apply()
    IMAGES.mkdir(exist_ok=True)
    listing_overlap()
    quarterly_trend()
    product_types()
    complaint_themes()
    helpful_votes()
    print("Charts written to", IMAGES)
