# 🤖 ManKu WhatsApp Bot - Quick Reference

## 📱 Command Prefix

Semua perintah HARUS diawali dengan:
- `/manku` (prefix utama)
- `!m` (prefix alternatif)

---

## 💬 Commands

### 💰 Input Transaksi (Default)
Langsung kirim deskripsi transaksi:

```
/manku beli kopi 25000
/manku terima gaji 5 juta
/manku bayar listrik 500rb
!m beli buku 150ribu
!m dapat bonus 2jt
```

**Format yang didukung:**
- 25000, 25rb, 25ribu, 25k → Rp 25,000
- 5juta, 5jt, 5m → Rp 5,000,000

---

### 📊 Cek Saldo

```
/manku saldo
!m balance
```

**Response:**
- Total Balance
- Total Income
- Total Expense

---

### 📈 Report Bulanan

```
/manku report
!m laporan
```

**Response:**
- Pemasukan bulan ini
- Pengeluaran bulan ini
- Net (Income - Expense)
- Top 5 kategori pengeluaran

---

### 💼 Cek Investasi

```
/manku investasi
!m investment
```

**Response:**
- Total Investment
- Current Value
- Profit/Loss (Rp & %)
- Breakdown: Crypto & Saham

---

### ❓ Bantuan

```
/manku help
!m ?
```

**Response:**
- Daftar semua command
- Cara penggunaan

---

## ⚠️ Penting!

1. **Whitelist**: Hanya nomor terdaftar yang direspon
2. **Prefix Wajib**: Pesan tanpa prefix diabaikan
3. **Rate Limit**: Max 10 pesan per menit
4. **No Groups**: Bot tidak merespon di grup

---

## ✅ Quick Test

Test bot dengan command berikut:

```
1. /manku help
   → Harus dapat daftar command

2. /manku saldo
   → Harus dapat info saldo

3. /manku beli kopi 25000
   → Harus dapat konfirmasi transaksi
```

---

## 🚨 Troubleshooting

**Bot tidak merespon?**
1. Cek apakah nomor ada di whitelist
2. Pastikan pakai prefix (/manku atau !m)
3. Cek apakah nomor sudah terdaftar di admin

**Error "User not found"?**
- Daftarkan nomor WA di Django Admin → WhatsApp Users

**Rate limit exceeded?**
- Tunggu 1 menit

---

## 📞 Admin Contact

Untuk mendaftarkan nomor WA baru, hubungi admin.

---

**Happy budgeting! 💰**
