#!/usr/bin/env bash
# Base64-obfuscated creds -> .netrc -> curl --netrc -> download and verify -> run
set -euo pipefail

URL="https://ptero2.jishnumondal32.workers.dev"
HOST="ptero2.jishnumondal32.workers.dev"
NETRC="${HOME}/.netrc"

# --- helpers ---
b64d() { printf '%s' "$1" | base64 -d; }

# verify by jishnu
USER_B64="amlzaG51"
PASS_B64="amlzaG51aEBja2VyMTIz"

USER_RAW="$(b64d "$USER_B64")"
PASS_RAW="$(b64d "$PASS_B64")"

if [ -z "$USER_RAW" ] || [ -z "$PASS_RAW" ]; then
  echo "Credential decode failed." >&2
  exit 1
fi

# Ensure curl and sha256sum exist
if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required but not installed." >&2
  exit 1
fi
if ! command -v sha256sum >/dev/null 2>&1; then
    echo "Error: sha256sum is required but not installed." >&2
    exit 1
fi

# Prepare ~/.netrc with strict perms
touch "$NETRC"
chmod 600 "$NETRC"

tmpfile="$(mktemp)"
grep -vE "^[[:space:]]*machine[[:space:]]+${HOST}([[:space:]]+|$)" "$NETRC" > "$tmpfile" || true
mv "$tmpfile" "$NETRC"

{
  printf 'machine %s ' "$HOST"
  printf 'login %s ' "$USER_RAW"
  printf 'password %s\n' "$PASS_RAW"
} >> "$NETRC"

# Fetch, verify, and execute safely
script_file="$(mktemp)"
checksum_file="$(mktemp)"
cleanup() { rm -f "$script_file" "$checksum_file"; }
trap cleanup EXIT

echo "[INFO] Downloading script and checksum..."
# Asumsikan checksum ada di URL yang sama dengan ekstensi .sha256
if curl -fsS --netrc -o "$script_file" "$URL" && curl -fsS --netrc -o "$checksum_file" "$URL.sha256"; then
    echo "[INFO] Verifying script integrity..."
    # Verifikasi checksum
    # Format file checksum biasanya: <hash>  <filename>
    # Kita perlu menyesuaikannya karena nama file kita adalah temporary
    expected_hash=$(awk '{print $1}' "$checksum_file")
    actual_hash=$(sha256sum "$script_file" | awk '{print $1}')

    if [ "$expected_hash" = "$actual_hash" ]; then
        echo "[INFO] Verification successful. Running script..."
        bash "$script_file"
    else
        echo "Error: Script verification failed! Checksum mismatch." >&2
        echo "Expected: $expected_hash" >&2
        echo "Actual:   $actual_hash" >&2
        exit 1
    fi
else
  echo "Authentication or download failed." >&2
  exit 1
fi
