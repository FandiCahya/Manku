# 🚀 WhatsApp Bot - Installation & Setup Instructions

Panduan lengkap untuk menginstall dan menjalankan WhatsApp Bot ManKu.

---

## 📋 Prerequisites

### Required Software:
1. **Python 3.8+** - Backend bot
2. **Node.js 16+** - WhatsApp Web integration
3. **Django Backend** - ManKu backend harus running

### Check Installations:
```bash
python --version    # Should be 3.8+
node --version      # Should be 16+
npm --version       # Should be 8+
```

---

## 📦 Step 1: Install Python Dependencies

```bash
# Navigate to whatsapp_bot folder
cd whatsapp_bot

# Install Python packages
pip install -r requirements.txt
```

**Dependencies yang akan terinstall:**
- `groq` - AI untuk parsing natural language
- `requests` - HTTP client
- `aiohttp` - Async HTTP server
- `python-dotenv` - Environment variables

---

## 📦 Step 2: Install Node.js Dependencies

```bash
# Masih di folder whatsapp_bot
npm install
```

**Dependencies yang akan terinstall:**
- `whatsapp-web.js` - WhatsApp Web library
- `qrcode-terminal` - Display QR code
- `express` - HTTP server
- `axios` - HTTP client

---

## ⚙️ Step 3: Configure Bot

### 3.1 Edit Whitelist Numbers

Edit file `whatsapp_bot/bot_config.py`:

```python
# Tambahkan nomor WhatsApp yang diizinkan (format: 628xxx)
ALLOWED_PHONE_NUMBERS = [
    '628123456789',  # 🔴 GANTI DENGAN NOMOR ANDA
    '628987654321',  # Tambahkan nomor lain jika perlu
]
```

**Format Nomor:**
- ✅ BENAR: `'628123456789'` (tanpa +, tanpa spasi, tanpa -)
- ❌ SALAH: `'+62 812-3456-789'`

### 3.2 (Optional) Customize Settings

Di file `bot_config.py`, Anda bisa ubah:

```python
# Command prefix
COMMAND_PREFIX = '/manku'      # Prefix utama
ALTERNATIVE_PREFIX = '!m'       # Prefix alternatif

# Backend URL (sesuaikan jika berbeda)
BACKEND_URL = 'http://127.0.0.1:8000'

# Rate limiting
RATE_LIMIT_PER_MINUTE = 10     # Max pesan per menit
```

---

## 🗄️ Step 4: Database Migration

Buat tabel `WhatsAppUser` di database:

```bash
# Kembali ke root folder ManKu
cd ..

# Create migration
python manage.py makemigrations accounts

# Apply migration
python manage.py migrate
```

**Output yang diharapkan:**
```
Migrations for 'accounts':
  accounts/migrations/0003_whatsappuser.py
    - Create model WhatsAppUser
```

---

## 👤 Step 5: Register WhatsApp Numbers

### Method 1: Via Django Admin (Recommended)

1. **Start Django server:**
```bash
python manage.py runserver
```

2. **Open admin panel:**
   - URL: http://127.0.0.1:8000/admin/
   - Login dengan superuser

3. **Create superuser (jika belum ada):**
```bash
python manage.py createsuperuser
```

4. **Register WhatsApp number:**
   - Masuk ke admin panel
   - Klik "WhatsApp Users"
   - Klik "Add WhatsApp User"
   - **User**: Pilih user yang ingin didaftarkan
   - **Phone number**: Masukkan nomor WA (format: 628xxx)
   - **Is active**: Centang
   - Klik "Save"

### Method 2: Via Django Shell

```bash
python manage.py shell
```

```python
from django.contrib.auth.models import User
from accounts.models import WhatsAppUser

# Ambil user (ganti dengan username Anda)
user = User.objects.get(username='john_doe')

# Daftarkan nomor WhatsApp
WhatsAppUser.objects.create(
    user=user,
    phone_number='628123456789'  # Ganti dengan nomor Anda
)

print("✅ WhatsApp number registered!")
exit()
```

---

## 🚀 Step 6: Run the Bot

### Terminal 1: Start Django Backend

```bash
python manage.py runserver
```

**Keep this running!** Bot needs backend API.

### Terminal 2: Start WhatsApp Bot

```bash
cd whatsapp_bot
python run_bot.py
```

**Output yang diharapkan:**
```
================================================================================
🤖 ManKu WhatsApp Bot
================================================================================

🐍 Python server started on http://localhost:8001
🚀 WhatsApp Bot Server running on http://localhost:3000
📱 Starting WhatsApp client...
```

---

## 📱 Step 7: Scan QR Code

1. **Wait for QR code** - Akan muncul di terminal:
```
📱 QR Code received! Please scan with WhatsApp:
█████████████████████████████
█████████████████████████████
█████████████████████████████
```

2. **Open WhatsApp on your phone**

3. **Go to Settings → Linked Devices**

4. **Click "Link a Device"**

5. **Scan the QR code** yang muncul di terminal

6. **Wait for confirmation:**
```
✅ Authenticated with WhatsApp
✅ WhatsApp Bot is ready!
🤖 Bot is now listening for messages...
```

---

## ✅ Step 8: Test the Bot

Kirim pesan WhatsApp ke nomor yang sudah di-scan:

### Test 1: Help Command
```
/manku help
```

**Expected Response:**
```
🤖 ManKu Bot - Bantuan

Perintah yang tersedia:
...
```

### Test 2: Balance Check
```
/manku saldo
```

**Expected Response:**
```
💰 Saldo Anda

📈 Total Balance: Rp ...
...
```

### Test 3: Transaction Input
```
/manku beli kopi 25000
```

**Expected Response:**
```
⏳ Sedang memproses transaksi...

✅ Transaksi Berhasil Disimpan!
💰 Nominal: Rp 25,000
...
```

---

## 🔧 Troubleshooting

### Problem 1: Bot tidak merespon

**Check 1: Whitelist**
- Pastikan nomor WA ada di `ALLOWED_PHONE_NUMBERS` di `bot_config.py`

**Check 2: Prefix**
- Pesan harus diawali `/manku` atau `!m`
- Contoh BENAR: `/manku help`
- Contoh SALAH: `help` (tanpa prefix)

**Check 3: Registration**
- Pastikan nomor WA sudah terdaftar di Django Admin → WhatsApp Users

**Check 4: Django Backend**
- Pastikan Django running di http://127.0.0.1:8000

### Problem 2: QR Code tidak muncul

**Solution:**
1. Check Node.js terinstall: `node --version`
2. Check dependencies terinstall: `npm list` di folder whatsapp_bot
3. Reinstall: `npm install`
4. Restart bot: `python run_bot.py`

### Problem 3: "User not found" error

**Solution:**
Nomor WA belum didaftarkan. Daftarkan via Django Admin:
1. Admin → WhatsApp Users → Add
2. Pilih User
3. Masukkan nomor WA
4. Save

### Problem 4: Rate limit exceeded

**Error Message:**
```
⚠️ Anda mengirim terlalu banyak pesan. Silakan tunggu 1 menit.
```

**Solution:**
- Tunggu 1 menit
- Rate limit: 10 pesan per menit

### Problem 5: AI parsing gagal

**Error:**
```
❌ Maaf, saya tidak bisa memahami transaksi tersebut.
```

**Solution:**
Format pesan harus jelas:
- ✅ BENAR: `/manku beli kopi 25000`
- ❌ SALAH: `/manku kopi aja`

Harus ada:
- Deskripsi yang jelas
- Nominal dalam angka

### Problem 6: Module not found error

**Error:**
```
ModuleNotFoundError: No module named 'groq'
```

**Solution:**
```bash
pip install -r whatsapp_bot/requirements.txt
```

### Problem 7: Port already in use

**Error:**
```
Address already in use: 3000
```

**Solution:**

Windows:
```bash
# Find process on port 3000
netstat -ano | findstr :3000

# Kill process (replace PID)
taskkill /PID <PID> /F

# Restart bot
python run_bot.py
```

---

## 📊 Monitoring

### Check Logs

**Log file location:**
```
whatsapp_bot/whatsapp_bot.log
```

**View logs:**
```bash
# Windows
type whatsapp_bot.log

# Real-time monitoring
tail -f whatsapp_bot.log  # (Jika punya Git Bash)
```

### Check Bot Status

**Check if bot is running:**

Open browser:
- http://localhost:3000/status (Node.js server)
- http://localhost:8001 (Python server)

---

## 🛑 Stop the Bot

### Graceful Shutdown

1. **In terminal where bot is running**
2. **Press:** `Ctrl + C`
3. **Wait for:** "🛑 Bot stopped"

### Force Stop (if needed)

**Windows:**
```bash
# Kill Python process
taskkill /IM python.exe /F

# Kill Node.js process
taskkill /IM node.exe /F
```

---

## 🔄 Restart the Bot

**After configuration changes:**

1. Stop bot (Ctrl + C)
2. Edit configuration
3. Restart: `python run_bot.py`

**No need to scan QR again** - Session is saved!

---

## 📝 Important Notes

### 1. Session Persistence
- QR code scan **hanya sekali**
- Session tersimpan di `.wwebjs_auth/`
- Tidak perlu scan ulang setiap restart

### 2. Django Backend Required
- Backend **HARUS running** untuk bot berfungsi
- Port 8000 harus accessible

### 3. Multiple Users
- Bisa tambah banyak nomor di whitelist
- Setiap nomor harus terdaftar di Django Admin

### 4. Groups Not Supported
- Bot **TIDAK** merespon pesan di grup
- Hanya personal chat

### 5. Groq API Key
- API key sudah hardcoded di `bot_config.py`
- Free tier sudah cukup untuk testing
- Bisa ganti dengan API key sendiri jika perlu

---

## 🎯 Quick Start Summary

```bash
# 1. Install dependencies
cd whatsapp_bot
pip install -r requirements.txt
npm install

# 2. Configure whitelist
# Edit bot_config.py → ALLOWED_PHONE_NUMBERS

# 3. Database migration
cd ..
python manage.py makemigrations
python manage.py migrate

# 4. Register WA number via Django Admin
python manage.py runserver
# Open admin → Add WhatsApp User

# 5. Start bot (in separate terminals)
# Terminal 1:
python manage.py runserver

# Terminal 2:
cd whatsapp_bot
python run_bot.py

# 6. Scan QR code with WhatsApp

# 7. Test bot
# Send: /manku help
```

---

## 📚 Documentation References

- **Complete Guide**: `WHATSAPP_BOT_GUIDE.md`
- **Feature Summary**: `WHATSAPP_BOT_SUMMARY.md`
- **Command Reference**: `whatsapp_bot/QUICK_REFERENCE.md`
- **Project Summary**: `COMPLETE_PROJECT_SUMMARY.md`

---

## ✅ Installation Checklist

Before running bot, make sure:

- [ ] Python 3.8+ installed
- [ ] Node.js 16+ installed
- [ ] Python dependencies installed (`pip install -r requirements.txt`)
- [ ] Node.js dependencies installed (`npm install`)
- [ ] Whitelist configured in `bot_config.py`
- [ ] Database migrated (`python manage.py migrate`)
- [ ] WhatsApp numbers registered in Django Admin
- [ ] Django backend running (`python manage.py runserver`)
- [ ] Bot started (`python run_bot.py`)
- [ ] QR code scanned with WhatsApp
- [ ] Test command sent (`/manku help`)

---

## 🎉 Success!

Jika semua langkah berhasil, Anda akan melihat:

✅ Bot running di terminal
✅ "WhatsApp Bot is ready!" message
✅ Bot merespon command `/manku help`
✅ Transaksi bisa disimpan via WhatsApp

**Selamat! Bot WhatsApp ManKu sudah siap digunakan! 🚀💰📱**

---

## 📞 Need Help?

Jika ada masalah:
1. Check troubleshooting section di atas
2. Check log file: `whatsapp_bot.log`
3. Verify semua checklist terpenuhi
4. Check terminal output untuk error messages

**Good luck! 🍀**
