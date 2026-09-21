#!/usr/bin/env python3
"""PreToolUse gate: block tool arguments that carry a live secret value.

Value-based, not entropy-based: reads the secrets files at hook time and blocks
when any actual value appears in the tool's arguments, plus a short list of
unmistakable literal token shapes (ghp_, sk-, AKIA, private-key headers).
Exit 0 = allow. Exit 2 = block; stderr names the variable, never its value.
Fails open on anything it cannot parse.

Adapted from https://git.naps.pt/yolo/agent-skills (hooks/secret-guard.py).
"""
import json
import os
import re
import sys

# Colon-separated. Shell `export X=v` and TOML `x = "v"` lines both parse. A
# git-crypt file still locked on this machine matches no line and guards
# nothing, same as an absent file.
DOTFILES = os.environ.get("DOTFILES") or os.path.expanduser("~/.dotfiles")
ENV_FILES = (os.environ.get("SECRET_GUARD_ENV") or ":".join([
    os.path.join(DOTFILES, "system", "secret.env.sh"),
    os.path.join(DOTFILES, ".wrangler", "config", "default.toml"),
])).split(":")
# Values under this are unguardable by matching: even as standalone
# tokens they collide with ordinary prose and code (a 4-char password
# blocked two unrelated calls in live testing). Rotate any real secret
# this short to a longer one instead; then it is covered automatically.
MIN_LEN = 6

# Exact names whose values are identity, location or tool config, not
# credentials. Extend deliberately, one name at a time — never by shape.
ALLOW_NAMES = {"PATH", "GPG_TTY", "expiration_time", "scopes"}

# Deliberately public: the standard dev-chain test mnemonic.
ALLOWLIST = {
    "test test test test test test test test test test test junk",
}


def plain_url(val):
    # Only a bare origin is an address, not a credential. Userinfo, any
    # path segment, query or fragment can all carry one, so they stay
    # secret; endpoint vars with real paths go in ALLOW_NAMES instead.
    m = re.match(r"https?://([^/?#@]+)(/?)$", val)
    return bool(m)

TOKEN_SHAPES = [
    ("a GitHub token", re.compile(r"\bgh[pousr]_[A-Za-z0-9]{20,}")),
    ("a GitHub fine-grained token", re.compile(r"\bgithub_pat_[A-Za-z0-9_]{20,}")),
    ("an sk- API key", re.compile(r"\bsk-[A-Za-z0-9_-]{20,}")),
    ("an AWS access key id", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
    ("a Slack token", re.compile(r"\bxox[bpoas]-[A-Za-z0-9-]{10,}")),
    ("a private key block",
     re.compile(r"-----BEGIN (OPENSSH|RSA|EC|DSA|PGP|ENCRYPTED)? ?PRIVATE KEY")),
]

LINE = re.compile(r"^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$")


def env_secrets():
    out, unguardable = {}, []
    lines = []
    for path in ENV_FILES:
        try:
            with open(path, errors="replace") as f:
                lines += f.readlines()
        except OSError:
            continue
    for line in lines:
        m = LINE.match(line)
        if not m:
            continue
        name, val = m.group(1), m.group(2).strip()
        if len(val) >= 2 and val[0] == val[-1] and val[0] in "\"'":
            val = val[1:-1]
        if name in ALLOW_NAMES:
            continue
        # Both forms are classified independently: the inherited value can
        # be stale after a rotation and the file value fresh (or vice
        # versa), and guarding old and new together is safe. A literal
        # that is nothing but a $-reference matches the referencing style
        # itself, so only its inherited form counts.
        forms = [os.environ[name]] if name in os.environ else []
        if not re.fullmatch(r"\$\{?[A-Za-z_][A-Za-z0-9_]*\}?", val):
            forms.append(val)
        for v in forms:
            if (len(v) >= MIN_LEN and v not in ALLOWLIST
                    and not plain_url(v) and not v.startswith(("/", "~"))):
                out.setdefault(name, []).append(v)
            elif 0 < len(v) < MIN_LEN and name not in unguardable:
                unguardable.append(name)
    return out, unguardable


def warn_unguardable(names):
    marker = os.path.expanduser("~/.cache/secret-guard-warned")
    try:
        import time
        if os.path.exists(marker) and time.time() - os.path.getmtime(marker) < 86400:
            return
        os.makedirs(os.path.dirname(marker), exist_ok=True)
        open(marker, "w").close()
    except OSError:
        return
    print(
        f"secret-guard warning (daily): {', '.join('$' + n for n in names)} "
        f"shorter than {MIN_LEN} chars — too short to guard by value matching, "
        f"so it can leak undetected. Rotate it to a longer value.",
        file=sys.stderr,
    )
    sys.exit(1)


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    text = json.dumps(payload.get("tool_input") or {})

    def hit(v):
        # Short values collide as substrings of ordinary text (a 4-char
        # password blocked an unrelated command in testing), so they only
        # match as standalone tokens; long values match anywhere.
        for form in {v, json.dumps(v)[1:-1]}:
            if len(v) >= 8:
                if form in text:
                    return True
            elif re.search(
                    r"(?<![A-Za-z0-9])" + re.escape(form) + r"(?![A-Za-z0-9])",
                    text):
                return True
        return False

    secrets, unguardable = env_secrets()
    for name, vals in secrets.items():
        if any(hit(v) for v in vals):
            print(
                f"Blocked: the argument contains the value of ${name} from a "
                f"secrets file. Reference the variable (\"${name}\") instead "
                f"of its value.",
                file=sys.stderr,
            )
            sys.exit(2)

    for label, pat in TOKEN_SHAPES:
        m = pat.search(text)
        if m and m.group(0) not in ALLOWLIST:
            print(
                f"Blocked: the argument contains what looks like {label}. "
                f"Never write live credentials into commands or files; "
                f"reference an env var or a mounted file instead.",
                file=sys.stderr,
            )
            sys.exit(2)

    if unguardable:
        warn_unguardable(unguardable)
    sys.exit(0)


if __name__ == "__main__":
    main()
