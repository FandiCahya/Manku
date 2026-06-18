# Savings Goals - Concept Design

## Problem Statement
Current system: **Budget Bulanan** (reset setiap bulan)
- Budget untuk kategori pengeluaran (Food, Transport, etc.)
- Reset setiap bulan
- Fokus: kontrol pengeluaran

Needed system: **Savings Goals** (tujuan tabungan jangka panjang)
- Goals untuk tabungan (Investasi, Beli Rumah, Liburan, etc.)
- Tidak reset bulanan
- Akumulatif sampai target tercapai
- Fokus: mencapai tujuan finansial

## Solution Design

### Concept A: Dual System (Recommended)
Keep both Budget & Savings Goals as separate features

```
Profile Menu:
├─ 💰 Pengelolaan Keuangan
│  ├─ Tab 1: Budget Bulanan (existing)
│  └─ Tab 2: Savings Goals (new)
│
└─ Other settings...
```

**Benefits:**
- Keep existing budget system intact
- Add new savings goals feature
- Users can use both

### Concept B: Replace Budget with Savings Goals
Replace current budget system entirely

```
Profile Menu:
└─ 🎯 Savings Goals (replaces Pengelolaan Keuangan)
   ├─ Goals List (Investasi, Rumah, dll)
   └─ Add/Edit/Delete Goals
```

**Benefits:**
- Simpler architecture
- Focus on one feature
- Cleaner UX

### Concept C: Rename & Repurpose
Repurpose current budget system for savings goals

```
Profile Menu:
└─ 🎯 Tujuan Keuangan
   ├─ Goals List (not reset monthly)
   ├─ Progress tracking
   └─ Target dates
```

**Benefits:**
- Minimal code changes
- Reuse existing UI/UX
- Quick implementation

## Recommended: Concept A (Dual System)

### UI Structure

```
┌────────────────────────────────────────┐
│ Pengelolaan Keuangan              <    │
├────────────────────────────────────────┤
│  Budget Bulanan  │  Savings Goals  │   │ ← Tabs
├────────────────────────────────────────┤
│                                        │
│  TAB 1: Budget Bulanan (existing)     │
│  ┌──────────────────────────────────┐ │
│  │ TOTAL BUDGET: Rp 5,000,000       │ │
│  │ Spent: Rp 3,200,000 (64%)        │ │
│  └──────────────────────────────────┘ │
│                                        │
│  Budget per Kategori:                 │
│  ◉ Food: 1,500,000 (80%)              │
│  ◉ Transport: 800,000 (60%)           │
│                                        │
│  [Resets every month]                 │
│                                        │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ Pengelolaan Keuangan              <    │
├────────────────────────────────────────┤
│  Budget Bulanan  │  Savings Goals  │   │ ← Tabs
├────────────────────────────────────────┤
│                                        │
│  TAB 2: Savings Goals (new)           │
│  ┌──────────────────────────────────┐ │
│  │ TOTAL SAVINGS: Rp 15,000,000     │ │
│  │ Target: Rp 50,000,000 (30%)      │ │
│  └──────────────────────────────────┘ │
│                                        │
│  Tujuan Tabungan:                     │
│  🏠 Beli Rumah: 15M/100M (15%)        │
│     Target: Dec 2025                  │
│                                        │
│  📈 Investasi: 5M/20M (25%)           │
│     Target: Jun 2026                  │
│                                        │
│  🏖️ Liburan: 3M/5M (60%)              │
│     Target: Aug 2024                  │
│                                        │
│  [Never resets - accumulative]        │
│                                        │
└────────────────────────────────────────┘
```

## Data Model

### Current: Budget (Monthly)
```json
{
  "id": "uuid",
  "category_name": "Food",
  "budget_amount": 1500000,
  "spent_amount": 1200000,
  "month_year": "2024-01",
  "resets": true
}
```

### New: Savings Goal (Long-term)
```json
{
  "id": "uuid",
  "goal_name": "Beli Rumah",
  "goal_icon": "🏠",
  "target_amount": 100000000,
  "current_amount": 15000000,
  "target_date": "2025-12-31",
  "created_date": "2024-01-01",
  "status": "in_progress",
  "priority": "high",
  "notes": "DP rumah di BSD",
  "resets": false
}
```

## Features Comparison

| Feature | Budget Bulanan | Savings Goals |
|---------|---------------|---------------|
| Type | Expense control | Savings target |
| Duration | Monthly | Long-term |
| Reset | Yes (every month) | No (accumulative) |
| Target | Control spending | Reach savings goal |
| Categories | Food, Transport, etc | House, Investment, etc |
| Progress | % spent of budget | % saved of target |
| Deadline | End of month | Custom date |
| Add funds | N/A | Manual add |
| Withdraw | N/A | Manual withdraw |

## API Endpoints (New)

### 1. Get All Savings Goals
```
GET /api/savings-goals/

Response:
{
  "total_saved": 23000000,
  "total_target": 125000000,
  "percentage": 18.4,
  "goals": [
    {
      "id": "uuid",
      "goal_name": "Beli Rumah",
      "goal_icon": "🏠",
      "target_amount": 100000000,
      "current_amount": 15000000,
      "percentage": 15,
      "target_date": "2025-12-31",
      "days_left": 365,
      "status": "in_progress",
      "priority": "high"
    },
    ...
  ]
}
```

### 2. Create Savings Goal
```
POST /api/savings-goals/

Body:
{
  "goal_name": "Beli Rumah",
  "goal_icon": "🏠",
  "target_amount": 100000000,
  "target_date": "2025-12-31",
  "initial_amount": 0,
  "priority": "high",
  "notes": "DP rumah di BSD"
}
```

### 3. Add Funds to Goal
```
POST /api/savings-goals/{id}/add-funds/

Body:
{
  "amount": 1000000,
  "note": "Gaji bulan Januari"
}
```

### 4. Withdraw from Goal
```
POST /api/savings-goals/{id}/withdraw/

Body:
{
  "amount": 500000,
  "reason": "Emergency"
}
```

### 5. Update Goal
```
PUT /api/savings-goals/{id}/

Body:
{
  "goal_name": "Beli Rumah",
  "target_amount": 120000000,
  "target_date": "2026-12-31"
}
```

### 6. Delete Goal
```
DELETE /api/savings-goals/{id}/
```

### 7. Get Goal History
```
GET /api/savings-goals/{id}/history/

Response:
{
  "transactions": [
    {
      "id": "uuid",
      "type": "add",
      "amount": 1000000,
      "note": "Gaji bulan Januari",
      "date": "2024-01-15",
      "balance_after": 15000000
    },
    ...
  ]
}
```

## UI Components

### 1. Savings Goal Card
```dart
┌────────────────────────────────────┐
│ 🏠 Beli Rumah             [Edit] │
├────────────────────────────────────┤
│ Rp 15,000,000 / Rp 100,000,000    │
│ ████░░░░░░░░░░░░░░ 15%            │
│                                    │
│ 🎯 Target: 31 Des 2025             │
│ ⏰ 365 hari lagi                   │
│                                    │
│ [+ Add Funds]  [- Withdraw]       │
└────────────────────────────────────┘
```

### 2. Add/Edit Goal Modal
```dart
┌────────────────────────────────────┐
│ Tambah Tujuan Tabungan        ✕   │
├────────────────────────────────────┤
│                                    │
│ Nama Tujuan:                       │
│ [Beli Rumah________________]       │
│                                    │
│ Icon:                              │
│ [🏠] [📈] [🏖️] [🚗] [📱] [💍]      │
│                                    │
│ Target Nominal:                    │
│ Rp [100,000,000____________]       │
│                                    │
│ Target Tanggal:                    │
│ [31 Des 2025_____________] 📅      │
│                                    │
│ Dana Awal (Opsional):              │
│ Rp [0______________________]       │
│                                    │
│ Prioritas:                         │
│ ◉ Tinggi  ○ Sedang  ○ Rendah     │
│                                    │
│ Catatan (Opsional):                │
│ [DP rumah di BSD________]          │
│                                    │
│         [Simpan]                   │
│                                    │
└────────────────────────────────────┘
```

### 3. Add Funds Modal
```dart
┌────────────────────────────────────┐
│ Tambah Dana - Beli Rumah      ✕   │
├────────────────────────────────────┤
│                                    │
│ Saldo Saat Ini:                    │
│ Rp 15,000,000                      │
│                                    │
│ Jumlah yang Ditambahkan:           │
│ Rp [1,000,000____________]         │
│                                    │
│ Catatan:                           │
│ [Gaji bulan Januari_____]          │
│                                    │
│ Saldo Setelah:                     │
│ Rp 16,000,000                      │
│                                    │
│         [Tambah Dana]              │
│                                    │
└────────────────────────────────────┘
```

## Implementation Steps

### Phase 1: Add Tabbed Interface
1. Create TabBar in budget_goals_page.dart
2. Tab 1: Existing budget (keep as is)
3. Tab 2: New savings goals (placeholder)

### Phase 2: Create Savings Goals Models
1. Create savings_goal_models.dart
2. Define SavingsGoal, SavingsGoalSummary
3. Add API response models

### Phase 3: Create Savings Goals UI
1. Create savings_goals_tab.dart
2. Create savings_goal_card.dart
3. Create add_goal_sheet.dart
4. Create add_funds_sheet.dart
5. Create withdraw_sheet.dart

### Phase 4: State Management
1. Create savings_goals_cubit.dart
2. Add states (loading, loaded, error)
3. Handle CRUD operations

### Phase 5: API Integration
1. Create savings_goals_repository.dart
2. Implement all API endpoints
3. Handle offline/sync

### Phase 6: Polish & Test
1. Add animations
2. Add empty states
3. Add error handling
4. Test all flows

## Example Goals

### Common Savings Goals:
- 🏠 **Beli Rumah** (100M - 500M)
- 🚗 **Beli Mobil** (200M - 500M)
- 📈 **Investasi** (10M - 50M)
- 🏖️ **Liburan** (5M - 20M)
- 💍 **Dana Nikah** (50M - 200M)
- 👶 **Dana Pendidikan Anak** (100M - 500M)
- 🏥 **Dana Darurat** (20M - 50M)
- 📱 **Gadget Baru** (5M - 15M)
- 🎓 **Kuliah S2** (50M - 200M)
- 🌴 **Pensiun** (500M - 2B)

## Migration Strategy

### Option 1: Soft Launch
- Add new feature alongside existing
- Users can explore gradually
- No data migration needed

### Option 2: Hard Migration
- Offer to convert existing budgets to goals
- One-time migration
- Keep history

### Option 3: Keep Both
- Budget for monthly expense control
- Goals for long-term savings
- Best of both worlds ⭐

## Conclusion

**Recommendation: Implement Concept A (Dual System)**

Reasons:
1. ✅ Keeps existing functionality
2. ✅ Adds powerful new feature
3. ✅ Users can use both
4. ✅ No breaking changes
5. ✅ Flexible for different use cases

Next steps:
1. Approve concept design
2. Design API endpoints (backend)
3. Implement Phase 1 (tabs)
4. Implement Phase 2-6 incrementally
5. Launch & gather feedback
