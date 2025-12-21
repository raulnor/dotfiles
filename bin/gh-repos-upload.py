#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "gspread",
#   "google-auth",
# ]
# ///

import json
import subprocess
import gspread

# Fetch repos using gh CLI
result = subprocess.run(
    ["gh", "repo", "list", "--source", "--no-archived", "--json", "name,description,visibility,updatedAt"],
    capture_output=True,
    text=True,
    check=True,
)

repos = json.loads(result.stdout)

# Convert to rows with header
rows = [["NAME", "DESCRIPTION", "VISIBILITY", "UPDATED"]]
for repo in repos:
    rows.append([
        repo.get("name", ""),
        repo.get("description") or "",
        repo.get("visibility", ""),
        repo.get("updatedAt", ""),
    ])

# Update Google Sheet
gc = gspread.service_account()  # Uses ~/.config/gspread/service_account.json
sh = gc.open_by_key("1AUasleAZmbjRzw6kCkaRpkw5LP34_Msu7OFrBjT8u-k")
worksheet = sh.get_worksheet(1)

worksheet.update(values=rows, range_name="A1")
total_rows = len(rows)
if worksheet.row_count > total_rows:
    worksheet.delete_rows(total_rows + 1, worksheet.row_count)

print(f"Updated {len(repos)} repos to sheet")