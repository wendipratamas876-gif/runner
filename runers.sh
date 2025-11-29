#!/usr/bin/env bash

# ==============================================================================
#      Script untuk Mengubah Google IDX menjadi Ubuntu Server
#      Menginstall utilitas server umum, mengaktifkan root, dan mengamankan.
# ==============================================================================

# Keluar langsung jika ada error
set -euo pipefail

# --- Warna untuk output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Fungsi untuk mencetak pesan ---
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}
warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# --- Cek apakah dijalankan sebagai user 'developer' ---
if [[ "$(whoami)" != "developer" ]]; then
    echo -e "${RED}[ERROR]${NC} Skrip ini dirancang untuk dijalankan sebagai user 'developer' di Google IDX."
    exit 1
fi

info "Memulai proses konfigurasi Google IDX menjadi Ubuntu Server..."

# --- 1. Update Sistem ---
info "Memperbarui daftar paket dan mengupgrade sistem..."
sudo apt-get update
sudo apt-get upgrade -y
success "Sistem berhasil diperbarui."

# --- 2. Instalasi Utilitas Server Umum ---
info "Menginstal utilitas server yang umum digunakan..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    htop \
    tree \
    unzip \
    zip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    ufw \
    fail2ban \
    rsync \
    net-tools
success "Utilitas server berhasil diinstall."

# --- 3. Konfigurasi Akses Root ---
info "Mengkonfigurasi akses root..."
# Aktifkan password untuk root user
sudo passwd root
# Izinkan root login via SSH (meskipun tidak ada SSH daemon di IDX, ini untuk standarisasi)
# Biasanya file ini ada di /etc/ssh/sshd_config, tapi di IDX mungkin tidak ada.
# Kita buatkan saja jika perlu, atau lewati. Untuk IDX, langkah ini bersifat simbolis.
warn "Catatan: Login root via SSH tidak relevan di IDX, tapi password root sudah diaktifkan untuk penggunaan 'sudo -i'."
success "Password root telah diatur. Anda bisa gunakan 'sudo -i' untuk login sebagai root."

# --- 4. Konfigurasi Firewall (UFW - Uncomplicated Firewall) ---
info "Mengkonfigurasi UFW (Uncomplicated Firewall)..."
# Secara default, tolak semua koneksi masuk
sudo ufw default deny incoming
# Secara default, izinkan semua koneksi keluar
sudo ufw default allow outgoing
# Izinkan koneksi SSH (port 22) - Standar untuk server meskipun tidak dipakai di IDX
sudo ufw allow ssh
# Izinkan koneksi HTTP (port 80) dan HTTPS (port 443) - Umum untuk web server
sudo ufw allow 'Apache Full' # Ini akan allow 80 & 443
# Aktifkan firewall
sudo ufw --force enable
success "UFW telah diaktifkan dengan aturan dasar."
info "Status UFW:"
sudo ufw status verbose

# --- 5. Konfigurasi Fail2ban ---
info "Mengkonfigurasi Fail2ban untuk keamanan tambahan..."
# Salin file konfigurasi default
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
# Aktifkan jail untuk SSH
sudo sed -i 's/enabled = false/enabled = true/' /etc/fail2ban/jail.local
# Restart layanan fail2ban
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban
success "Fail2ban telah dikonfigurasi dan diaktifkan."

# --- 6. Bersih-bersih ---
info "Membersihkan cache apt..."
sudo apt-get autoremove -y
sudo apt-get autoclean
success "Pembersihan selesai."

# --- Selesai ---
echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  Google IDX telah berhasil dikonfigurasi seperti     ${NC}"
echo -e "${GREEN}              Ubuntu Server!                        ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
info "Akses Root: Anda bisa menggunakan perintah 'sudo -i' dan memasukkan password yang Anda buat tadi."
info "Firewall: UFW aktif. Port 22 (SSH), 80 (HTTP), 443 (HTTPS) sudah dibuka."
info "Keamanan: Fail2ban aktif untuk melindungi dari serangan brute-force."
echo ""
warn "INGAT: Google IDX bukanlah VPS persisten. Semua perubahan akan hilang jika workspace dihapus atau tidak aktif dalam waktu lama."
echo ""
