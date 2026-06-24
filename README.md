# ManKu — Personal Finance Manager API

> **Backend REST API** untuk aplikasi keuangan personal berbasis AI. Dibangun dengan Django REST Framework dan terintegrasi dengan Groq AI untuk analisis transaksi otomatis.

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 🤖 **AI Chat Input** | Input transaksi via teks natural language, diproses AI |
| 🧾 **Scan Struk** | Foto struk belanja → otomatis ekstrak nominal & kategori |
| 🎙️ **Voice Input** | Input transaksi via rekaman suara (Whisper AI) |
| 📊 **Dashboard & Report** | Ringkasan keuangan, tren pengeluaran, laporan bulanan |
| 💰 **Savings Goals** | Kelola target tabungan dengan fitur setor & tarik dana |
| 📈 **Investment Portfolio** | Lacak portofolio crypto & saham dengan harga real-time |
| 🔔 **WhatsApp Bot** | Catat transaksi via pesan WhatsApp dengan AI |
| 🔐 **Auth + OTP Email** | Register, login, Google OAuth, reset password via email OTP |

---

## 🛠️ Tech Stack

- **Framework:** Django 4.2 + Django REST Framework
- **Database:** PostgreSQL
- **AI / LLM:** [Groq](https://groq.com/) — `meta-llama/llama-4-scout-17b-16e-instruct` (vision), `llama-3.3-70b-versatile` (text), `whisper-large-v3` (audio)
- **Auth:** JWT (SimpleJWT) + Google OAuth2
- **Deployment:** Oracle Cloud (Ubuntu + Nginx + Gunicorn)
- **Harga Aset:** Yahoo Finance (saham) + CoinGecko (crypto)

---

## 📁 Struktur Project

```
ManKu/
├── accounts/          # Auth: register, login, OTP, Google OAuth, reset password
├── finance/           # Core: transaksi, kategori, budget, tabungan, investasi
│   ├── views.py           # Endpoint utama (chat, scan, voice, dashboard, dst.)
│   ├── investment_views.py # Endpoint portofolio & harga real-time
│   ├── models.py          # Model: Transaction, Category, Budget, SavingsGoal, Investment
│   └── price_api_service.py # Service harga crypto & saham
├── whatsapp_bot/      # Bot WhatsApp berbasis AI
├── core/              # Settings, URL routing, konfigurasi
├── manage.py
└── requirements.txt
```

---

## 🚀 Cara Menjalankan Lokal

### 1. Clone & Setup Environment

```bash
git clone https://github.com/FandiCahya/Manku.git
cd Manku

python -m venv venv
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

pip install -r requirements.txt
```

### 2. Buat File `.env`

Buat file `.env` di root project:

```env
# Django
SECRET_KEY=your-secret-key-here
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# Database PostgreSQL
DB_NAME=manku_db
DB_USER=postgres
DB_PASSWORD=your-password
DB_HOST=127.0.0.1
DB_PORT=5432

# AI - Groq API
GROQ_API_KEY=your-groq-api-key

# Email (untuk OTP)
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
```

> **Catatan:** Dapatkan Groq API key gratis di [console.groq.com](https://console.groq.com)

### 3. Setup Database & Jalankan Server

```bash
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

API berjalan di: `http://localhost:8000`

---

## 📡 API Endpoints

### Authentication
| Method | Endpoint | Deskripsi |
|---|---|---|
| POST | `/api/auth/register/` | Daftar akun baru |
| POST | `/api/auth/verify-otp/` | Verifikasi OTP email |
| POST | `/api/auth/login/` | Login, dapat JWT token |
| POST | `/api/auth/google-login/` | Login via Google OAuth |
| POST | `/api/auth/password-reset/request/` | Kirim OTP reset password |
| POST | `/api/auth/password-reset/verify/` | Reset password dengan OTP |

### Transaksi
| Method | Endpoint | Deskripsi |
|---|---|---|
| GET | `/api/transactions/` | Daftar semua transaksi |
| POST | `/api/transactions/save-transaction/` | Simpan transaksi manual |
| POST | `/api/transactions/chat-input/` | Input transaksi via teks AI |
| POST | `/api/transactions/scan-receipt/` | Scan struk via gambar |
| POST | `/api/transactions/scan-voice/` | Input transaksi via suara |
| GET | `/api/transactions/dashboard-summary/` | Ringkasan dashboard |
| GET | `/api/transactions/report-summary/` | Laporan & kategori |
| PUT | `/api/transactions/{id}/` | Edit transaksi |
| DELETE | `/api/transactions/{id}/` | Hapus transaksi |

### Tabungan & Budget
| Method | Endpoint | Deskripsi |
|---|---|---|
| GET/POST | `/api/savings-goals/` | Daftar & buat target tabungan |
| POST | `/api/savings-goals/{id}/add-funds/` | Setor dana ke tabungan |
| POST | `/api/savings-goals/{id}/withdraw/` | Tarik dana dari tabungan |
| GET/POST | `/api/budget-goals/` | Kelola budget bulanan |
| GET | `/api/budget-goals/savings-overview/` | Overview tabungan vs budget |

### Investasi
| Method | Endpoint | Deskripsi |
|---|---|---|
| GET/POST | `/api/investments/` | Portofolio investasi |
| GET | `/api/investments/portfolio-summary/` | Ringkasan portofolio |
| GET | `/api/investments/price/?symbol=BTC&type=crypto` | Harga real-time |
| GET | `/api/investments/search-crypto/?q=bitcoin` | Cari aset crypto |

---

## 🔑 Autentikasi API

Semua endpoint (kecuali auth) membutuhkan JWT token:

```http
Authorization: Bearer <access_token>
```

Token didapat dari response `/api/auth/login/`:
```json
{
  "tokens": {
    "access": "eyJ...",
    "refresh": "eyJ..."
  }
}
```

---

## 🤖 Contoh Penggunaan AI

### Chat Input
```bash
POST /api/transactions/chat-input/
{
  "text": "tadi beli kopi 25000 di starbucks"
}
```
Response:
```json
{
  "extracted_data": {
    "amount": 25000,
    "description": "Kopi Starbucks",
    "type": "expense",
    "category_hint": "Makanan & Minuman",
    "date": "2026-06-24"
  }
}
```

### Scan Struk
```bash
POST /api/transactions/scan-receipt/
Content-Type: multipart/form-data

receipt_image: <file>
```
Response:
```json
{
  "extracted_data": {
    "amount": 38000,
    "description": "Indomaret",
    "category_hint": "Belanja"
  }
}
```

---

## 🗄️ Postman Collection

Import file `ManKu_API.postman_collection.json` ke Postman untuk langsung mencoba semua endpoint dengan contoh request yang sudah disiapkan.

---

## 📝 Lisensi

MIT License — bebas digunakan untuk keperluan belajar dan pengembangan.

---

*Built with ❤️ using Django REST Framework + Groq AI*
