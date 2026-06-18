# Panduan Testing API Multimodal Transaction

## 📋 Daftar Endpoint yang Diuji

### 1. **Scan Receipt Image** (Gambar Struk)
- **Endpoint**: `POST /api/finance/transactions/scan-receipt/`
- **Input**: File gambar struk belanja (JPG/PNG)
- **Output**: Data transaksi yang diekstrak dari gambar
- **Teknologi**: Groq Vision Model (llama-3.2-11b-vision-preview)

### 2. **Scan Voice Audio** (Rekaman Suara)
- **Endpoint**: `POST /api/finance/transactions/scan-voice/`
- **Input**: File audio rekaman suara (MP3/WAV/M4A)
- **Output**: Transkripsi teks + data transaksi yang diekstrak
- **Teknologi**: Groq Whisper (whisper-large-v3) + GPT Text Model

### 3. **Chat Input Text** (Bonus)
- **Endpoint**: `POST /api/finance/transactions/chat-input/`
- **Input**: Teks deskripsi transaksi
- **Output**: Data transaksi yang diekstrak + otomatis disimpan ke database
- **Teknologi**: Groq Text Model (llama-3.3-70b-versatile)

---

## 🚀 Cara Menjalankan Test

### Langkah 1: Persiapan File Test

#### A. Untuk Test Gambar Struk
1. Ambil foto struk belanja Anda (format JPG/PNG)
2. Simpan dengan nama `test_receipt.jpg` di folder proyek
3. Atau gunakan gambar struk contoh

#### B. Untuk Test Audio Suara
1. Rekam suara Anda dengan format MP3/WAV
2. Contoh isi rekaman: *"Saya beli makan siang lima puluh ribu rupiah"*
3. Simpan dengan nama `test_voice.mp3` di folder proyek

**Alternatif**: Jika tidak ada file, test akan memberi peringatan tapi tetap lanjut ke test lainnya.

---

### Langkah 2: Setup Environment

```bash
# Aktifkan virtual environment
venv\Scripts\activate

# Install dependencies jika belum
pip install requests
```

---

### Langkah 3: Dapatkan Token Autentikasi

#### Opsi A: Login via API
```bash
# Login untuk mendapatkan token
curl -X POST http://127.0.0.1:8000/api/accounts/login/ \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"your_username\",\"password\":\"your_password\"}"
```

Atau gunakan Postman Collection yang sudah ada: `ManKu_API.postman_collection.json`

#### Opsi B: Dapatkan dari Django Admin
1. Login ke Django admin
2. Buat token di admin panel untuk user Anda

#### Opsi C: Lanjut Tanpa Autentikasi
Jika endpoint tidak memerlukan autentikasi, script akan menawarkan untuk lanjut tanpa token.

---

### Langkah 4: Update Script dengan Token

Edit file `test_multimodal_api.py`:

```python
# Ganti baris ini:
AUTH_TOKEN = "YOUR_AUTH_TOKEN_HERE"

# Dengan token Anda:
AUTH_TOKEN = "eyJ0eXAiOiJKV1QiLCJhbGc..."  # Token dari login
```

---

### Langkah 5: Jalankan Django Server

```bash
# Terminal 1: Jalankan Django server
python manage.py runserver
```

---

### Langkah 6: Jalankan Script Test

```bash
# Terminal 2: Jalankan test script
python test_multimodal_api.py
```

---

## 📊 Output yang Diharapkan

### Test Berhasil (Scan Receipt)
```
==============================================================================
  TEST 1: Scan Receipt Image
==============================================================================

📤 Request URL: http://127.0.0.1:8000/api/finance/transactions/scan-receipt/
📥 Status Code: 200

📄 Response Body:
{
  "message": "Struk berhasil dianalisis oleh OpenAI",
  "extracted_data": {
    "amount": 125000,
    "description": "Indomaret",
    "category_hint": "Belanja"
  }
}

✅ TEST BERHASIL: Gambar struk berhasil dianalisis!

   💰 Amount: Rp 125,000
   📝 Description: Indomaret
   🏷️  Category: Belanja
```

### Test Berhasil (Scan Voice)
```
==============================================================================
  TEST 2: Scan Voice Audio
==============================================================================

📤 Request URL: http://127.0.0.1:8000/api/finance/transactions/scan-voice/
📥 Status Code: 200

📄 Response Body:
{
  "message": "Suara berhasil dianalisis oleh OpenAI",
  "transcription": "Saya beli makan siang lima puluh ribu rupiah",
  "extracted_data": {
    "amount": 50000,
    "description": "Beli makan siang",
    "type": "expense",
    "category_hint": "Makanan"
  }
}

✅ TEST BERHASIL: Audio suara berhasil dianalisis!

   🎤 Transcription: Saya beli makan siang lima puluh ribu rupiah

   💰 Amount: Rp 50,000
   📝 Description: Beli makan siang
   🏷️  Category: Makanan
   📊 Type: expense
```

---

## 🧪 Test Manual dengan cURL

### Test Scan Receipt
```bash
curl -X POST http://127.0.0.1:8000/api/finance/transactions/scan-receipt/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "receipt_image=@test_receipt.jpg"
```

### Test Scan Voice
```bash
curl -X POST http://127.0.0.1:8000/api/finance/transactions/scan-voice/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "audio_file=@test_voice.mp3"
```

### Test Chat Input
```bash
curl -X POST http://127.0.0.1:8000/api/finance/transactions/chat-input/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"text\":\"Tadi pagi beli nasi goreng 25 ribu\"}"
```

---

## 🧪 Test Manual dengan Postman

1. Buka Postman Collection: `ManKu_API.postman_collection.json`
2. Import Environment: `ManKu_ENV.postman_environment.json`
3. Login dulu untuk mendapatkan token
4. Test endpoint:
   - **Scan Receipt**: Pilih endpoint, upload file di Body > form-data
   - **Scan Voice**: Upload file audio di Body > form-data
   - **Chat Input**: Kirim JSON di Body > raw

---

## ⚠️ Troubleshooting

### Error: "Server tidak berjalan"
**Solusi**: Jalankan `python manage.py runserver`

### Error: "File tidak ditemukan"
**Solusi**: 
- Pastikan file `test_receipt.jpg` atau `test_voice.mp3` ada di folder proyek
- Atau skip test tersebut dengan menekan Enter

### Error: "Gagal membaca format JSON dari AI"
**Kemungkinan**:
- API Groq rate limit
- Gambar tidak jelas atau tidak ada teks
- Audio tidak terdengar jelas

**Solusi**: 
- Tunggu beberapa saat lalu coba lagi
- Gunakan gambar/audio yang lebih jelas
- Cek API key Groq masih valid

### Error: "Unauthorized" (401)
**Solusi**: 
- Login dulu untuk mendapatkan token
- Update `AUTH_TOKEN` di script
- Atau jalankan tanpa autentikasi jika endpoint tidak dilindungi

### Error: "Groq API Key Invalid"
**Solusi**: 
- Cek file `finance/views.py` line 17
- Pastikan API key Groq masih valid
- Atau ganti dengan API key baru dari https://console.groq.com

---

## 📝 Catatan Penting

1. **Rate Limit**: Groq API memiliki rate limit. Jika error, tunggu beberapa saat.
2. **File Size**: Untuk gambar, usahakan ukuran < 5MB. Untuk audio, < 25MB.
3. **Format Audio**: Mendukung MP3, WAV, M4A, WebM, FLAC, OGG
4. **Format Gambar**: Mendukung JPG, PNG
5. **Bahasa**: Whisper diset ke Bahasa Indonesia (`language="id"`)
6. **Auto Save**: Endpoint `chat-input` otomatis menyimpan transaksi ke database

---

## 🔗 Referensi API

### Models yang Digunakan
- **Vision**: `llama-3.2-11b-vision-preview` (untuk analisis gambar struk)
- **Text**: `llama-3.3-70b-versatile` (untuk ekstraksi data dari teks)
- **Audio**: `whisper-large-v3` (untuk speech-to-text)

### Provider
- **Groq Cloud**: https://console.groq.com

---

## ✅ Checklist Testing

- [ ] Django server berjalan
- [ ] Token autentikasi didapat
- [ ] File test_receipt.jpg tersedia
- [ ] File test_voice.mp3 tersedia
- [ ] Script test_multimodal_api.py sudah diupdate dengan token
- [ ] Test scan receipt berhasil
- [ ] Test scan voice berhasil
- [ ] Test chat input berhasil
- [ ] Data tersimpan di database

---

## 📧 Kontak

Jika ada masalah atau pertanyaan, silakan buka issue atau hubungi tim developer.

**Happy Testing! 🚀**
