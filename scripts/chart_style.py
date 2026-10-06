"""Shared matplotlib settings so every chart in the project looks the same."""

import matplotlib as mpl
import matplotlib.pyplot as plt

INK = "#1f1f1d"
MUTED = "#6b6a66"
GRID = "#e4e3df"
SURFACE = "#fcfcfb"

# Categorical colours, used in this order.
SERIES = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#008300", "#4a3aa7", "#e34948"]
NEUTRAL = "#b8b7b2"

# Single-hue ramp for magnitude (light to dark).
BLUES = ["#cde2fb", "#9ec5f4", "#6da7ec", "#3987e5", "#2a78d6", "#1c5cab", "#104281"]


def apply() -> None:
    mpl.rcParams.update({
        "figure.facecolor": SURFACE,
        "axes.facecolor": SURFACE,
        "savefig.facecolor": SURFACE,
        "font.family": "DejaVu Sans",
        "font.size": 10,
        "text.color": INK,
        "axes.labelcolor": MUTED,
        "axes.edgecolor": GRID,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "axes.grid": True,
        "axes.grid.axis": "y",
        "axes.axisbelow": True,
        "grid.color": GRID,
        "grid.linewidth": 0.8,
        "xtick.color": MUTED,
        "ytick.color": MUTED,
        "xtick.major.size": 0,
        "ytick.major.size": 0,
        "legend.frameon": False,
        "figure.dpi": 110,
        "savefig.dpi": 160,
        "savefig.bbox": "tight",
    })


def titles(fig, title: str, subtitle: str | None = None, source: str | None = None) -> None:
    """Left-aligned title and subtitle above the plot, source note below it."""
    fig.text(0.0, 1.06, title, fontsize=13, fontweight="bold", color=INK, ha="left", transform=fig.transFigure)
    if subtitle:
        fig.text(0.0, 1.0, subtitle, fontsize=10, color=MUTED, ha="left", transform=fig.transFigure)
    if source:
        fig.text(0.0, -0.04, source, fontsize=8, color=MUTED, ha="left", transform=fig.transFigure)


def save(fig, path) -> None:
    fig.savefig(path)
    plt.close(fig)
