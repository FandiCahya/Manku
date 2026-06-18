# 📊 Penjelasan: Data TIDAK Akan Reset Saat Ganti Bulan

## ✅ Konfirmasi: Data Aman & Persisten

**Data transaksi, budget, dan savings Anda TIDAK AKAN hilang atau reset saat ganti bulan.**

Semua data tersimpan **permanen** di database dan hanya **tampilan dashboard** yang berubah sesuai periode yang dipilih.

---

## 🗄️ Struktur Data & Persistensi

### 1. **Transaction (Transaksi)**

**Model**:
```python
class Transaction(models.Model):
    id = UUIDField  # ID unik permanen
    user = ForeignKey  # Terhubung ke user
    category = ForeignKey  # Kategori transaksi
    amount = Decimal  # Nominal
    transaction_date = DateTime  # Tanggal transaksi (PENTING!)
    description = Text
    input_source = CharField  # manual/ai_image/ai_voice
```

**Karakteristik**:
- ✅ Tersimpan permanen di database
- ✅ Tidak ada auto-delete
- ✅ Tidak ada expiry date
- ✅ `transaction_date` menyimpan kapan transaksi terjadi
- ✅ Data historis tetap utuh

**Contoh**:
```
Transaction 1: Rp 50.000, 2026-01-15  ← Tersimpan selamanya
Transaction 2: Rp 75.000, 2026-02-10  ← Tersimpan selamanya
Transaction 3: Rp 100.000, 2026-03-05 ← Tersimpan selamanya
```

---

### 2. **Budget (Anggaran)**

**Model**:
```python
class Budget(models.Model):
    id = UUIDField
    user = ForeignKey
    category = ForeignKey
    amount = Decimal
    month_year = DateField  # Format: YYYY-MM-01
```

**Karakteristik**:
- ✅ Tersimpan per bulan (month_year)
- ✅ Setiap bulan bisa punya budget berbeda
- ✅ Budget bulan lalu tetap tersimpan
- ✅ Tidak ada auto-delete

**Cara Kerja**:
```
Budget Januari 2026:  Rp 5.000.000  ← Tersimpan
Budget Februari 2026: Rp 6.000.000  ← Tersimpan
Budget Maret 2026:    Rp 5.500.000  ← Tersimpan
```

User bisa:
- Set budget berbeda setiap bulan
- Lihat budget history
- Update budget bulan tertentu

---

### 3. **SavingsGoal (Target Tabungan)**

**Model**:
```python
class SavingsGoal(models.Model):
    id = UUIDField
    user = ForeignKey
    name = CharField  # Nama tabungan
    target_amount = Decimal  # Target
    current_amount = Decimal  # Uang yang sudah terkumpul
    deadline = DateField  # Target tanggal selesai
```

**Karakteristik**:
- ✅ Tersimpan permanen
- ✅ `current_amount` akumulatif
- ✅ Tidak reset otomatis
- ✅ User manual add/withdraw funds

**Contoh**:
```
Tabungan "Liburan Bali":
- Target: Rp 10.000.000
- Terkumpul: Rp 7.500.000
- Deadline: 2026-12-31

Januari: +Rp 2.000.000 → Total: Rp 2.000.000
Februari: +Rp 3.000.000 → Total: Rp 5.000.000
Maret: +Rp 2.500.000 → Total: Rp 7.500.000
```

---

## 📊 Dashboard & Perhitungan

### Endpoint: `/api/finance/transactions/dashboard-summary/`

**Logika Perhitungan**:

1. **Total Balance** (Saldo Total)
   ```python
   # Menghitung SEMUA transaksi dari awal
   income_total = SUM(semua_transaksi_income)
   expense_total = SUM(semua_transaksi_expense)
   total_balance = income_total - expense_total
   ```
   ✅ **AKUMULATIF DARI SEMUA WAKTU**

2. **Daily Expense** (Pengeluaran Hari Ini)
   ```python
   # Hanya transaksi hari ini
   daily_expense = SUM(transaksi WHERE date = today)
   ```
   ✅ Filter berdasarkan tanggal

3. **Monthly Income** (Pemasukan Bulan Ini)
   ```python
   # Transaksi bulan berjalan
   first_of_month = today.replace(day=1)
   monthly_income = SUM(transaksi WHERE date >= first_of_month)
   ```
   ✅ Filter >= awal bulan ini

4. **Monthly Expense** (Pengeluaran Bulan Ini)
   ```python
   # Transaksi bulan berjalan
   monthly_expense = SUM(transaksi WHERE date >= first_of_month)
   ```
   ✅ Filter >= awal bulan ini

5. **Budget Left** (Sisa Budget)
   ```python
   # Budget bulan ini - pengeluaran bulan ini
   monthly_budget = Budget WHERE month_year = first_of_month
   budget_left = monthly_budget - monthly_expense
   ```
   ✅ Budget spesifik bulan ini

6. **Spending Trends** (7 hari terakhir)
   ```python
   # Agregasi per hari
   for last_7_days:
       day_expense = SUM(transaksi WHERE date = target_date)
   ```
   ✅ Rolling 7 days

---

## 🔄 Apa yang Terjadi Saat Ganti Bulan?

### Contoh: Dari Januari → Februari 2026

**Yang BERUBAH** ✅:
1. Dashboard menampilkan data bulan Februari
2. "Monthly Income" menghitung dari 1 Feb
3. "Monthly Expense" menghitung dari 1 Feb
4. "Budget Left" menggunakan budget Februari (jika ada)

**Yang TETAP** ✅:
1. Total Balance tetap akumulatif (Jan + Feb + ...)
2. Transaksi Januari tetap tersimpan di database
3. Budget Januari tetap tersimpan
4. Savings tetap akumulatif

**Ilustrasi**:

```
=== JANUARI 2026 ===
Total Balance: Rp 10.000.000
Monthly Income: Rp 5.000.000
Monthly Expense: Rp 3.000.000
Transaksi: 50 transaksi tersimpan

       ⬇️ GANTI BULAN ⬇️

=== FEBRUARI 2026 ===
Total Balance: Rp 12.000.000  ← Akumulatif (Jan + Feb)
Monthly Income: Rp 4.000.000  ← Hanya Februari
Monthly Expense: Rp 2.000.000 ← Hanya Februari
Transaksi Januari: Masih ada (bisa dilihat di history)
Transaksi Februari: 30 transaksi baru
Total Transaksi: 80 transaksi (50 + 30)
```

---

## 📈 Melihat Data Historical

### 1. Transaction History

**Endpoint**: `/api/finance/transactions/history/`

**Response**:
```json
{
  "total_transactions": 150,
  "groups": [
    {
      "date_label": "TODAY, 12 JUN",
      "date": "2026-06-12",
      "transactions": [...]
    },
    {
      "date_label": "WEDNESDAY, 05 FEB 2026",
      "date": "2026-02-05",
      "transactions": [...]
    },
    {
      "date_label": "MONDAY, 15 JAN 2026",
      "date": "2026-01-15",
      "transactions": [...]
    }
  ]
}
```

✅ Menampilkan **SEMUA transaksi** dari semua waktu, dikelompokkan per tanggal

---

### 2. Report Summary (6 Bulan)

**Endpoint**: `/api/finance/transactions/report-summary/`

**Response**:
```json
{
  "total_spending": 5000000,  // Bulan ini
  "category_breakdown": [...],  // Bulan ini
  "performance_six_months": [
    {"month": "Jan", "year": 2026, "amount": 3000000},
    {"month": "Feb", "year": 2026, "amount": 3500000},
    {"month": "Mar", "year": 2026, "amount": 4000000},
    {"month": "Apr", "year": 2026, "amount": 3200000},
    {"month": "May", "year": 2026, "amount": 4500000},
    {"month": "Jun", "year": 2026, "amount": 5000000}
  ]
}
```

✅ Menampilkan data **6 bulan terakhir**

---

## 🛡️ Garantees (Jaminan)

### ✅ Data Tidak Akan Hilang Karena:

1. **Tidak Ada Auto-Delete**
   - Tidak ada cron job yang menghapus data lama
   - Tidak ada trigger database untuk delete
   - Tidak ada cascade delete yang tidak disengaja

2. **Tidak Ada Expiry**
   - Model tidak punya field `expired_at`
   - Tidak ada TTL (Time To Live)
   - Data tersimpan selamanya

3. **Foreign Key Protection**
   - `on_delete=CASCADE` hanya jika user dihapus
   - `on_delete=SET_NULL` untuk kategori (transaksi tetap ada)

4. **Database Integrity**
   - UUID untuk unique ID
   - Timestamps untuk tracking
   - Constraints untuk data consistency

---

## 🔍 Cara Memverifikasi Data Tidak Hilang

### Method 1: Check via Django Admin

1. Login ke Django Admin: `http://127.0.0.1:8000/admin/`
2. Buka **Finance > Transactions**
3. Lihat semua transaksi dengan tanggal kapanpun

---

### Method 2: Check via API

**Get All Transactions**:
```bash
curl -X GET http://127.0.0.1:8000/api/finance/transactions/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response**: Semua transaksi dari awal waktu

---

### Method 3: Check via Database

```bash
# Masuk ke Django shell
python manage.py shell
```

```python
from finance.models import Transaction
from django.contrib.auth.models import User

# Cek user
user = User.objects.get(email='your-email@example.com')

# Hitung total transaksi
total = Transaction.objects.filter(user=user).count()
print(f"Total transaksi: {total}")

# Lihat transaksi bulan Januari 2026
from datetime import date
jan_transactions = Transaction.objects.filter(
    user=user,
    transaction_date__year=2026,
    transaction_date__month=1
).count()
print(f"Transaksi Januari 2026: {jan_transactions}")

# Lihat transaksi bulan Februari 2026
feb_transactions = Transaction.objects.filter(
    user=user,
    transaction_date__year=2026,
    transaction_date__month=2
).count()
print(f"Transaksi Februari 2026: {feb_transactions}")
```

---

## 💡 Best Practices untuk User

### 1. Backup Regular (Optional)
Meskipun data tidak akan hilang, backup tetap direkomendasikan:
- Export data via API
- Database backup berkala
- Sync ke Google Sheets (fitur `is_synced`)

### 2. Budget Planning
- Set budget baru setiap awal bulan
- Review budget bulan lalu
- Adjust berdasarkan spending patterns

### 3. Savings Tracking
- Update savings goal progress
- Review di akhir bulan
- Celebrate milestones! 🎉

---

## 🚨 Kapan Data Bisa Hilang?

### Skenario Risiko:

1. **User Dihapus**
   ```python
   User.delete()  # CASCADE → semua data user ikut terhapus
   ```
   ⚠️ **Solusi**: Jangan delete user, gunakan `is_active=False`

2. **Manual Delete**
   ```python
   Transaction.objects.filter(user=user).delete()
   ```
   ⚠️ **Solusi**: API tidak menyediakan bulk delete

3. **Database Corruption**
   ⚠️ **Solusi**: Regular backup

4. **Server Data Loss**
   ⚠️ **Solusi**: Cloud backup, redundancy

---

## 📝 Summary

| Aspek | Status | Penjelasan |
|-------|--------|------------|
| Data Transaksi | ✅ AMAN | Tersimpan permanen, tidak reset |
| Data Budget | ✅ AMAN | Per bulan, semua tersimpan |
| Data Savings | ✅ AMAN | Akumulatif, tidak reset |
| Total Balance | ✅ AKUMULATIF | Dari semua transaksi |
| Monthly Data | ✅ DINAMIS | Filter per bulan berjalan |
| Historical Data | ✅ TERSEDIA | Bisa diakses kapan saja |

---

## 🎯 Kesimpulan

**Data Anda 100% AMAN dan TIDAK AKAN RESET saat ganti bulan!**

Yang berubah hanya:
- ✅ Tampilan dashboard (filter bulan berjalan)
- ✅ Monthly metrics (reset per awal bulan)
- ✅ Budget reference (budget bulan ini)

Yang tetap:
- ✅ Semua transaksi historis
- ✅ Total balance akumulatif
- ✅ Semua budget history
- ✅ Savings progress

---

**🎉 Aplikasi ManKu dirancang untuk menyimpan data finansial Anda dengan aman untuk jangka panjang!**

*Dokumentasi dibuat: 12 Juni 2026*
