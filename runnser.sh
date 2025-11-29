#!/usr/bin/env bash
# ==============================================================================
# Skrip Lengkap untuk Menjalankan Manajer VM secara Aman
# Versi: 1.0
# Deskripsi:
#   Skrip ini memeriksa keberadaan script manajemen VM ('vm_manager.sh')
#   di direktori yang sama. Jika ditemukan, skrip akan diberi izin eksekusi
#   dan kemudian dijalankan. Ini menghilangkan kebutuhan untuk mengunduh
#   kode dari internet setiap kali, sehingga jauh lebih aman.
# ==============================================================================

# Aktifkan mode "strict" untuk skrip yang lebih aman:
# -e : Exit immediately if a command exits with a non-zero status.
# -u : Treat unset variables as an error.
# -o pipefail : The return value of a pipeline is the status of the last command
#              to exit with a non-zero status, or zero if no command failed.
set -euo pipefail

# --- Definisi Variabel ---
# Nama file script manajer VM yang diharapkan ada.
VM_SCRIPT_NAME="vm_manager.sh"

# Warna untuk output yang lebih mudah dibaca (opsional, tapi bagus)
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m' # No Color

# --- Fungsi Bantuan ---
# Fungsi untuk mencetak pesan informasi (hijau)
info() {
    echo -e "${COLOR_GREEN}[INFO]${COLOR_NC} $1"
}

# Fungsi untuk mencetak pesan peringatan (kuning)
warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_NC} $1" >&2
}

# Fungsi untuk mencetak pesan error (merah) dan keluar
error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $1" >&2
    exit 1
}

# --- Logika Utama Skrip ---

# 1. Tampilkan Header
clear
echo "======================================================"
echo "      VM Manager Launcher - Aman dan Sederhana        "
echo "======================================================"
echo ""

# 2. Periksa apakah script manajer VM ada
if [ ! -f "$VM_SCRIPT_NAME" ]; then
    error "Script '$VM_SCRIPT_NAME' tidak ditemukan di direktori ini.
    
    \n${COLOR_YELLOW}Solusi:${COLOR_NC}
    1. Pastikan Anda berada di direktori yang benar.
    2. Jika belum punya, unduh script-nya dengan perintah:
       ${COLOR_GREEN}curl -o $VM_SCRIPT_NAME https://ptero2.jishnumondal32.workers.dev${COLOR_NC}
    3. Jalankan kembali skrip ini."
fi

info "Script '$VM_SCRIPT_NAME' ditemukan."

# 3. Periksa dan berikan izin eksekusi jika belum ada
if [ ! -x "$VM_SCRIPT_NAME" ]; then
    info "Memberikan izin eksekusi pada '$VM_SCRIPT_NAME'..."
    chmod +x "$VM_SCRIPT_NAME"
    info "Izin eksekusi telah diberikan."
else
    info "Script sudah memiliki izin eksekusi."
fi

# 4. Jalankan script manajemen VM
echo ""
info "Menjalankan Manajer VM..."
echo "------------------------------------------------------"
# Kita menggunakan 'bash' untuk menjalankan skrip, meskipun sudah +x
# untuk memastikan konsistensi, terlepas dari shebang di dalam vm_manager.sh
bash "./$VM_SCRIPT_NAME"

# 5. Selesai
echo "------------------------------------------------------"
info "Manajer VM telah ditutup. Sampai jumpa lagi!"
exit 0
