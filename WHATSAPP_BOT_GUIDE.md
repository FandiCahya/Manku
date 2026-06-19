# 🤖 ManKu WhatsApp Bot - Setup & Usage Guide

Bot WhatsApp AI untuk input transaksi dan cek data keuangan langsung dari WhatsApp.

## 📋 Fitur

✅ **Input Transaksi via Natural Language**
- Kirim pesan seperti "beli kopi 25000" langsung jadi transaksi
- AI akan parsing otomatis: nominal, deskripsi, kategori, tipe (income/expense)

✅ **Cek Saldo**
- Command: `/manku saldo` atau `!m balance`
- Tampilkan total balance, income, expense

✅ **Report Bulanan**
- Command: `/manku report` atau `!m laporan`
- Tampilkan pemasukan, pengeluaran, top kategori

✅ **Cek Investasi**
- Command: `/manku investasi` atau `!m investment`
- Tampilkan portfolio crypto & saham

✅ **Security Features**
- Whitelist nomor WA (hanya nomor terdaftar yang direspon)
- Command prefix wajib (`/manku` atau `!m`)
- Rate limiting (10 pesan per menit)

---

## 🛠️ Instalasi

### 1. Install Node.js Dependencies

```bash
cd whatsapp_bot
npm install
```

Dependencies yang akan terinstall:
- `whatsapp-web.js` - Library untuk WhatsApp Web
- `qrcode-terminal` - Menampilkan QR code di terminal
- `express` - HTTP server
- `axios` - HTTP client

### 2. Install Python Dependencies

```bash
pip install -r whatsapp_bot/requirements.txt
```

Dependencies:
- `groq` - AI untuk parsing natural language
- `requests` - HTTP client untuk backend API
- `aiohttp` - Async HTTP server
- `python-dotenv` - Environment variables

### 3. Konfigurasi

Edit file `whatsapp_bot/bot_config.py`:

```python
# Tambahkan nomor WhatsApp yang diizinkan
ALLOWED_PHONE_NUMBERS = [
    '628123456789',  # Ganti dengan nomor Anda
    '628987654321',  # Tambahkan nomor lain
]

# Command prefix (opsional)
COMMAND_PREFIX = '/manku'
ALTERNATIVE_PREFIX = '!m'

# Backend URL (sesuaikan jika berbeda)
BACKEND_URL = 'http://127.0.0.1:8000'
```

### 4. Database Migration

Jalankan migration untuk membuat tabel WhatsAppUser:

```bash
python manage.py makemigrations
python manage.py migrate
```

### 5. Register Nomor WhatsApp ke User Account

Ada 2 cara:

**Cara 1: Via Django Admin**
1. Buka http://127.0.0.1:8000/admin/
2. Masuk ke "WhatsApp Users"
3. Klik "Add WhatsApp User"
4. Pilih User dan masukkan nomor WA (format: 628xxx)
5. Save

**Cara 2: Via Django Shell**
```bash
python manage.py shell
```

```python
from django.contrib.auth.models import User
from accounts.models import WhatsAppUser

# Ambil user
user = User.objects.get(username='your_username')

# Daftarkan nomor WA
WhatsAppUser.objects.create(
    user=user,
    phone_number='628123456789'  # Nomor WA Anda
)
```

---

## 🚀 Cara Menjalankan Bot

### 1. Start Django Backend

Di terminal pertama:
```bash
python manage.py runserver
```

### 2. Start WhatsApp Bot

Di terminal kedua:
```bash
cd whatsapp_bot
python run_bot.py
```

### 3. Scan QR Code

1. Bot akan menampilkan QR code di terminal
2. Buka WhatsApp di HP
3. Settings → Linked Devices → Link a Device
4. Scan QR code yang muncul di terminal
5. Tunggu sampai muncul "✅ WhatsApp Bot is ready!"

### 4. Test Bot

Kirim pesan ke nomor WA yang sudah di-scan:

```
/manku help
```

Jika berhasil, bot akan membalas dengan daftar command.

---

## 💬 Cara Menggunakan

### Format Pesan

Semua pesan HARUS diawali dengan `/manku` atau `!m`:

```
/manku <command>
!m <command>
```

### Commands

#### 1. Input Transaksi (Default)

Langsung kirim deskripsi transaksi:

```
/manku beli kopi 25000
/manku terima gaji 5 juta
/manku bayar listrik 500rb
!m beli buku 150ribu
!m dapat bonus 2jt
```

AI akan otomatis parsing:
- **Nominal**: 25000, 5 juta, 500rb → dikonversi ke angka
- **Deskripsi**: "beli kopi", "terima gaji", dll
- **Tipe**: expense (beli, bayar) atau income (terima, dapat)
- **Kategori**: otomatis (Makanan, Gaji, Tagihan, dll)

Response:
```
✅ Transaksi Berhasil Disimpan!

💰 Nominal: Rp 25,000
📝 Deskripsi: beli kopi
🏷️ Kategori: Makanan & Minuman
📊 Tipe: EXPENSE
📅 Tanggal: 2024-01-15

Terima kasih sudah menggunakan ManKu! 🎉
```

#### 2. Cek Saldo

```
/manku saldo
!m balance
```

Response:
```
💰 Saldo Anda

📈 Total Balance: Rp 5,000,000
📊 Total Income: Rp 10,000,000
📊 Total Expense: Rp 5,000,000

Update: 15 Jan 2024, 14:30
```

#### 3. Report Bulanan

```
/manku report
!m laporan
```

Response:
```
📊 Report Bulan Ini

💵 Pemasukan: Rp 5,000,000
💸 Pengeluaran: Rp 3,500,000
📈 Net: Rp 1,500,000

Top Kategori Pengeluaran:
• Makanan & Minuman: Rp 1,200,000
• Transport: Rp 800,000
• Belanja: Rp 600,000
```

#### 4. Cek Investasi

```
/manku investasi
!m investment
```

Response:
```
📈 Portfolio Investasi

💼 Total Investment: Rp 10,000,000
💰 Current Value: Rp 12,500,000
📊 Profit/Loss: Rp 2,500,000 (25.00%)

🪙 Crypto: Rp 6,500,000
📈 Saham: Rp 6,000,000
```

#### 5. Bantuan

```
/manku help
!m ?
```

---

## 🔒 Security

### Whitelist

Hanya nomor WA yang ada di `ALLOWED_PHONE_NUMBERS` yang akan direspon.

Edit di `bot_config.py`:
```python
ALLOWED_PHONE_NUMBERS = [
    '628123456789',
]
```

### Command Prefix

Semua pesan HARUS diawali prefix:
- `/manku` (default)
- `!m` (alternatif pendek)

Pesan tanpa prefix akan diabaikan.

### Rate Limiting

Maksimal 10 pesan per menit per user.

### User Authentication

Nomor WA harus terhubung dengan user account via tabel `WhatsAppUser`.

---

## 🔧 Troubleshooting

### Bot tidak merespon

1. **Cek whitelist**: Pastikan nomor WA ada di `ALLOWED_PHONE_NUMBERS`
2. **Cek prefix**: Pesan harus diawali `/manku` atau `!m`
3. **Cek mapping**: Pastikan nomor WA sudah terdaftar di Django Admin → WhatsApp Users
4. **Cek log**: Lihat terminal untuk error message

### QR Code tidak muncul

1. Pastikan Node.js sudah terinstall: `node --version`
2. Pastikan dependencies sudah terinstall: `npm install`
3. Cek firewall - port 3000 harus terbuka

### Error "User not found"

Nomor WA belum didaftarkan. Daftarkan via Django Admin:
1. Admin → WhatsApp Users → Add
2. Pilih User
3. Masukkan nomor WA (format: 628xxx)

### AI parsing gagal

Coba format pesan yang lebih jelas:
```
✅ BENAR: /manku beli kopi 25000
❌ SALAH: /manku kopi aja
```

Harus ada:
- Deskripsi jelas
- Nominal dalam angka

### Rate limit exceeded

Tunggu 1 menit sebelum kirim pesan lagi.

---

## 📁 Struktur File

```
whatsapp_bot/
├── bot_config.py              # Konfigurasi bot (whitelist, prefix, dll)
├── whatsapp_client.py         # WhatsApp client wrapper
├── message_handler.py         # Handler pesan masuk & routing
├── ai_parser.py               # AI parsing natural language
├── backend_integration.py     # Integration dengan Django backend
├── bot_commands.py            # Implementasi semua command
├── whatsapp_server.js         # Node.js server (WhatsApp Web)
├── run_bot.py                 # Main entry point
├── requirements.txt           # Python dependencies
└── package.json               # Node.js dependencies
```

---

## 🔄 Flow Architecture

```
[WhatsApp User]
      ↓
[WhatsApp Web] ← (QR Code scan)
      ↓
[Node.js Server] (whatsapp_server.js)
      ↓ HTTP POST
[Python Server] (run_bot.py)
      ↓
[Message Handler] (message_handler.py)
      ↓
[Security Check] (whitelist + prefix)
      ↓
[Command Routing]
      ├── Transaction → [AI Parser] → [Backend API]
      ├── Balance → [Backend API]
      ├── Report → [Backend API]
      └── Investment → [Backend API]
      ↓
[Response to User]
```

---

## 🧪 Testing

### Test 1: Help Command
```
/manku help
```
Expected: Daftar command

### Test 2: Transaction Input
```
/manku beli kopi 25000
```
Expected: Konfirmasi transaksi tersimpan

### Test 3: Balance Check
```
/manku saldo
```
Expected: Saldo, income, expense

### Test 4: Report
```
/manku report
```
Expected: Report bulanan

### Test 5: Invalid Prefix
```
beli kopi 25000  (tanpa prefix)
```
Expected: Tidak ada response (diabaikan)

---

## 📝 Notes

1. **Session WhatsApp**: Setelah scan QR pertama kali, session akan tersimpan. Tidak perlu scan ulang setiap kali start bot.

2. **Multiple Users**: Bisa tambahkan banyak nomor WA di whitelist dan mapping ke user berbeda.

3. **Grup WhatsApp**: Bot tidak merespon pesan di grup, hanya personal chat.

4. **Backend Harus Running**: Django backend (manage.py runserver) harus running agar bot bisa save transaksi.

5. **Groq API Key**: Sudah hardcoded di `bot_config.py`. Bisa diganti ke API key sendiri jika perlu.

---

## 🚧 Future Improvements

- [ ] Voice message support (speech-to-text)
- [ ] Image receipt scanning via WA
- [ ] Multi-language support
- [ ] Reminder untuk budget limit
- [ ] Export report ke PDF via WA
- [ ] Notifikasi otomatis (budget alert, dll)

---

## 📞 Support

Jika ada masalah, cek:
1. Log file: `whatsapp_bot.log`
2. Terminal output dari Node.js dan Python
3. Django log

---

**Happy Budgeting! 💰📊**
