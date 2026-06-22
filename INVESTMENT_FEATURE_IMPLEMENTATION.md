# 💼 Investment Portfolio - Implementation Guide

## ✅ Yang Sudah Dibuat

### 1. API Endpoints (api_config.dart)
✅ Semua endpoint investment sudah ditambahkan:
- `/api/finance/investments/` - List & Create
- `/api/finance/investments/{id}/` - Detail, Update, Delete
- `/api/finance/investments/portfolio-summary/` - Portfolio summary
- `/api/finance/investments/{id}/transactions/` - Transaction history
- `/api/finance/investments/{id}/add-transaction/` - Add buy/sell
- `/api/finance/investments/price/` - Real-time prices
- `/api/finance/investments/search-crypto/` - Search crypto
- `/api/finance/investments/refresh-prices/` - Refresh prices

### 2. Domain Models (investment_models.dart)
✅ Model lengkap untuk:
- `Investment` - Asset investasi (crypto/stock)
- `PortfolioSummary` - Ringkasan portfolio
- `PortfolioByType` - Breakdown per jenis asset
- `AssetTypeInfo` - Info per tipe (crypto/stock)
- `InvestmentTransaction` - Transaksi buy/sell
- `PriceData` - Data harga real-time
- `CryptoSearchResult` - Hasil pencarian crypto

### 3. Repository (investment_repository.dart)
✅ Semua method API sudah diimplementasi:
- `fetchInvestments()` - Get all investments
- `fetchPortfolioSummary()` - Get portfolio summary
- `createInvestment()` - Tambah investment baru
- `fetchInvestmentDetail()` - Get detail investment
- `updateInvestment()` - Update investment
- `deleteInvestment()` - Delete investment
- `addTransaction()` - Tambah transaksi buy/sell
- `fetchTransactions()` - Get transaction history
- `fetchPrice()` - Get real-time price
- `searchCrypto()` - Search cryptocurrency
- `refreshPrices()` - Refresh all prices

## 🚧 Yang Perlu Dibuat Selanjutnya

### 4. Cubit/State Management
Buat file: `lib/features/investment/presentation/cubit/investment_cubit.dart`

### 5. UI Pages
- `investment_page.dart` - Halaman utama portfolio
- `add_investment_page.dart` - Form tambah investment
- `investment_detail_page.dart` - Detail & transaksi
- `add_transaction_page.dart` - Form buy/sell

### 6. Widgets
- `investment_card.dart` - Card untuk list investment
- `portfolio_summary_card.dart` - Card ringkasan portfolio
- `price_chart.dart` - Chart harga (optional)
- `transaction_list.dart` - List transaksi

## 📱 Struktur Folder

```
lib/features/investment/
├── domain/
│   └── investment_models.dart ✅
├── data/
│   └── investment_repository.dart ✅
└── presentation/
    ├── cubit/
    │   ├── investment_cubit.dart ⏳
    │   └── investment_state.dart ⏳
    ├── pages/
    │   ├── investment_page.dart ⏳
    │   ├── add_investment_page.dart ⏳
    │   └── investment_detail_page.dart ⏳
    └── widgets/
        ├── investment_card.dart ⏳
        ├── portfolio_summary_card.dart ⏳
        └── transaction_list.dart ⏳
```

## 🎯 Langkah Implementasi Selanjutnya

### Step 1: Buat Investment Cubit
```dart
// File: lib/features/investment/presentation/cubit/investment_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/investment_repository.dart';
import '../../domain/investment_models.dart';

class InvestmentCubit extends Cubit<InvestmentState> {
  InvestmentCubit() : super(InvestmentInitial());

  Future<void> loadInvestments() async {
    emit(InvestmentLoading());
    try {
      final investments = await InvestmentRepository.fetchInvestments();
      final summary = await InvestmentRepository.fetchPortfolioSummary();
      emit(InvestmentLoaded(
        investments: investments,
        summary: summary,
      ));
    } catch (e) {
      emit(InvestmentError(e.toString()));
    }
  }

  Future<void> addInvestment({
    required String assetType,
    required String symbol,
    required String name,
    required double quantity,
    required double buyPrice,
    required DateTime purchaseDate,
    String? notes,
  }) async {
    try {
      await InvestmentRepository.createInvestment(
        assetType: assetType,
        symbol: symbol,
        name: name,
        quantity: quantity,
        buyPrice: buyPrice,
        purchaseDate: purchaseDate,
        notes: notes,
      );
      await loadInvestments(); // Reload
    } catch (e) {
      emit(InvestmentError(e.toString()));
    }
  }

  // ... methods lainnya
}
```

### Step 2: Buat Investment States
```dart
// File: lib/features/investment/presentation/cubit/investment_state.dart

abstract class InvestmentState {}

class InvestmentInitial extends InvestmentState {}

class InvestmentLoading extends InvestmentState {}

class InvestmentLoaded extends InvestmentState {
  final List<Investment> investments;
  final PortfolioSummary summary;

  InvestmentLoaded({
    required this.investments,
    required this.summary,
  });
}

class InvestmentError extends InvestmentState {
  final String message;
  InvestmentError(this.message);
}
```

### Step 3: Tambahkan ke Main.dart
```dart
// Di main.dart, tambahkan BlocProvider untuk InvestmentCubit
providers: [
  // ... providers lain
  BlocProvider<InvestmentCubit>(
    create: (context) => InvestmentCubit()..loadInvestments(),
  ),
],
```

### Step 4: Buat UI Investment Page
```dart
// File: lib/features/investment/presentation/pages/investment_page.dart

class InvestmentPage extends StatelessWidget {
  const InvestmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Portfolio'),
      ),
      body: BlocBuilder<InvestmentCubit, InvestmentState>(
        builder: (context, state) {
          if (state is InvestmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is InvestmentError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          
          if (state is InvestmentLoaded) {
            return Column(
              children: [
                // Portfolio Summary Card
                PortfolioSummaryCard(summary: state.summary),
                
                // Investment List
                Expanded(
                  child: ListView.builder(
                    itemCount: state.investments.length,
                    itemBuilder: (context, index) {
                      return InvestmentCard(
                        investment: state.investments[index],
                      );
                    },
                  ),
                ),
              ],
            );
          }
          
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Investment page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## 🎨 UI Design Suggestions

### Portfolio Summary Card
```
┌──────────────────────────────────────────┐
│  💼 Investment Portfolio                 │
├──────────────────────────────────────────┤
│  Total Investment: Rp 351.000.000        │
│  Current Value:    Rp 381.000.000 ↗️     │
│  Profit/Loss:      +Rp 30.000.000 (8.5%) │
├──────────────────────────────────────────┤
│  🪙 Crypto: Rp 360.000.000 (94%)         │
│  📈 Saham:  Rp 21.000.000 (6%)           │
└──────────────────────────────────────────┘
```

### Investment Card
```
┌──────────────────────────────────────────┐
│  🪙 BTC                                   │
│  Bitcoin                                  │
│  0.5 BTC @ Rp 700.000.000                │
│                                          │
│  Current: Rp 720.000.000 (+2.5% ↗️)      │
│  Value:   Rp 360.000.000                 │
│  P/L:     +Rp 10.000.000 (+2.86%)       │
│                                          │
│  [View Details] [Add Transaction]        │
└──────────────────────────────────────────┘
```

## 🔧 Integration dengan Bottom Nav

Tambahkan Investment ke bottom navigation:

```dart
// Di bottom_nav_bar.dart atau home_page.dart
BottomNavigationBarItem(
  icon: Icon(Icons.trending_up),
  label: 'Investment',
),

// Di page switcher:
pages: [
  DashboardTab(),
  HistoryTab(),
  AddTransactionTab(),
  InvestmentPage(), // ← Tambahkan ini
  ProfilePage(),
],
```

## 📊 Features to Implement

### Must Have (Priority 1)
- [x] API Integration
- [x] Models & Repository
- [ ] List Investments
- [ ] Portfolio Summary
- [ ] Add Investment
- [ ] Real-time Prices
- [ ] Buy/Sell Transactions

### Nice to Have (Priority 2)
- [ ] Price Charts
- [ ] Search Crypto
- [ ] Transaction History
- [ ] Edit Investment
- [ ] Delete Investment
- [ ] Refresh Prices
- [ ] Pull to Refresh

### Future Enhancements (Priority 3)
- [ ] Price Alerts
- [ ] Portfolio Analytics
- [ ] Export to CSV
- [ ] Dividend Tracking
- [ ] Tax Calculator

## 🎯 Testing Checklist

### API Testing
- [ ] Test list investments
- [ ] Test create investment
- [ ] Test portfolio summary
- [ ] Test get price
- [ ] Test add transaction
- [ ] Test error handling

### UI Testing
- [ ] Display portfolio summary correctly
- [ ] Show profit/loss with correct color
- [ ] Format currency properly (Rupiah)
- [ ] Handle loading states
- [ ] Handle empty states
- [ ] Handle error states

## 📝 Notes

- Semua harga dalam Rupiah (IDR)
- Crypto menggunakan CoinGecko API (free, no key)
- Saham menggunakan Yahoo Finance (free, unofficial)
- Price cache 5 menit untuk performa
- Support BTC, ETH, BNB, dan 10,000+ crypto
- Support semua saham IDX (.JK)

## 🚀 Ready to Continue?

Struktur dasar sudah siap! Selanjutnya:
1. Buat InvestmentCubit & States
2. Buat UI Pages
3. Buat Widgets
4. Integrasikan ke Bottom Nav
5. Testing!

Apakah Anda ingin saya lanjutkan membuat Cubit dan UI Pages sekarang? 🎨
