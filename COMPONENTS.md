# Component Documentation

## TopAppBar

Widget yang menampilkan navigasi di bagian atas layar dengan profile picture dan notifikasi.

### Usage
```dart
import 'package:my_manage/widgets/index.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: const TopAppBar(),
      ),
      body: Container(),
    );
  }
}
```

### Features
- Circular profile avatar
- User greeting text
- Notification icon button
- Responsive design

---

## BalanceCard

Hero card yang menampilkan total balance dengan dekorasi dan mascot character.

### Usage
```dart
const BalanceCard()
```

### Customizable Properties
```dart
class BalanceCard extends StatelessWidget {
  // Dapat diubah untuk menampilkan nilai yang berbeda
  // Saat ini hardcoded, bisa di-refactor untuk menerima parameter:
  // - final double totalBalance;
  // - final String mascotMessage;
}
```

### Features
- Background sparkles decoration
- Mascot avatar dengan speech bubble
- Large balance display
- Motivational message
- Smooth shadows dan effects

---

## StatsGrid

Grid component menampilkan statistik keuangan dalam layout bento style.

### Usage
```dart
const StatsGrid()
```

### Components Dalam StatsGrid

1. **Daily Expense Card**
   - Icon: Shopping bag
   - Warna: Secondary container
   - Menampilkan: Pengeluaran hari ini

2. **Budget Left Card**
   - Icon: Wallet
   - Warna: Primary container
   - Menampilkan: Sisa budget

3. **Income Card** (Full Width)
   - Icon: Payments
   - Warna: Tertiary container
   - Menampilkan: Income dengan trend indicator

### Customization
Setiap card bisa di-customize dengan mengganti nilai di dalam widget:
```dart
// Contoh: Ubah Daily Expense
'\$124.50' -> '$YOUR_VALUE'
```

---

## SpendingTrendsChart

Interactive bar chart menampilkan trend pengeluaran 7 hari terakhir.

### Usage
```dart
const SpendingTrendsChart()
```

### Features
- 7-bar chart (M-S)
- Hover effects pada bar
- Responsive height based on data
- Day labels di bawah chart
- Primary color untuk bar tertinggi

### Data Structure
```dart
final List<Map<String, dynamic>> data = [
  {'day': 'M', 'height': 0.30},  // 30% dari max height
  {'day': 'T', 'height': 0.60},
  {'day': 'W', 'height': 1.0},   // Tertinggi
  // ... dst
];
```

### Customization
Ubah data list untuk menampilkan data real dari backend:
```dart
// Saat ini hardcoded, bisa menerima parameter:
// final List<Map<String, dynamic>> data;
```

---

## BottomNavBar

Bottom navigation dengan 5 tabs dan active state indication.

### Usage
```dart
BottomNavBar(
  currentIndex: 0,
  onItemSelected: (index) {
    // Handle navigation
    print('Selected tab: $index');
  },
)
```

### Parameters
| Parameter | Type | Description |
|-----------|------|-------------|
| `currentIndex` | int | Index tab yang sedang aktif (default: 0) |
| `onItemSelected` | Function(int) | Callback ketika tab dipilih |

### Tabs (0-4)
0. Dashboard
1. History
2. Add
3. Reports
4. Profile

### Features
- Smooth animations
- Active state dengan background color
- Responsive text sizing
- Material Design 3 style

---

## QuickAddFAB

Floating Action Button untuk quick add action.

### Usage
```dart
Scaffold(
  floatingActionButton: QuickAddFAB(
    onPressed: () {
      print('Add button pressed!');
    },
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
)
```

### Parameters
| Parameter | Type | Description |
|-----------|------|-------------|
| `onPressed` | VoidCallback | Function dipanggil saat button ditekan |

---

## DashboardPage

Main page yang menggabungkan semua components.

### Usage
```dart
import 'package:my_manage/pages/index.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const DashboardPage(),
    );
  }
}
```

### Layout Structure
```
┌─────────────────────┐
│    TopAppBar        │
├─────────────────────┤
│   BalanceCard       │
├─────────────────────┤
│    StatsGrid        │
├─────────────────────┤
│ SpendingTrendsChart │
├─────────────────────┤
│   QuickAddFAB →     │
│                     │
└─────────────────────┘
│   BottomNavBar      │
└─────────────────────┘
```

### Navigation Handling
```dart
void _handleNavigation(int index) {
  switch (index) {
    case 0:
      // Navigate to Dashboard
      break;
    case 1:
      // Navigate to History
      break;
    // ... dst
  }
}
```

---

## Color Constants (AppColors)

Semua warna tersedia di `constants/colors.dart`:

```dart
import 'package:my_manage/constants/colors.dart';

// Usage
Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.onPrimary),
  ),
)
```

### Main Colors
- **Primary**: `#2c5f87` - Brand color
- **Secondary**: `#794f61` - Accent color
- **Tertiary**: `#605e20` - Additional accent
- **Background**: `#f4f6ff` - App background

### Surface Colors
- `surfaceContainerLow` - Low contrast cards
- `surfaceContainerHigh` - High contrast cards
- `surfaceContainerLowest` - White/light backgrounds

---

## Tips & Best Practices

1. **Reusability**: Ketika membuat component baru, buat sefleksibel mungkin dengan parameters
2. **Consistency**: Gunakan `AppColors` untuk konsistensi warna
3. **Performance**: Gunakan `const` constructor ketika memungkinkan
4. **Accessibility**: Pastikan contrast ratio dan text size sesuai Material Design 3
5. **Testing**: Setiap component bisa di-test secara terpisah

---

## Common Customizations

### Mengubah Balance Amount
Buka `widgets/balance_card.dart` dan ubah:
```dart
'\$12,450.00' -> '\$YOUR_AMOUNT'
```

### Mengubah Daily Stats
Buka `widgets/stats_grid.dart` dan ubah:
```dart
'\$124.50' -> '\$YOUR_AMOUNT'
```

### Mengubah Chart Data
Buka `widgets/spending_trends_chart.dart` dan ubah data list.

---

## Troubleshooting

**Q: Image tidak muncul?**
A: Images di-load dari network. Pastikan internet connection aktif atau ganti dengan local assets.

**Q: Colors tidak sesuai?**
A: Pastikan import `AppColors` dengan benar dari `constants/colors.dart`

**Q: Navigation tidak bekerja?**
A: Implement navigation logic di `_handleNavigation()` method di `DashboardPage`
