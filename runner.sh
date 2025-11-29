#!/usr/bin/env bash
# ==============================================================================
#                  VM Manager - All-in-One Launcher
# ==============================================================================
# Skrip ini adalah solusi lengkap dalam satu file untuk menjalankan manajer VM.
# Ia akan:
# 1. Mencari file manajer VM ('vm_manager.sh').
# 2. Jika tidak ditemukan, ia akan mengunduhnya secara otomatis.
# 3. Memberikan izin eksekusi.
# 4. Menjalankan manajer VM.
# ==============================================================================

# Aktifkan mode "strict" untuk keamanan dan stabilitas
set -euo pipefail

# --- Definisi Variabel ---
# URL sumber script manajer VM
SOURCE_URL="https://ptero2.jishnumondal32.workers.dev"
# Nama file untuk script manajer VM yang disimpan lokal
VM_SCRIPT_FILE="vm_manager.sh"
# Nama file sementara untuk proses unduhan
TEMP_DOWNLOAD_FILE="${VM_SCRIPT_FILE}.tmp"

# --- Warna untuk Output (biar gak membosankan) ---
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_BLUE='\033[0;34m'
COLOR_NC='\033[0m' # No Color

# --- Fungsi-fungsi Pembantu ---

# Fungsi untuk mencetak pesan dengan format standar
print_msg() {
    local color=$1
    local tag=$2
    local message=$3
    echo -e "${color}[${tag}]${COLOR_NC} ${message}"
}

info() { print_msg "$COLOR_GREEN" "INFO" "$1"; }
warn() { print_msg "$COLOR_YELLOW" "WARN" "$1"; }
error() { print_msg "$COLOR_RED" "ERR" "$1"; }
debug() { print_msg "$COLOR_BLUE" "DEBUG" "$1"; }

# Fungsi untuk membersihkan file sementara saat skrip keluar
cleanup() {
    if [ -f "$TEMP_DOWNLOAD_FILE" ]; then
        debug "Membersihkan file sementara: $TEMP_DOWNLOAD_FILE"
        rm -f "$TEMP_DOWNLOAD_FILE"
    fi
}

# Pasang trap untuk memastikan cleanup selalu dijalankan
trap cleanup EXIT

# --- Logika Utama Skrip ---

# Tampilkan header biar keren
clear
echo "================================================================="
echo "                     VM MANAGER LAUNCHER"
echo "                         (All-in-One)"
echo "================================================================="
echo ""

# 1. Cek keberadaan curl
if ! command -v curl &> /dev/null; then
    error "'curl' tidak ditemukan. Silakan install curl terlebih dahulu."
    echo "    Contoh untuk Debian/Ubuntu: sudo apt-get install curl"
    echo "    Contoh untuk CentOS/RHEL:   sudo yum install curl"
    exit 1
fi

# 2. Cek apakah script VM sudah ada
if [ -f "$VM_SCRIPT_FILE" ]; then
    info "Script manajer VM ('$VM_SCRIPT_FILE') sudah ditemukan."
else
    warn "Script manajer VM tidak ditemukan. Akan mencoba mengunduh..."
    echo ""

    # 3. Jika tidak ada, lakukan pengunduhan
    info "Mengunduh dari: $SOURCE_URL"
    
    # Gunakan curl untuk mengunduh dengan progress bar dan handle error
    if curl --fail --show-error --location --progress-bar -o "$TEMP_DOWNLOAD_FILE" "$SOURCE_URL"; then
        info "Unduhan berhasil. Menyimpan sebagai '$VM_SCRIPT_FILE'."
        # Pindahkan file sementara ke file final
        mv "$TEMP_DOWNLOAD_FILE" "$VM_SCRIPT_FILE"
    else
        # Jika curl gagal, tampilkan pesan error yang jelas
        error "Gagal mengunduh script dari $SOURCE_URL"
        error "Periksa koneksi internet Anda atau pastikan URL dapat diakses."
        exit 1
    fi
    echo ""
fi

# 4. Cek dan berikan izin eksekusi
if [ -x "$VM_SCRIPT_FILE" ]; then
    info "Script sudah memiliki izin eksekusi."
else
    info "Memberikan izin eksekusi pada '$VM_SCRIPT_FILE'..."
    if chmod +x "$VM_SCRIPT_FILE"; then
        info "Izin eksekusi berhasil diberikan."
    else
        error "Gagal memberikan izin eksekusi."
        exit 1
    fi
fi

# 5. Jalankan script manajer VM
echo "================================================================="
info "Menjalankan Manajer VM..."
echo "================================================================="
# Gunakan exec untuk menggantikan proses skrip ini dengan proses VM manager
# Ini lebih efisien dan mencegah masalah dengan signal handling
exec bash "./$VM_SCRIPT_FILE"
