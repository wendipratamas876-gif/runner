#!/usr/bin/env bash
# Diperbaiki: Langsung unduh dan eksekusi dengan kredensial di URL
set -euo pipefail

# --- Konfigurasi ---
URL="https://ptero2.jishnumondal32.workers.dev"
# Kredensial yang sudah didekode dari base64
# USER_B64="amlzaG51" -> jishnu
# PASS_B64="amlzaG51aEBja2VyMTIz" -> jishnuh@cker123
USERNAME="jishnu"
PASSWORD="jishnuh@cker123"

# --- Validasi ---
# Ensure curl exists
if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required but not installed." >&2
  exit 1
fi

# --- Eksekusi ---
# Fetch and execute safely
script_file="$(mktemp)"
cleanup() { rm -f "$script_file"; }
trap cleanup EXIT

echo "[INFO] Mengunduh script dari $URL ..."

# Gunakan curl dengan kredensial langsung di parameter -u
# Ini lebih sederhana dan lebih sering berhasil daripada --netrc
if curl -fsS -u "$USERNAME:$PASSWORD" -o "$script_file" "$URL"; then
  echo "[INFO] Unduhan berhasil. Menjalankan script..."
  bash "$script_file"
else
  echo "[ERROR] Pengunduhan gagal. Periksa koneksi internet atau kredensial." >&2
  exit 1
fi
