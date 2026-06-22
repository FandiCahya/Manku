# 🚀 JALANKAN ULANG APLIKASI

## ⚠️ PENTING: HOT RELOAD TIDAK CUKUP!

Dari screenshot Anda, saya lihat tab Investment **TIDAK MUNCUL**. Ini karena perubahan struktur widget memerlukan **FULL RESTART**.

---

## ✅ LANGKAH WAJIB:

### 1. STOP aplikasi yang sedang running
- Tekan **Ctrl+C** di terminal
- Atau tutup tab browser

### 2. Clean build
```bash
flutter clean
flutter pub get
```

### 3. Run ulang aplikasi
```bash
flutter run -d chrome
```

### 4. Tunggu sampai selesai compile
```
✓ Built build\web\main.dart.js
Launching lib\main.dart on Chrome in debug mode...
```

### 5. Refresh browser (F5)

---

## 🎯 SETELAH RUN ULANG:

Anda HARUS melihat:

1. **Buka halaman Reports** (bottom nav, menu ke-4)
2. **Lihat di ATAS halaman** - seharusnya ada **TAB BAR** dengan 2 tab:

```
┌─────────────────────────────────────┐
│ ┌───────────────┬───────────────┐   │  ← INI HARUS MUNCUL!
│ │ Transactions  │ Investments   │   │
│ └───────────────┴───────────────┘   │
│                                     │
│  (Content di sini)                  │
└─────────────────────────────────────┘
```

3. **Default** akan menampilkan tab "Transactions" (Spending Report)
4. **Tap "Investments"** untuk lihat investment tab

---

## 🔍 VERIFICATION:

Setelah run ulang, cek:

### ✅ Tab Bar Muncul?
- [ ] YES → Lanjut tap "Investments"
- [ ] NO → Kirim screenshot + console error (F12)

### ✅ Tab "Investments" bisa di-tap?
- [ ] YES → Investment tab terbuka
- [ ] NO → Kirim screenshot error

### ✅ Investment tab menampilkan sesuatu?
- [ ] Empty state "No Investments Yet" → NORMAL
- [ ] Portfolio summary + investments → BAGUS!
- [ ] Error message → Kirim screenshot

---

## 💡 MENGAPA PERLU RESTART?

**Hot Reload** (tekan `r` di terminal) hanya update widget kecil.  
**Hot Restart** (tekan `R` di terminal) restart state tapi tidak reload semua.  
**Full Restart** (stop + run ulang) reload SEMUA termasuk routing dan providers.

Perubahan seperti:
- Menambah tab baru
- Mengubah structure HomePage
- Menambah provider (InvestmentCubit)

Memerlukan **FULL RESTART** agar berfungsi!

---

## 🐛 JIKA MASIH TIDAK MUNCUL:

### Check 1: Pastikan semua file investment ada
```bash
ls lib\features\investment\presentation\pages\investment_tab.dart
ls lib\features\investment\presentation\widgets\portfolio_summary_card.dart
ls lib\features\investment\presentation\widgets\investment_card.dart
```

Semua harus ada (tidak error "file not found")

### Check 2: Lihat console error
1. Buka browser DevTools (F12)
2. Ke tab "Console"
3. Lihat apakah ada error merah
4. Screenshot dan kirim ke saya

### Check 3: Cek terminal output
Saat run `flutter run -d chrome`, lihat apakah ada error compilation.

---

## 📋 PERINTAH LENGKAP:

Copy-paste perintah ini ke terminal:

```bash
# 1. Stop aplikasi (Ctrl+C)

# 2. Clean
flutter clean

# 3. Get dependencies
flutter pub get

# 4. Run ulang
flutter run -d chrome

# 5. Tunggu sampai selesai
# 6. Refresh browser (F5)
# 7. Buka Reports
# 8. Lihat tab bar di atas
```

---

## ✅ EXPECTED RESULT:

Setelah run ulang, Anda HARUS lihat ini di halaman Reports:

```
SEBELUM (Screenshot Anda):
┌─────────────────────────────────────┐
│  Spending Report                    │  ← Tidak ada tab bar
│  (Chart)                            │
│                                     │
│  Category Breakdown                 │
│  All | Income | Expense             │
└─────────────────────────────────────┘

SESUDAH (Expected):
┌─────────────────────────────────────┐
│ ┌───────────────┬───────────────┐   │  ← TAB BAR MUNCUL!
│ │ Transactions  │ Investments   │   │
│ └───────────────┴───────────────┘   │
│                                     │
│  Spending Report                    │
│  (Chart)                            │
│                                     │
│  Category Breakdown                 │
└─────────────────────────────────────┘
```

---

## 📞 JIKA MASIH BERMASALAH:

Kirimkan ke saya:

1. **Screenshot** halaman Reports setelah run ulang
2. **Console log** dari browser (F12 → Console)
3. **Terminal output** dari `flutter run`
4. **File verification**:
   ```bash
   flutter analyze lib/pages/home_page.dart
   ```

---

**SILAKAN RUN ULANG SEKARANG!** 🚀

```bash
flutter clean && flutter pub get && flutter run -d chrome
```
