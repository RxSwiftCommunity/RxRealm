#!/usr/bin/env python3
"""Summarize SwiftPM code coverage for the package's own sources and enforce a floor.

Usage: scripts/coverage-report.py <codecov.json> [--min-lines PERCENT]

<codecov.json> is the file printed by `swift test --show-codecov-path` after
`swift test --enable-code-coverage`. The Markdown table is printed to stdout and,
on GitHub Actions, appended to the job summary.
"""

import argparse
import json
import os
import sys

parser = argparse.ArgumentParser()
parser.add_argument("codecov_json")
parser.add_argument("--min-lines", type=float, default=0)
args = parser.parse_args()

sources = os.path.join(os.getcwd(), "Sources") + os.sep
with open(args.codecov_json) as f:
    files = [f for f in json.load(f)["data"][0]["files"] if f["filename"].startswith(sources)]

if not files:
    sys.exit(f"No coverage data for files under {sources}")

kinds = ["lines", "functions", "regions"]
totals = {kind: [0, 0] for kind in kinds}
rows = []
for f in sorted(files, key=lambda f: f["filename"]):
    summary = f["summary"]
    for kind in kinds:
        totals[kind][0] += summary[kind]["covered"]
        totals[kind][1] += summary[kind]["count"]
    rows.append([os.path.relpath(f["filename"])] + [f"{summary[kind]['percent']:.1f}%" for kind in kinds])


def percent(kind):
    covered, count = totals[kind]
    return 100 * covered / count if count else 100.0


rows.append(["**Total**"] + [f"**{percent(kind):.1f}%**" for kind in kinds])
table = ["| File | Lines | Functions | Regions |", "| --- | ---: | ---: | ---: |"]
table += ["| " + " | ".join(row) + " |" for row in rows]
report = "### Code coverage\n\n" + "\n".join(table) + "\n"

print(report)
if summary_path := os.environ.get("GITHUB_STEP_SUMMARY"):
    with open(summary_path, "a") as f:
        f.write(report)

if percent("lines") < args.min_lines:
    sys.exit(f"Line coverage {percent('lines'):.1f}% is below the {args.min_lines:.0f}% floor")
