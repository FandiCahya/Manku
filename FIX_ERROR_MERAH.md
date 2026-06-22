# 🔴 FIX ERROR "MERAH SEMUA"

## PENYEBAB KEMUNGKINAN:

Error "merah semua" biasanya disebabkan oleh:
1. **Hot reload gagal** - Widget tree berubah tapi tidak ter-reload dengan benar
2. **Context error** - Widget mencoba akses context yang tidak valid
3. **Missing provider** - BlocProvider tidak tersedia
4. **Runtime exception** - Ada error saat build widget

---

## ✅ SOLUSI LANGKAH DEMI LANGKAH:

### Step 1: STOP Aplikasi
```bash
# Tekan Ctrl+C di terminal Flutter
```

### Step 2: Clean Build
```bash
flutter clean
```

### Step 3: Get Dependencies
```bash
flutter pub get
```

### Step 4: Run Ulang
```bash
flutter run -d chrome --web-renderer html
```

**PENTING:** Gunakan `--web-renderer html` untuk menghindari masalah rendering di Chrome!

### Step 5: Tunggu Compile Selesai
```
✓ Built build\web\main.dart.js
Launching lib\main.dart on Chrome in debug mode...
```

### Step 6: Refresh Browser
- Tekan **F5** atau **Ctrl+R** di browser
- Atau tutup tab dan buka lagi di `localhost:xxxx`

---

## 🔍 CEK ERROR DI CONSOLE:

### 1. Buka Browser DevTools
- Tekan **F12** di Chrome
- Atau klik kanan → **Inspect**

### 2. Buka Tab "Console"
- Lihat apakah ada pesan error warna merah
- Screenshot error message
- Kirim ke saya

### 3. Cek Stack Trace
Error biasanya menunjukkan di file mana masalahnya. Contoh:
```
Error: InvestmentCubit not found
    at investment_tab.dart:15
    at home_page.dart:580
```

---

## 🐛 TROUBLESHOOTING SPESIFIK INVESTMENT:

### Error: "Couldn't find InvestmentCubit"

**Penyebab:** Provider tidak terdaftar di main.dart

**Solusi:** Cek file `lib/main.dart`, pastikan ada ini:
```dart
BlocProvider<InvestmentCubit>(
  create: (context) => InvestmentCubit()..loadInvestments(),
),
```

### Error: "Failed to load"

**Penyebab:** API backend tidak running atau endpoint salah

**Solusi:**
1. Pastikan backend berjalan
2. Cek API endpoint di `lib/core/constants/api_config.dart`
3. Test API di Postman:
   ```
   GET http://localhost:8000/api/v1/investments/
   GET http://localhost:8000/api/v1/investments/summary/
   ```

### Error: "RenderFlex overflowed"

**Penyebab:** Widget melebihi ukuran layar

**Solusi:** Sudah handled dengan Expanded dan Flexible

### Error: "Context error" atau "Overlay not found"

**Penyebab:** Debug overlay issue

**Solusi:** Sudah diperbaiki dengan Directionality wrapper

---

## 📋 PERINTAH LENGKAP (COPY-PASTE):

```bash
# 1. Stop aplikasi (Ctrl+C)

# 2. Clean semua
flutter clean

# 3. Get dependencies
flutter pub get

# 4. Run dengan html renderer
flutter run -d chrome --web-renderer html

# 5. Tunggu sampai selesai compile

# 6. Refresh browser (F5)
```

---

## 📸 INFORMASI YANG DIBUTUHKAN:

Jika masih error setelah langkah di atas, kirim ke saya:

### 1. Screenshot Error di Browser Console
- Buka DevTools (F12)
- Tab "Console"
- Screenshot semua pesan error merah

### 2. Screenshot Terminal Output
- Screenshot output dari `flutter run`
- Terutama bagian yang ada "ERROR" atau "EXCEPTION"

### 3. Screenshot Halaman App
- Screenshot tampilan app yang "merah semua"
- Ini membantu saya identifikasi masalahnya

### 4. Copy-Paste Error Message
Jika memungkinkan, copy-paste text error dari console:
```
Copy error text di sini...
```

---

## 🔧 FIX ALTERNATIF:

### Opsi 1: Disable Investment Tab Sementara

Jika investment tab terus error, kita bisa disable dulu:

```dart
// File: lib/pages/home_page.dart
// Line ~560

Widget _buildReportsContent() {
  return DefaultTabController(
    length: 1,  // ← Ubah dari 2 ke 1
    child: SafeArea(
      child: Column(
        children: [
          // Tab Bar - COMMENT OUT
          // Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          //   ...
          // ),

          // Tab Views
          Expanded(
            child: RefreshIndicator(  // ← Langsung tampilkan Transactions
              onRefresh: _fetchReport,
              child: SingleChildScrollView(
                ...
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

### Opsi 2: Ganti Investment Tab dengan Placeholder

```dart
// Investments Tab - ganti dengan placeholder
Center(
  child: Text('Investment feature under maintenance'),
),
```

---

## ✅ VERIFIKASI SETELAH FIX:

Setelah run ulang, cek:

- [ ] App terbuka tanpa error
- [ ] Bottom navigation terlihat
- [ ] Bisa navigasi ke semua halaman
- [ ] Dashboard loading dengan benar
- [ ] History loading dengan benar
- [ ] Reports → Transactions tab berfungsi
- [ ] Reports → Investments tab loading (atau error tapi tidak crash app)

---

## 📞 JIKA MASIH BERMASALAH:

Saya butuh informasi ini untuk help lebih lanjut:

1. **Screenshot browser console** (F12 → Console tab)
2. **Screenshot terminal Flutter** (output dari flutter run)
3. **Screenshot tampilan error** di app
4. **Copy-paste error message** lengkap dari console

Dengan informasi ini, saya bisa diagnosa masalah yang spesifik dan kasih solusi yang tepat!

---

## 🎯 QUICK FIX COMMANDS:

```bash
# Quick fix - jalankan ini:
flutter clean && flutter pub get && flutter run -d chrome --web-renderer html
```

Tunggu sampai compile selesai, lalu refresh browser (F5).

---

**Maaf untuk error ini! Mari kita fix bersama.** 🔧

**Silakan jalankan perintah di atas dan kirim screenshot error jika masih bermasalah!**
