#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "fitdecode",
#     "visidata",
# ]
# ///
"""
strava-compare.py -- mile-by-mile comparison of two Strava-export activities.

Reads two activity files (.fit / .gpx / .tcx, optionally .gz), computes per-split
stats (pace, avg HR, elevation gain, avg cadence), and prints a side-by-side
comparison. Works entirely on exported files -- no Strava API.

Usage:
    python strava-compare.py A.fit B.gpx
    python strava-compare.py A.fit B.fit --label-a "Race 2024" --label-b "Race 2025"
    python strava-compare.py A.gpx B.gpx --km --csv out.csv
"""
import argparse
import bisect
import gzip
import math
import os
import re
import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from datetime import datetime

METERS_PER_MILE = 1609.344
METERS_PER_KM = 1000.0


@dataclass
class Records:
    t: list = field(default_factory=list)    # seconds from start
    d: list = field(default_factory=list)    # cumulative distance, meters
    alt: list = field(default_factory=list)  # altitude, meters (None allowed)
    hr: list = field(default_factory=list)   # heart rate bpm (None allowed)
    cad: list = field(default_factory=list)  # cadence spm/rpm (None allowed)


# ---------------------------------------------------------------------------
# File reading
# ---------------------------------------------------------------------------
def _open_maybe_gz(path, mode="rb"):
    if path.endswith(".gz"):
        return gzip.open(path, mode)
    return open(path, mode)


def _base_ext(path):
    p = path[:-3] if path.endswith(".gz") else path
    return os.path.splitext(p)[1].lower()


def _haversine(lat1, lon1, lat2, lon2):
    R = 6371000.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp = math.radians(lat2 - lat1)
    dl = math.radians(lon2 - lon1)
    a = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * R * math.asin(math.sqrt(a))


def read_fit(path):
    import fitdecode
    rec = Records()
    t0 = None
    with _open_maybe_gz(path) as fh, fitdecode.FitReader(fh) as fit:
        for frame in fit:
            if not (isinstance(frame, fitdecode.FitDataMessage) and frame.name == "record"):
                continue
            g = lambda k: frame.get_value(k) if frame.has_field(k) else None
            ts = g("timestamp")
            if ts is None:
                continue
            if t0 is None:
                t0 = ts
            rec.t.append((ts - t0).total_seconds())
            rec.d.append(g("distance"))
            rec.alt.append(g("enhanced_altitude") if frame.has_field("enhanced_altitude") else g("altitude"))
            rec.hr.append(g("heart_rate"))
            rec.cad.append(g("cadence"))
    _fill_distance(rec)
    return rec


def _local(tag):
    return tag.rsplit("}", 1)[-1].lower()


def read_gpx(path):
    from datetime import datetime
    with _open_maybe_gz(path, "rt") as fh:
        tree = ET.parse(fh)
    rec = Records()
    t0 = None
    lastlat = lastlon = None
    cum = 0.0
    for tp in tree.iter():
        if _local(tp.tag) != "trkpt":
            continue
        lat = float(tp.attrib["lat"])
        lon = float(tp.attrib["lon"])
        ele = ts = hr = cad = None
        for child in tp.iter():
            name = _local(child.tag)
            if name == "ele" and child.text:
                ele = float(child.text)
            elif name == "time" and child.text:
                ts = child.text
            elif name == "hr" and child.text:
                hr = float(child.text)
            elif name in ("cad", "cadence") and child.text:
                cad = float(child.text)
        if ts is None:
            continue
        stamp = datetime.fromisoformat(ts.replace("Z", "+00:00"))
        if t0 is None:
            t0 = stamp
        rec.t.append((stamp - t0).total_seconds())
        if lastlat is not None:
            cum += _haversine(lastlat, lastlon, lat, lon)
        lastlat, lastlon = lat, lon
        rec.d.append(cum)
        rec.alt.append(ele)
        rec.hr.append(hr)
        rec.cad.append(cad)
    return rec


def read_tcx(path):
    with _open_maybe_gz(path, "rt") as fh:
        tree = ET.parse(fh)
    rec = Records()
    from datetime import datetime
    t0 = None
    for tp in tree.iter():
        if _local(tp.tag) != "trackpoint":
            continue
        vals = {}
        hr = None
        for child in tp.iter():
            name = _local(child.tag)
            if name == "time" and child.text:
                vals["time"] = child.text
            elif name == "distancemeters" and child.text:
                vals["dist"] = float(child.text)
            elif name == "altitudemeters" and child.text:
                vals["alt"] = float(child.text)
            elif name == "value" and child.text:  # HeartRateBpm/Value
                hr = float(child.text)
            elif name == "cadence" and child.text:
                vals["cad"] = float(child.text)
        if "time" not in vals:
            continue
        ts = datetime.fromisoformat(vals["time"].replace("Z", "+00:00"))
        if t0 is None:
            t0 = ts
        rec.t.append((ts - t0).total_seconds())
        rec.d.append(vals.get("dist"))
        rec.alt.append(vals.get("alt"))
        rec.hr.append(hr)
        rec.cad.append(vals.get("cad"))
    _fill_distance(rec)
    return rec


def _fill_distance(rec):
    """If distance is missing, leave as-is (FIT/TCX usually have it)."""
    if any(d is None for d in rec.d):
        # forward-fill so interpolation stays monotonic
        last = 0.0
        for i, d in enumerate(rec.d):
            if d is None:
                rec.d[i] = last
            else:
                last = rec.d[i]


def read_activity(path):
    ext = _base_ext(path)
    if ext == ".fit":
        return read_fit(path)
    if ext == ".gpx":
        return read_gpx(path)
    if ext == ".tcx":
        return read_tcx(path)
    raise ValueError(f"Unsupported file type: {path}")


# ---------------------------------------------------------------------------
# Human labels from the export's activities.csv
# ---------------------------------------------------------------------------
def _activity_id(path):
    """Strava's numeric id + the bare filename, from a path like .../2830239434.fit.gz"""
    base = os.path.basename(path)
    stripped = base[:-3] if base.endswith(".gz") else base
    return os.path.splitext(stripped)[0], base


def find_activities_csv(path, override=None):
    if override:
        return override if os.path.exists(override) else None
    d = os.path.dirname(os.path.abspath(path))
    # files live in export/activities/<id>...; the csv sits one or two levels up
    for cand in (d, os.path.dirname(d), os.path.dirname(os.path.dirname(d))):
        p = os.path.join(cand, "activities.csv")
        if os.path.exists(p):
            return p
    return None


def _short_date(s):
    """Trim Strava's date-time string down to just the date part."""
    s = s.strip()
    if not s:
        return s
    if s[:4].isdigit():                       # '2018-01-06 13:00:14' / '...T...'
        return s.replace("T", " ").split(" ")[0]
    parts = [p.strip() for p in s.split(",")]  # 'Jan 6, 2018, 8:00:14 AM'
    if parts and (":" in parts[-1] or parts[-1][-2:] in ("AM", "PM")):
        parts = parts[:-1]
    return ", ".join(parts)


def label_from_csv(path, csv_path):
    import csv as _csv
    act_id, base = _activity_id(path)
    try:
        with open(csv_path, newline="", encoding="utf-8-sig") as f:
            for row in _csv.DictReader(f):
                fn = (row.get("Filename") or "").replace("\\", "/")
                rid = (row.get("Activity ID") or "").strip()
                if fn.endswith(base) or (act_id and rid == act_id):
                    name = (row.get("Activity Name") or "").strip()
                    date = _short_date(row.get("Activity Date") or "")
                    if not name:
                        return None
                    return f"{name} ({date})" if date else name
    except Exception:
        return None
    return None


def resolve_label(path, explicit, override_csv):
    if explicit:
        return explicit
    csv_path = find_activities_csv(path, override_csv)
    if csv_path:
        lab = label_from_csv(path, csv_path)
        if lab:
            return lab
    return os.path.basename(path)


# ---------------------------------------------------------------------------
# Splits
# ---------------------------------------------------------------------------
def _time_at_distance(d, t, target):
    """Linear-interpolate the elapsed time at a cumulative distance."""
    i = bisect.bisect_left(d, target)
    if i <= 0:
        return t[0]
    if i >= len(d):
        return t[-1]
    d0, d1 = d[i - 1], d[i]
    t0, t1 = t[i - 1], t[i]
    if d1 == d0:
        return t1
    frac = (target - d0) / (d1 - d0)
    return t0 + frac * (t1 - t0)


def _mean(vals):
    vals = [v for v in vals if v is not None]
    return sum(vals) / len(vals) if vals else None


def compute_splits(rec, unit_m):
    d, t, alt, hr, cad = rec.d, rec.t, rec.alt, rec.hr, rec.cad
    if len(d) < 2:
        return []
    total = d[-1]
    n_full = int(total // unit_m)
    boundaries = [k * unit_m for k in range(n_full + 1)]
    if total - boundaries[-1] > 1.0:  # trailing partial split
        boundaries.append(total)

    splits = []
    for k in range(1, len(boundaries)):
        lo, hi = boundaries[k - 1], boundaries[k]
        seg_time = _time_at_distance(d, t, hi) - _time_at_distance(d, t, lo)
        seg_len = hi - lo
        # samples whose cumulative distance falls in [lo, hi)
        idx = [i for i in range(len(d)) if lo <= d[i] < hi] or [
            i for i in range(len(d)) if lo <= d[i] <= hi
        ]
        gain = 0.0
        for a, b in zip(idx, idx[1:]):
            if alt[a] is not None and alt[b] is not None:
                diff = alt[b] - alt[a]
                if diff > 0:
                    gain += diff
        pace = seg_time / (seg_len / unit_m) if seg_len else None  # sec per full unit
        splits.append({
            "unit": k,
            "dist_units": seg_len / unit_m,
            "time_s": seg_time,
            "pace_s": pace,
            "hr": _mean([hr[i] for i in idx]),
            "cad": _mean([cad[i] for i in idx]),
            "gain_m": gain,
        })
    return splits


# ---------------------------------------------------------------------------
# Formatting
# ---------------------------------------------------------------------------
def fmt_pace(sec):
    if sec is None:
        return "   -  "
    m, s = divmod(int(round(sec)), 60)
    return f"{m:d}:{s:02d}"


def fmt_delta_pace(sec):
    if sec is None:
        return "   -  "
    sign = "+" if sec >= 0 else "-"
    m, s = divmod(int(round(abs(sec))), 60)
    return f"{sign}{m:d}:{s:02d}"


def _n(v, dp=0):
    return "-" if v is None else (f"{v:.{dp}f}")


def print_comparison(sa, sb, la, lb, unit_label, feet):
    conv = 3.28084 if feet else 1.0
    ele_u = "ft" if feet else "m"
    n = max(len(sa), len(sb))
    print()
    print(f"Mile-by-mile: {la}  vs  {lb}")
    print("=" * 78)
    header = (f"{unit_label:>4} | {'pace A':>7} {'pace B':>7} {'Δ':>7} | "
              f"{'HR A':>5} {'HR B':>5} {'Δ':>5} | {'+'+ele_u+' A':>6} {'+'+ele_u+' B':>6}")
    print(header)
    print("-" * 78)
    for i in range(n):
        a = sa[i] if i < len(sa) else None
        b = sb[i] if i < len(sb) else None
        idx = (a or b)["unit"]
        pa = a["pace_s"] if a else None
        pb = b["pace_s"] if b else None
        dp = (pb - pa) if (pa is not None and pb is not None) else None
        ha = a["hr"] if a else None
        hb = b["hr"] if b else None
        dh = (hb - ha) if (ha is not None and hb is not None) else None
        ga = a["gain_m"] * conv if a else None
        gb = b["gain_m"] * conv if b else None
        print(f"{idx:>4} | {fmt_pace(pa):>7} {fmt_pace(pb):>7} {fmt_delta_pace(dp):>7} | "
              f"{_n(ha):>5} {_n(hb):>5} {('+' if (dh or 0)>=0 else '')+_n(dh) if dh is not None else '-':>5} | "
              f"{_n(ga):>6} {_n(gb):>6}")
    print("-" * 78)
    _summary_row(sa, sb, conv, ele_u)


def _totals(splits, conv):
    tot_t = sum(s["time_s"] for s in splits)
    tot_d = sum(s["dist_units"] for s in splits)
    hrs = [s["hr"] for s in splits if s["hr"] is not None]
    gain = sum(s["gain_m"] for s in splits) * conv
    pace = tot_t / tot_d if tot_d else None
    hr = sum(hrs) / len(hrs) if hrs else None
    return pace, hr, gain, tot_t


def _summary_row(sa, sb, conv, ele_u):
    pa, ha, ga, ta = _totals(sa, conv)
    pb, hb, gb, tb = _totals(sb, conv)
    dp = (pb - pa) if (pa is not None and pb is not None) else None
    dh = (hb - ha) if (ha is not None and hb is not None) else None
    print(f"{'AVG':>4} | {fmt_pace(pa):>7} {fmt_pace(pb):>7} {fmt_delta_pace(dp):>7} | "
          f"{_n(ha):>5} {_n(hb):>5} {('+' if (dh or 0)>=0 else '')+_n(dh) if dh is not None else '-':>5} | "
          f"{_n(ga):>6} {_n(gb):>6}")
    print(f"     total time  A {fmt_hms(ta)}   B {fmt_hms(tb)}   Δ {fmt_delta_hms(tb-ta)}")


def fmt_hms(sec):
    h, r = divmod(int(round(sec)), 3600)
    m, s = divmod(r, 60)
    return f"{h}:{m:02d}:{s:02d}" if h else f"{m}:{s:02d}"


def fmt_delta_hms(sec):
    sign = "+" if sec >= 0 else "-"
    return sign + fmt_hms(abs(sec))


def write_csv(sa, sb, la, lb, unit_label, path):
    import csv
    n = max(len(sa), len(sb))
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow([unit_label, f"pace_{la}", f"pace_{lb}", "d_pace_s",
                    f"hr_{la}", f"hr_{lb}", f"gain_m_{la}", f"gain_m_{lb}"])
        for i in range(n):
            a = sa[i] if i < len(sa) else {}
            b = sb[i] if i < len(sb) else {}
            idx = (sa[i] if i < len(sa) else sb[i])["unit"]
            pa, pb = a.get("pace_s"), b.get("pace_s")
            w.writerow([idx, fmt_pace(pa), fmt_pace(pb),
                        (pb - pa) if (pa and pb) else "",
                        _n(a.get("hr")), _n(b.get("hr")),
                        _n(a.get("gain_m"), 1), _n(b.get("gain_m"), 1)])
    print(f"\nWrote {path}")


# ---------------------------------------------------------------------------
# Interactive picker (browse activities.csv, choose two)
# ---------------------------------------------------------------------------
_DATE_FORMATS = [
    "%b %d, %Y, %I:%M:%S %p", "%B %d, %Y, %I:%M:%S %p",
    "%Y-%m-%d %H:%M:%S", "%Y-%m-%dT%H:%M:%S", "%Y-%m-%d", "%b %d, %Y",
]


def _parse_date(s):
    s = s.strip()
    for fmt in _DATE_FORMATS:
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            continue
    return None


def _approx_miles(v):
    try:
        x = float(v)
    except (TypeError, ValueError):
        return None
    if x <= 0:
        return None
    meters = x if x > 1000 else x * 1000.0   # Strava CSV distance is km or m
    return meters / METERS_PER_MILE


def locate_csv(override, export, anchor):
    if override and os.path.exists(override):
        return override
    if export:
        p = os.path.join(export, "activities.csv")
        if os.path.exists(p):
            return p
    d = os.path.abspath(anchor)
    for _ in range(4):
        p = os.path.join(d, "activities.csv")
        if os.path.exists(p):
            return p
        parent = os.path.dirname(d)
        if parent == d:
            break
        d = parent
    return None


def load_activity_rows(csv_path):
    import csv as _csv
    root = os.path.dirname(os.path.abspath(csv_path))
    rows = []
    with open(csv_path, newline="", encoding="utf-8-sig") as f:
        for r in _csv.DictReader(f):
            fn = (r.get("Filename") or "").replace("\\", "/").strip()
            if not fn:
                continue
            name = (r.get("Activity Name") or "").strip() or f"Activity {r.get('Activity ID','')}"
            ds = r.get("Activity Date") or ""
            rows.append({
                "name": name,
                "date": _short_date(ds),
                "dt": _parse_date(ds),
                "type": (r.get("Activity Type") or "").strip(),
                "dist": _approx_miles(r.get("Distance")),
                "path": os.path.join(root, fn),
                "file": fn,
            })
    rows.sort(key=lambda x: (x["dt"] or datetime.min), reverse=True)
    return rows


def _fmt_row(i, r):
    dist = f"~{r['dist']:.1f} mi" if r["dist"] else ""
    name = r["name"] if len(r["name"]) <= 36 else r["name"][:35] + "\u2026"
    return f"{i:>3}  {r['date']:<13} {name:<36} {r['type']:<5} {dist:>9}"


def interactive_pick(rows, top=20):
    if not rows:
        raise SystemExit("No activities with a Filename found in activities.csv.")
    view = rows
    n_show = min(top, len(view))
    print(f"\n{len(rows)} activities in activities.csv (most recent first).")
    while True:
        shown = view[:n_show]
        print()
        for i, r in enumerate(shown, 1):
            print(_fmt_row(i, r))
        if n_show < len(view):
            print(f"     \u2026 {len(view) - n_show} more")
        print("\nPick two by number (e.g. '2 1'), '/text' to filter by name, "
              "'more' to expand, 'q' to quit.")
        try:
            line = input("select > ").strip()
        except EOFError:
            raise SystemExit("\nNo selection made.")
        if not line:
            continue
        low = line.lower()
        if low in ("q", "quit", "exit"):
            raise SystemExit("Cancelled.")
        if low in ("more", "all"):
            n_show = len(view)
            continue
        if line.startswith("/"):
            term = line[1:].strip().lower()
            match = [r for r in rows if term in r["name"].lower()]
            if match:
                view, n_show = match, min(top, len(match))
            else:
                print("No matches; showing all.")
                view, n_show = rows, min(top, len(rows))
            continue
        nums = [int(t) for t in re.split(r"[\s,]+", line) if t.isdigit()]
        if len(nums) >= 2 and all(1 <= x <= len(shown) for x in nums[:2]):
            return shown[nums[0] - 1], shown[nums[1] - 1]
        if len(nums) == 1 and 1 <= nums[0] <= len(shown):
            a = shown[nums[0] - 1]
            try:
                line2 = input(f"A = {a['name']}. Now pick B > ").strip()
            except EOFError:
                raise SystemExit("\nNo second selection made.")
            n2 = [int(t) for t in re.split(r"[\s,]+", line2) if t.isdigit()]
            if n2 and 1 <= n2[0] <= len(shown):
                return a, shown[n2[0] - 1]
            print("Invalid second selection.")
            continue
        print("Didn't understand that. Enter two numbers, or /text to filter.")


def _label(row):
    return f"{row['name']} ({row['date']})" if row["date"] else row["name"]


# ---------------------------------------------------------------------------
# VisiData front door: browse, select two, compare (comparison is a new sheet)
# ---------------------------------------------------------------------------
def _run_letters(n):
    return [chr(ord("A") + i) for i in range(n)]


def comparison_rows(splits_list, feet, ele):
    """Pure builder: aligned per-mile dicts for any number of runs (A, B, C, ...).

    Keys per row: 'mi', and for each run letter L: 'pace L' (min/mi, float),
    'HR L' (int), '+{ele} L' (int). For exactly two runs, also 'dsec' (B-A, sec).
    """
    conv = 3.28084 if feet else 1.0
    letters = _run_letters(len(splits_list))
    n = max((len(s) for s in splits_list), default=0)
    out = []
    for i in range(n):
        mi = next((s[i]["unit"] for s in splits_list if i < len(s)), None)
        row = {"mi": mi}
        for L, s in zip(letters, splits_list):
            sp = s[i] if i < len(s) else None
            pace = sp["pace_s"] / 60 if (sp and sp["pace_s"]) else None
            row[f"pace {L}"] = round(pace, 2) if pace else None
            row[f"HR {L}"] = round(sp["hr"]) if (sp and sp["hr"] is not None) else None
            row[f"+{ele} {L}"] = round(sp["gain_m"] * conv) if sp else None
        if len(splits_list) == 2:
            pa, pb = row.get("pace A"), row.get("pace B")
            row["dsec"] = round((pb - pa) * 60) if (pa and pb) else None
        out.append(row)
    return out


def write_chart_html(path, letters, names, rowdata, unit_label, feet):
    """Write a self-contained Chart.js page: pace overlay + HR overlay, one line per run."""
    import json
    ele = "ft" if feet else "m"
    miles = [r["mi"] for r in rowdata]
    pace = {L: [r.get(f"pace {L}") for r in rowdata] for L in letters}
    hr = {L: [r.get(f"HR {L}") for r in rowdata] for L in letters}
    palette = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#6250d6", "#008300", "#e34948"]
    legend = [{"L": L, "name": names[i], "color": palette[i % len(palette)],
               "dash": (i % 2 == 1)} for i, L in enumerate(letters)]

    def datasets(series):
        return [{"label": f"{L} \u00b7 {names[i]}", "data": series[L],
                 "borderColor": palette[i % len(palette)], "backgroundColor": palette[i % len(palette)],
                 "borderWidth": 2, "borderDash": ([6, 4] if i % 2 else []),
                 "tension": 0.25, "pointRadius": 2, "pointHoverRadius": 5, "spanGaps": False}
                for i, L in enumerate(letters)]

    data = {"miles": miles, "pace": datasets(pace), "hr": datasets(hr),
            "legend": legend, "unit": unit_label, "ele": ele}
    title = " vs ".join(names)
    html = _CHART_TEMPLATE.replace("__TITLE__", title).replace("__DATA__", json.dumps(data))
    with open(path, "w", encoding="utf-8") as f:
        f.write(html)
    return path


_CHART_TEMPLATE = """<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>__TITLE__</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
<style>
 body{font-family:-apple-system,Segoe UI,Roboto,sans-serif;max-width:900px;margin:2rem auto;padding:0 1rem;color:#1a1a19}
 h1{font-size:20px;font-weight:500}
 .legend{display:flex;flex-wrap:wrap;gap:16px;margin:.5rem 0 1.5rem;font-size:13px;color:#52514e}
 .legend span{display:flex;align-items:center;gap:6px}
 .swatch{width:16px;height:0;border-top-width:2px;border-top-style:solid}
 .panel{position:relative;height:320px;margin-bottom:2rem}
 h2{font-size:14px;font-weight:500;color:#52514e;margin:0 0 .25rem}
</style></head><body>
<h1>__TITLE__</h1>
<div class="legend" id="legend"></div>
<h2>pace per mile (higher = faster)</h2>
<div class="panel"><canvas id="pace" role="img" aria-label="Pace per mile for each run"></canvas></div>
<h2>heart rate</h2>
<div class="panel"><canvas id="hr" role="img" aria-label="Heart rate per mile for each run"></canvas></div>
<script>
const D = __DATA__;
const fmt = s => { const m=Math.floor(s), r=Math.round((s-m)*60); return m+':'+String(r).padStart(2,'0'); };
document.getElementById('legend').innerHTML = D.legend.map(l =>
  `<span><span class="swatch" style="border-top-style:${l.dash?'dashed':'solid'};border-top-color:${l.color}"></span>${l.L} · ${l.name}</span>`).join('');
new Chart(document.getElementById('pace'),{type:'line',
 data:{labels:D.miles,datasets:D.pace},
 options:{responsive:true,maintainAspectRatio:false,
  plugins:{legend:{display:false},tooltip:{callbacks:{
    title:i=>'Mile '+i[0].label,
    label:c=>c.dataset.label+': '+(c.parsed.y==null?'—':fmt(c.parsed.y)+'/'+D.unit)}}},
  scales:{y:{reverse:true,ticks:{callback:v=>fmt(v)},title:{display:true,text:'min/'+D.unit}},
          x:{title:{display:true,text:'mile'},ticks:{autoSkip:false}}}}});
new Chart(document.getElementById('hr'),{type:'line',
 data:{labels:D.miles,datasets:D.hr},
 options:{responsive:true,maintainAspectRatio:false,
  plugins:{legend:{display:false},tooltip:{callbacks:{title:i=>'Mile '+i[0].label}}},
  scales:{y:{title:{display:true,text:'bpm'}},x:{title:{display:true,text:'mile'},ticks:{autoSkip:false}}}}});
</script></body></html>
"""


def open_chart_file(letters, names, rowdata, unit_label, feet):
    """Write the comparison chart to a temp file and open it in the browser. Returns the path."""
    import tempfile, time, webbrowser
    fname = f"compare_{os.getpid()}_{int(time.time())}.html"
    path = os.path.join(tempfile.gettempdir(), fname)
    write_chart_html(path, letters, names, rowdata, unit_label, feet)
    webbrowser.open("file://" + path)
    return path


def run_visidata_picker(csv_path, unit_m, unit_label, feet, _run=True):
    from visidata import vd, Sheet, ItemColumn, run

    rows = load_activity_rows(csv_path)
    if not rows:
        sys.exit("No activities with a Filename found in activities.csv.")
    ele = "ft" if feet else "m"

    class ComparisonSheet(Sheet):
        rowtype = "miles"

        def iterload(self):
            self.columns = []
            self.addColumn(ItemColumn("mi", "mi", type=int))
            for L in self.letters:
                self.addColumn(ItemColumn(f"{L} {unit_label}", f"pace {L}", type=float))
            if len(self.letters) == 2:
                self.addColumn(ItemColumn("dsec", "dsec", type=int))
            for L in self.letters:
                self.addColumn(ItemColumn(f"HR {L}", f"HR {L}", type=int))
            for L in self.letters:
                self.addColumn(ItemColumn(f"+{ele} {L}", f"+{ele} {L}", type=int))
            self.setKeys([self.column("mi")])
            yield from self.rowdata

        @Sheet.api
        def open_chart(sheet):
            path = open_chart_file(sheet.letters, sheet.run_names, sheet.rowdata, unit_label, feet)
            vd.status(f"chart \u2192 {path}")

    ComparisonSheet.addCommand("z.", "open-chart", "sheet.open_chart()",
                               "render this comparison as an HTML chart and open in a browser")

    class ActivitiesSheet(Sheet):
        rowtype = "activities"
        columns = [
            ItemColumn("run", "name"),
            ItemColumn("date", "date"),
            ItemColumn("type", "type"),
            ItemColumn("mi", "dist", type=float),
        ]

        def iterload(self):
            yield from rows

        @Sheet.api
        def compare_selected(sheet):
            sel = list(sheet.selectedRows)
            if not sel:
                vd.fail("select one or more runs (press s on each), then Enter")
            if len(sel) > 8:
                vd.fail(f"{len(sel)} selected; compare at most 8 runs at once")
            for r in sel:
                if not os.path.exists(r["path"]):
                    vd.fail(f"file not found: {r['path']}")
            letters = _run_letters(len(sel))
            names = [f"{r['name']} ({r['date']})" for r in sel]
            legend = "\n".join(f"{L} = {n}" for L, n in zip(letters, names))
            vd.status(legend)
            splits = [compute_splits(read_activity(r["path"]), unit_m) for r in sel]
            rowdata = comparison_rows(splits, feet, ele)
            title = " vs ".join(r["name"] for r in sel)
            vd.push(ComparisonSheet(title[:60], letters=letters, run_names=names,
                                    rowdata=rowdata, legend=legend))

    ActivitiesSheet.addCommand("Enter", "compare-runs", "sheet.compare_selected()",
                               "compare the selected runs (1 to 8)")

    sheet = ActivitiesSheet(os.path.basename(os.path.dirname(csv_path)) or "activities")
    if not _run:
        return sheet, ActivitiesSheet, ComparisonSheet
    vd.status("Select runs with s (any number, 1-8), then press Enter to compare.")
    run(sheet)


def main():
    ap = argparse.ArgumentParser(description="Mile-by-mile comparison of two activities.")
    ap.add_argument("activity_a", nargs="?", help="First activity file (omit to pick interactively)")
    ap.add_argument("activity_b", nargs="?", help="Second activity file")
    ap.add_argument("-i", "--interactive", action="store_true",
                    help="Browse activities.csv and choose two (simple numbered menu)")
    ap.add_argument("--vd", action="store_true",
                    help="Browse activities.csv in VisiData; select two rows, press Enter to compare")
    ap.add_argument("--export", default=None, help="Path to the unzipped Strava export folder")
    ap.add_argument("--label-a", default=None)
    ap.add_argument("--label-b", default=None)
    ap.add_argument("--km", action="store_true", help="Split by kilometer instead of mile")
    ap.add_argument("--feet", action="store_true", help="Report elevation in feet")
    ap.add_argument("--csv", default=None, help="Also write the comparison to a CSV file")
    ap.add_argument("--chart", action="store_true",
                    help="Also render an HTML pace/HR chart to a temp file and open it in a browser")
    ap.add_argument("--activities-csv", default=None,
                    help="Path to the export's activities.csv (auto-detected if omitted)")
    args = ap.parse_args()

    if args.vd:
        anchor = args.activity_a if (args.activity_a and os.path.isdir(args.activity_a)) else os.getcwd()
        csv_path = locate_csv(args.activities_csv, args.export, anchor)
        if not csv_path:
            ap.error("Could not find activities.csv. Pass --export DIR or --activities-csv PATH.")
        unit_m = METERS_PER_KM if args.km else METERS_PER_MILE
        unit_label = "km" if args.km else "mi"
        run_visidata_picker(csv_path, unit_m, unit_label, args.feet)
        return

    interactive = args.interactive or not (args.activity_a and args.activity_b)

    if interactive:
        anchor = args.activity_a if (args.activity_a and os.path.isdir(args.activity_a)) else os.getcwd()
        csv_path = locate_csv(args.activities_csv, args.export, anchor)
        if not csv_path:
            ap.error("Could not find activities.csv. Pass --export DIR or --activities-csv PATH.")
        rows = load_activity_rows(csv_path)
        a_row, b_row = interactive_pick(rows)
        path_a, path_b = a_row["path"], b_row["path"]
        la = args.label_a or _label(a_row)
        lb = args.label_b or _label(b_row)
        for p in (path_a, path_b):
            if not os.path.exists(p):
                ap.error(f"Activity file not found: {p}")
        print(f"\nComparing:\n  A  {la}\n  B  {lb}")
    else:
        path_a, path_b = args.activity_a, args.activity_b
        la = resolve_label(path_a, args.label_a, args.activities_csv)
        lb = resolve_label(path_b, args.label_b, args.activities_csv)

    unit_m = METERS_PER_KM if args.km else METERS_PER_MILE
    unit_label = "km" if args.km else "mi"

    sa = compute_splits(read_activity(path_a), unit_m)
    sb = compute_splits(read_activity(path_b), unit_m)

    print_comparison(sa, sb, la, lb, unit_label, args.feet)
    if args.csv:
        write_csv(sa, sb, la, lb, unit_label, args.csv)
    if args.chart:
        ele = "ft" if args.feet else "m"
        rowdata = comparison_rows([sa, sb], args.feet, ele)
        path = open_chart_file(["A", "B"], [la, lb], rowdata, unit_label, args.feet)
        print(f"\nchart \u2192 {path}")


if __name__ == "__main__":
    main()
