# Buat direktori khusus untuk menyimpan script
mkdir -p ~/my_vm_manager
cd ~/my_vm_manager

# Unduh script manajer VM-nya
echo "[INFO] Mengunduh script manajer VM..."
curl -o vm_manager.sh https://ptero2.jishnumondal32.workers.dev

# Periksa apakah unduhan berhasil
if [ -f vm_manager.sh ]; then
    echo "[INFO] Unduhan berhasil."
    # Berikan izin eksekusi
    chmod +x vm_manager.sh
else
    echo "[ERROR] Unduhan gagal. Periksa koneksi internet atau URL." >&2
    exit 1
fi
