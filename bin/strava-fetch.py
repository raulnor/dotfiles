#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "requests",
# ]
# ///
"""
Fetch a Strava activity page using a browser-derived session cookie.

First run prompts for the cookie and stores it. After that:
    ./strava-fetch.py 19829159133

When the session expires, re-run with --login to paste a fresh one.
"""

import re
import os
import sys
from http.cookiejar import Cookie, MozillaCookieJar
from pathlib import Path

import requests

# Cookies Strava actually authenticates with. Everything else in the header is
# analytics (GA, TikTok, Snowplow, Reddit) or consent state.
ESSENTIAL = {"_strava4_session", "strava_remember_id", "strava_remember_token"}

# Keep the full cookie set rather than filtering down to ESSENTIAL. Costs
# nothing but disk, and covers the case where the backend wants something we
# didn't classify as essential.
KEEP_ALL = True

INSTRUCTIONS = """\
Paste your Strava cookie header.

  1. Open https://www.strava.com/dashboard in Chrome, logged in.
  2. Open DevTools (Option-Command-I) and select the Network tab.
  3. Reload the page. Click the first request in the list ("dashboard").
  4. Under Headers > Request Headers, find the "cookie" row.
  5. Copy the whole value starting with "CookieConsent=".

Paste it at the prompt and press return.
"""

HEADERS = {
    "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,"
              "image/avif,image/webp,image/apng,*/*;q=0.8",
    "accept-language": "en-US,en;q=0.9",
    "referer": "https://www.strava.com/dashboard",
    "sec-ch-ua": '"Not=A?Brand";v="99", "Google Chrome";v="151", "Chromium";v="151"',
    "sec-ch-ua-mobile": "?0",
    "sec-ch-ua-platform": '"macOS"',
    "sec-fetch-dest": "document",
    "sec-fetch-mode": "navigate",
    "sec-fetch-site": "same-origin",
    "sec-fetch-user": "?1",
    "upgrade-insecure-requests": "1",
    "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                  "AppleWebKit/537.36 (KHTML, like Gecko) "
                  "Chrome/151.0.0.0 Safari/537.36",
}


def local_dir() -> Path:
    """Get location of saved cookie."""
    dir = "strava-fetch"
    if xdg := os.environ.get("XDG_STATE_HOME"):
        return Path(xdg) / dir
    if sys.platform == "darwin":
        return Path.home() / "Library" / "Application Support" / dir
    if sys.platform == "win32":
        return Path(os.environ.get("LOCALAPPDATA", Path.home())) / dir
    return Path.home() / ".local" / "state" / dir


def jar_path() -> Path:
    d = local_dir()
    d.mkdir(parents=True, exist_ok=True)
    d.chmod(0o700)
    return d / "cookies.txt"


def clean_paste(raw: str) -> str:
    """Tolerate what actually lands on the clipboard."""
    raw = raw.strip()
    # Terminals with bracketed paste can leak the wrapper into the buffer.
    raw = raw.replace("\x1b[200~", "").replace("\x1b[201~", "")
    # If they grabbed a curl fragment, pull the cookie out of it.
    m = re.search(r"(?:-b|--cookie)\s+(['\"])(.+?)\1", raw, re.S)
    if m:
        raw = m.group(2)
    # Or the DevTools row, which includes the header name.
    if raw.lower().startswith("cookie:"):
        raw = raw.split(":", 1)[1]
    return raw.strip()


def parse_cookie_header(header: str) -> dict:
    """Split a raw `Cookie:` header value into name -> value."""
    out = {}
    for part in header.split(";"):
        part = part.strip()
        if not part or "=" not in part:
            continue
        name, _, value = part.partition("=")  # values contain '=' (base64 padding)
        name = name.strip()
        if name and (KEEP_ALL or name in ESSENTIAL):
            out[name] = value.strip()
    return out


def prompt_for_cookie() -> dict:
    if not sys.stdin.isatty():
        # Piped in, e.g. `pbpaste | ./strava-fetch.py --login 123`.
        raw = sys.stdin.read()
    else:
        # Importing readline puts the tty in raw mode, which lifts the 1024-byte
        # canonical-input limit. Without it the paste is silently truncated.
        try:
            import readline  # noqa: F401
        except ImportError:
            pass
        print(INSTRUCTIONS, file=sys.stderr)
        try:
            raw = input("cookie> ")
        except (EOFError, KeyboardInterrupt):
            sys.exit("\nAborted.")

    cookies = parse_cookie_header(clean_paste(raw))
    missing = ESSENTIAL - cookies.keys()
    if missing:
        sys.exit(f"That paste is missing: {', '.join(sorted(missing))}. "
                 "Make sure you copied the entire value.")
    return cookies


def make_cookie(name: str, value: str) -> Cookie:
    return Cookie(
        version=0, name=name, value=value,
        port=None, port_specified=False,
        domain=".strava.com", domain_specified=True, domain_initial_dot=True,
        path="/", path_specified=True,
        secure=True, expires=None, discard=False,
        comment=None, comment_url=None, rest={}, rfc2109=False,
    )


def make_session(force_login: bool = False) -> requests.Session:
    path = jar_path()
    jar = MozillaCookieJar(str(path))
    if path.exists() and not force_login:
        jar.load(ignore_discard=True, ignore_expires=True)

    if force_login or not any(c.name in ESSENTIAL for c in jar):
        for name, value in prompt_for_cookie().items():
            jar.set_cookie(make_cookie(name, value))

    s = requests.Session()
    s.cookies = jar
    s.headers.update(HEADERS)
    return s


def save(session: requests.Session) -> None:
    path = jar_path()
    session.cookies.save(ignore_discard=True, ignore_expires=True)
    path.chmod(0o600)


def fetch(session: requests.Session, activity_id: str) -> str:
    url = f"https://www.strava.com/activities/{activity_id}"
    r = session.get(url, timeout=30)
    r.raise_for_status()

    # Strava serves the login page with a 200, so a dead session looks like
    # success unless you check for it.
    if "/login" in r.url or "session[email]" in r.text:
        sys.exit("Session expired. Re-run with --login to paste a fresh cookie.")

    save(session)
    return r.text


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--login"]
    force = "--login" in sys.argv[1:]
    if not args:
        sys.exit("Usage: strava-fetch.py [--login] <activity_id_or_url>")
    ident = args[0].rstrip("/").rsplit("/", 1)[-1]
    print(fetch(make_session(force), ident))