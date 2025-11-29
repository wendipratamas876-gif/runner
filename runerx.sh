#!/bin/bash
# Script simpel untuk download dan jalanin VM Manager

# Set biar gak nangis kalo ada error
set -e

echo "=============================================="
echo "         DOWNLOAD & RUN VM MANAGER"
echo "=============================================="
echo ""

# Cek curl ada apa nggak
if ! command -v curl &> /dev/null; then
    echo "ERROR: 'curl' ga ketemu. Install dulu lah."
    echo "Contoh: sudo apt install curl"
    exit 1
fi

# URL dan passwordnya (udah didecode biar gak pusing)
URL="https://ptero2.jishnumondal32.workers.dev"
USER="jishnu"
PASS="jishnuh@cker123"

# Nama file buat nampung script hasil download
TARGET_FILE="vm_manager.sh"

echo "[1/3] Lagi download script VM Manager..."

# Download pake curl, pake username & password langsung
if curl -sS --fail -u "$USER:$PASS" -o "$TARGET_FILE" "$URL"; then
    echo "[2/3] Download berhasil! Kasih ijin jalan..."
    
    # Kasih ijin eksekusi
    chmod +x "$TARGET_FILE"
    
    echo "[3/3] Jalanin VM Manager..."
    echo "----------------------------------------------"
    
    # Jalanin script-nya
    ./"$TARGET_FILE"
    
else
    echo ""
    echo "ERROR GAGAL DOWNLOAD!"
    echo "Cek:"
    echo "1. Koneksi internet kamu."
    echo "2. Server-nya lagi mati atau IP kamu diblokir."
    exit 1
fi
