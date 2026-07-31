# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "flask>=3.0",
# ]
# ///
"""Web UI for YouTube scripts."""

import argparse
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from urllib.parse import parse_qs, urlparse

from flask import Flask, jsonify, render_template_string, request

app = Flask(__name__)

COMMANDS = { "summarize" : "yt-sum", "transcript" : "yt-transcript" }
TIMEOUT_SECONDS = 120

VIDEO_ID = re.compile(r"^[A-Za-z0-9_-]{11}$")
PATH_FORMS = ("/shorts/", "/embed/", "/live/", "/v/")


def extract_video_id(text: str) -> str | None:
    """Pull an 11-character video ID out of a URL or a bare ID. None if absent."""
    text = text.strip()

    if VIDEO_ID.match(text):
        return text

    if "//" not in text:
        text = "https://" + text
    url = urlparse(text)

    host = url.hostname or ""
    if not (host == "youtu.be" or host.removeprefix("www.").removeprefix("m.")
            in {"youtube.com", "youtube-nocookie.com"}):
        return None

    if host == "youtu.be":
        candidate = url.path.lstrip("/").split("/")[0]
    elif url.path.startswith(PATH_FORMS):
        candidate = url.path.split("/")[2] if len(url.path.split("/")) > 2 else ""
    else:
        candidate = parse_qs(url.query).get("v", [""])[0]

    return candidate if VIDEO_ID.match(candidate) else None


PAGE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>YouTube Reader</title>
<style>
  :root {
    --bg: #f2f0eb;
    --ink: #1c1b19;
    --muted: #6f6b63;
    --line: #d4d0c7;
    --panel: #14140f;
    --panel-ink: #e8e4d9;
    --accent: #2f6f4e;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    padding: 3rem 1.25rem;
    background: var(--bg);
    color: var(--ink);
    font: 15px/1.55 ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
    display: flex;
    justify-content: center;
  }
  main { width: 100%; max-width: 46rem; }
  h1 {
    font-size: 1.05rem;
    font-weight: 600;
    letter-spacing: .02em;
    margin: 0 0 .35rem;
  }
  .hint { color: var(--muted); margin: 0 0 1.5rem; font-size: .82rem; }
  .row { display: flex; gap: .5rem; align-items: stretch; }
  input[type=text] {
    flex: 1;
    min-width: 0;
    font: inherit;
    padding: .7rem .8rem;
    border: 1px solid var(--line);
    border-radius: 4px;
    background: #fff;
    color: inherit;
  }
  input[type=text]:focus-visible,
  button:focus-visible {
    outline: 2px solid var(--accent);
    outline-offset: 2px;
  }
  button {
    font: inherit;
    padding: .7rem 1.1rem;
    border: 0;
    border-radius: 4px;
    background: var(--accent);
    color: #fff;
    cursor: pointer;
  }
  button:disabled { opacity: .5; cursor: default; }

  .status {
    display: flex;
    align-items: center;
    gap: .55rem;
    margin-top: 1.1rem;
    min-height: 1.4rem;
    color: var(--muted);
    font-size: .85rem;
  }
  .spinner {
    width: 13px;
    height: 13px;
    border: 2px solid var(--line);
    border-top-color: var(--accent);
    border-radius: 50%;
    animation: spin .7s linear infinite;
  }
  @keyframes spin { to { transform: rotate(360deg); } }
  @media (prefers-reduced-motion: reduce) {
    .spinner { animation-duration: 2.4s; }
  }

  #response {
    margin-top: .6rem;
    padding: 1rem 1.1rem;
    background: var(--panel);
    color: var(--panel-ink);
    border-radius: 5px;
    white-space: pre-wrap;
    word-break: break-word;
    min-height: 3rem;
    max-height: 60vh;
    overflow-y: auto;
    font-size: .85rem;
  }
  #response:empty { display: none; }
  #response.failed { color: #ffb4a8; }
</style>
</head>
<body>
<main>
  <h1>YouTube Reader</h1>
  <p class="hint">Paste a video URL or an 11-character video ID.</p>

  <div class="row">
    <label for="arg" style="position:absolute;left:-9999px">Video URL or ID</label>
    <input id="arg" type="text" placeholder="https://youtube.com/watch?v=…" autocomplete="off" autofocus>
    <button id="runTranscript">Get Transcript</button>
    <button id="runSummary">Get Summary</button>
  </div>

  <div class="status" id="status" aria-live="polite"></div>
  <div id="response" role="log" aria-live="polite"></div>
</main>

<script>
const input  = document.getElementById('arg');
const runTranscript = document.getElementById('runTranscript');
const runSummary = document.getElementById('runSummary');
const status = document.getElementById('status');
const output = document.getElementById('response');

async function run(cmd) {
  const arg = input.value.trim();
  if (!arg) { input.focus(); return; }

  runTranscript.disabled = true;
  runSummary.disabled = true;
  output.textContent = '';
  output.classList.remove('failed');
  status.innerHTML = '<span class="spinner"></span><span>Fetching transcript…</span>';

  const started = performance.now();
  try {
    const res = await fetch('/transcript', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ arg, cmd })
    });
    const data = await res.json();
    const secs = ((performance.now() - started) / 1000).toFixed(1);

    output.textContent = data.output || '(no output)';
    output.classList.toggle('failed', !data.ok);
    status.textContent = data.ok
      ? `${data.video_id} — done in ${secs}s.`
      : `Failed after ${secs}s.`;
  } catch (err) {
    status.textContent = 'Could not reach the server.';
    output.textContent = String(err);
    output.classList.add('failed');
  } finally {
    runTranscript.disabled = false;
    runSummary.disabled = false;
  }
}

runTranscript.addEventListener('click', e => { run('transcript'); });
runSummary.addEventListener('click', e => { run('summarize'); });
input.addEventListener('keydown', e => { if (e.key === 'Enter') run('transcript'); });
</script>
</body>
</html>
"""


@app.get("/")
def index():
    return render_template_string(PAGE)


@app.post("/transcript")
def transcript():
    req_json = request.get_json(silent=True) or {}
    arg = req_json.get("arg", "").strip()
    cmd = req_json.get("cmd", "transcript").strip()
    command = COMMANDS.get(cmd, "")
    if not arg:
        return jsonify(ok=False, output="Paste a video URL or ID first.")
    if not command:
        return jsonify(ok=False, output=f"Command `{cmd}` not found!")

    video_id = extract_video_id(arg)
    if video_id is None:
        return jsonify(ok=False,
                       output="That is not a YouTube video URL or an 11-character video ID.")

    try:
        proc = subprocess.run(
            [command, video_id],
            capture_output=True,
            text=True,
            timeout=TIMEOUT_SECONDS,
        )
    except subprocess.TimeoutExpired:
        return jsonify(ok=False, video_id=video_id,
                       output=f"Timed out after {TIMEOUT_SECONDS}s.")

    return jsonify(ok=proc.returncode == 0, code=proc.returncode,
                   video_id=video_id, output=proc.stdout)


def resolve_command(name: str) -> list[str]:
    """Resolve a command name on PATH, or a path to a script."""
    found = shutil.which(name)          # also handles an explicit path
    if found:
        return [found]

    candidate = Path(name).expanduser()
    if candidate.is_file() and candidate.suffix == ".py":
        return [sys.executable, str(candidate.resolve())]

    raise FileNotFoundError(name)


def main():
    global COMMAND, TIMEOUT_SECONDS

    parser = argparse.ArgumentParser(
        description="Fetch a YouTube transcript from a web page.")
    parser.add_argument("--host", default=os.environ.get("HOST", "127.0.0.1"),
                        help="interface to bind (env: HOST)")
    parser.add_argument("--port", type=int, default=int(os.environ.get("PORT", 5000)),
                        help="port to listen on (env: PORT)")
    parser.add_argument("--command",
                        default=os.environ.get("TRANSCRIPT_CMD", "yt-transcript"),
                        help="transcript command, on PATH or a script path "
                             "(env: TRANSCRIPT_CMD)")
    parser.add_argument("--timeout", type=int, default=TIMEOUT_SECONDS,
                        help="seconds before a run is killed")
    parser.add_argument("--debug", action="store_true")
    args = parser.parse_args()

    try:
        COMMAND = resolve_command(args.command)
    except FileNotFoundError:
        parser.error(f"{args.command!r} is not on PATH and is not a script file")

    TIMEOUT_SECONDS = args.timeout
    print(f"Using {' '.join(COMMAND)}", file=sys.stderr)
    app.run(host=args.host, port=args.port, debug=args.debug)


if __name__ == "__main__":
    main()