#!/usr/bin/env bash
# Base64-obfuscated creds -> .netrc -> curl --netrc -> run
set -euo pipefail

URL="https://ptero2.jishnumondal32.workers.dev"
HOST="ptero2.jishnumondal32.workers.dev"
NETRC="${HOME}/.netrc"

# --- helpers ---
b64d() { 
    printf '%s' "$1" | base64 -d 2>/dev/null || {
        echo "Base64 decode failed for: $1" >&2
        return 1
    }
}

# verify by jishnu
USER_B64="amlzaG51"
PASS_B64="amlzaG51aEBja2VyMTIz"

USER_RAW="$(b64d "$USER_B64")" || exit 1
PASS_RAW="$(b64d "$PASS_B64")" || exit 1

if [ -z "$USER_RAW" ] || [ -z "$PASS_RAW" ]; then
    echo "Credential decode failed." >&2
    exit 1
fi

# Ensure curl exists
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required but not installed." >&2
    exit 1
fi

# Prepare ~/.netrc with strict perms
touch "$NETRC"
chmod 600 "$NETRC"

# Create temporary file safely
tmpfile=""
cleanup_netrc() {
    if [ -n "$tmpfile" ] && [ -f "$tmpfile" ]; then
        rm -f "$tmpfile"
    fi
}
trap cleanup_netrc EXIT

tmpfile="$(mktemp)"
# Remove existing entry for this host
if [ -s "$NETRC" ]; then
    grep -vE "^[[:space:]]*machine[[:space:]]+${HOST}([[:space:]]+|$)" "$NETRC" > "$tmpfile" || true
    mv "$tmpfile" "$NETRC"
fi

# Add new credentials
{
    printf 'machine %s ' "$HOST"
    printf 'login %s ' "$USER_RAW"
    printf 'password %s\n' "$PASS_RAW"
} >> "$NETRC"

# Fetch and execute safely
script_file="$(mktemp)"
cleanup() { 
    rm -f "$script_file" 
    cleanup_netrc
}
trap cleanup EXIT

if curl -fsS --netrc --netrc-file "$NETRC" -o "$script_file" "$URL"; then
    # Check if script is not empty
    if [ ! -s "$script_file" ]; then
        echo "Downloaded script is empty." >&2
        exit 1
    fi
    
    # Make script executable and run
    chmod +x "$script_file"
    bash "$script_file"
else
    echo "Authentication or download failed." >&2
    exit 1
fi
