# 📈 Dokumentasi API Investment Portfolio (Saham & Crypto)

## 🎯 Overview

Fitur Investment Portfolio memungkinkan user untuk:
- ✅ Track investasi saham Indonesia
- ✅ Track investasi cryptocurrency
- ✅ Melihat harga real-time
- ✅ Hitung profit/loss otomatis
- ✅ Lihat performance portfolio
- ✅ History transaksi buy/sell

---

## 🌐 Data Sources (API External)

### 1. **Cryptocurrency Prices**
- **Provider**: CoinGecko API
- **URL**: https://api.coingecko.com/api/v3
- **Features**: 
  - ✅ **GRATIS** (No API key required)
  - ✅ Harga dalam IDR
  - ✅ Update setiap 1-2 menit
  - ✅ 10,000-50,000 requests/month (free tier)
- **Supported**: BTC, ETH, BNB, USDT, dan 10,000+ crypto lainnya

### 2. **Stock Prices (Saham Indonesia)**
- **Provider**: Yahoo Finance API
- **Features**:
  - ✅ **GRATIS** (Unofficial API)
  - ✅ Data IDX (Bursa Efek Indonesia)
  - ✅ Real-time saat market hours (09:00-16:00 WIB)
  - ✅ Semua saham IDX (.JK suffix)
- **Supported**: BBCA, BMRI, BBRI, TLKM, ASII, dll

---

## 📊 Database Models

### 1. **Investment**
```python
{
    "id": "uuid",
    "user": "foreign_key",
    "asset_type": "crypto/stock",
    "symbol": "BTC",           # Ticker
    "name": "Bitcoin",
    "quantity": 0.5,           # Jumlah (desimal untuk crypto)
    "buy_price": 700000000,    # Harga beli rata-rata
    "purchase_date": "2026-01-15",
    "notes": "Beli saat dip",
    "created_at": "datetime",
    "updated_at": "datetime"
}
```

**Calculated Fields**:
- `total_cost` = quantity × buy_price
- `current_value` = quantity × current_price
- `profit_loss` = current_value - total_cost
- `profit_loss_percentage` = (profit_loss / total_cost) × 100

### 2. **InvestmentTransaction**
```python
{
    "id": "uuid",
    "investment": "foreign_key",
    "transaction_type": "buy/sell",
    "quantity": 0.25,
    "price": 680000000,
    "total_amount": 170000000,  # Auto-calculated
    "transaction_date": "datetime",
    "notes": "Optional",
    "created_at": "datetime"
}
```

### 3. **PriceCache**
```python
{
    "symbol": "BTC",
    "asset_type": "crypto",
    "current_price": 700000000,
    "price_change_24h": 2.5,    # Persentase
    "last_updated": "datetime",
    "source": "coingecko"
}
```

**Cache Duration**: 5 menit (market hours) atau 1 jam (after hours)

---

## 🔌 API Endpoints

### 1️⃣ List Investments

**GET** `/api/finance/investments/`

**Response**:
```json
[
  {
    "id": "uuid",
    "asset_type": "crypto",
    "symbol": "BTC",
    "name": "Bitcoin",
    "quantity": "0.50000000",
    "buy_price": "700000000.00",
    "total_cost": "350000000.00",
    "current_price": "720000000.00",
    "current_value": 360000000,
    "profit_loss": 10000000,
    "profit_loss_percentage": 2.86,
    "purchase_date": "2026-01-15",
    "notes": "",
    "created_at": "2026-01-15T10:00:00Z",
    "updated_at": "2026-06-12T14:30:00Z"
  },
  {
    "id": "uuid",
    "asset_type": "stock",
    "symbol": "BBCA",
    "name": "Bank BCA",
    "quantity": "100.00000000",
    "buy_price": "9000.00",
    "total_cost": "900000.00",
    "current_price": "9200.00",
    "current_value": 920000,
    "profit_loss": 20000,
    "profit_loss_percentage": 2.22,
    "purchase_date": "2026-02-10",
    "notes": "Blue chip stock",
    "created_at": "2026-02-10T09:30:00Z",
    "updated_at": "2026-06-12T14:30:00Z"
  }
]
```

---

### 2️⃣ Create Investment

**POST** `/api/finance/investments/`

**Request Body**:
```json
{
  "asset_type": "crypto",
  "symbol": "BTC",
  "name": "Bitcoin",
  "quantity": 0.5,
  "buy_price": 700000000,
  "purchase_date": "2026-01-15",
  "notes": "First crypto investment"
}
```

**Response**: `201 Created`
```json
{
  "id": "uuid",
  "asset_type": "crypto",
  "symbol": "BTC",
  ...
}
```

---

### 3️⃣ Get Investment Detail

**GET** `/api/finance/investments/{id}/`

**Response**:
```json
{
  "id": "uuid",
  "asset_type": "crypto",
  "symbol": "BTC",
  "name": "Bitcoin",
  "quantity": "0.50000000",
  "buy_price": "700000000.00",
  "total_cost": "350000000.00",
  "current_price": "720000000.00",
  "current_value": 360000000,
  "profit_loss": 10000000,
  "profit_loss_percentage": 2.86,
  ...
}
```

---

### 4️⃣ Update Investment

**PUT/PATCH** `/api/finance/investments/{id}/`

**Request Body**:
```json
{
  "quantity": 0.75,
  "buy_price": 710000000,
  "notes": "Updated"
}
```

---

### 5️⃣ Delete Investment

**DELETE** `/api/finance/investments/{id}/`

**Response**: `204 No Content`

---

### 6️⃣ Portfolio Summary ⭐

**GET** `/api/finance/investments/portfolio-summary/`

**Response**:
```json
{
  "total_investment": 351000000,
  "current_value": 381000000,
  "total_profit_loss": 30000000,
  "profit_loss_percentage": 8.55,
  "total_assets": 2,
  "by_type": {
    "crypto": {
      "total_investment": 350000000,
      "current_value": 360000000,
      "profit_loss": 10000000,
      "count": 1
    },
    "stock": {
      "total_investment": 1000000,
      "current_value": 1020000,
      "profit_loss": 20000,
      "count": 1
    }
  }
}
```

**Keterangan**:
- `total_investment`: Total modal yang diinvestasikan
- `current_value`: Nilai portfolio saat ini (berdasarkan harga real-time)
- `total_profit_loss`: Untung/rugi total
- `profit_loss_percentage`: Persentase return
- `by_type`: Breakdown per jenis asset (crypto vs stock)

---

### 7️⃣ Add Transaction (Buy/Sell)

**POST** `/api/finance/investments/{id}/add-transaction/`

**Request Body (Buy)**:
```json
{
  "transaction_type": "buy",
  "quantity": 0.25,
  "price": 680000000,
  "transaction_date": "2026-06-12T10:00:00Z",
  "notes": "Beli saat dip"
}
```

**Request Body (Sell)**:
```json
{
  "transaction_type": "sell",
  "quantity": 0.1,
  "price": 720000000,
  "transaction_date": "2026-06-12T15:00:00Z",
  "notes": "Take profit"
}
```

**Response**: `201 Created`
```json
{
  "message": "Transaksi berhasil ditambahkan",
  "transaction": {
    "id": "uuid",
    "investment": "uuid",
    "investment_symbol": "BTC",
    "investment_name": "Bitcoin",
    "transaction_type": "buy",
    "quantity": "0.25000000",
    "price": "680000000.00",
    "total_amount": "170000000.00",
    "transaction_date": "2026-06-12T10:00:00Z",
    "notes": "Beli saat dip",
    "created_at": "2026-06-12T10:00:10Z"
  }
}
```

**Auto-Update Investment**:
- **Buy**: Quantity bertambah, buy_price di-recalculate (average)
- **Sell**: Quantity berkurang

---

### 8️⃣ Transaction History

**GET** `/api/finance/investments/{id}/transactions/`

**Response**:
```json
[
  {
    "id": "uuid",
    "investment": "uuid",
    "investment_symbol": "BTC",
    "investment_name": "Bitcoin",
    "transaction_type": "buy",
    "quantity": "0.25000000",
    "price": "680000000.00",
    "total_amount": "170000000.00",
    "transaction_date": "2026-06-12T10:00:00Z",
    "notes": "",
    "created_at": "2026-06-12T10:00:10Z"
  },
  ...
]
```

---

### 9️⃣ Get Real-Time Price

**GET** `/api/finance/investments/price/?symbol=BTC&type=crypto`

**Query Params**:
- `symbol` (required): Ticker symbol
- `type` (required): `crypto` atau `stock`

**Response**:
```json
{
  "symbol": "BTC",
  "name": "Bitcoin",
  "current_price": 720000000,
  "price_change_24h": 2.5,
  "last_updated": "2026-06-12T14:30:00Z"
}
```

---

### 🔟 Search Crypto

**GET** `/api/finance/investments/search-crypto/?q=bitcoin`

**Response**:
```json
[
  {
    "id": "bitcoin",
    "symbol": "BTC",
    "name": "Bitcoin"
  },
  {
    "id": "bitcoin-cash",
    "symbol": "BCH",
    "name": "Bitcoin Cash"
  },
  ...
]
```

---

### 1️⃣1️⃣ Refresh Prices

**GET** `/api/finance/investments/refresh-prices/`

**Response**:
```json
{
  "message": "Prices refreshed successfully",
  "prices": {
    "BTC": {
      "symbol": "BTC",
      "name": "Bitcoin",
      "current_price": 720000000,
      "price_change_24h": 2.5,
      "last_updated": "2026-06-12T14:35:00Z"
    },
    ...
  }
}
```

**Keterangan**: Bypass cache dan fetch fresh prices dari API

---

## 📱 Flutter Integration Examples

### 1. List Investments

```dart
Future<List<Investment>> getInvestments() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/finance/investments/'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => Investment.fromJson(json)).toList();
  }
  throw Exception('Failed to load investments');
}
```

---

### 2. Add Investment

```dart
Future<void> addInvestment({
  required String assetType,
  required String symbol,
  required String name,
  required double quantity,
  required double buyPrice,
  required DateTime purchaseDate,
  String? notes,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/finance/investments/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'asset_type': assetType,
      'symbol': symbol,
      'name': name,
      'quantity': quantity,
      'buy_price': buyPrice,
      'purchase_date': purchaseDate.toIso8601String().split('T')[0],
      'notes': notes,
    }),
  );
  
  if (response.statusCode != 201) {
    throw Exception('Failed to add investment');
  }
}
```

---

### 3. Get Portfolio Summary

```dart
Future<PortfolioSummary> getPortfolioSummary() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/finance/investments/portfolio-summary/'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  if (response.statusCode == 200) {
    return PortfolioSummary.fromJson(jsonDecode(response.body));
  }
  throw Exception('Failed to load portfolio summary');
}
```

---

### 4. Get Real-Time Price

```dart
Future<PriceData> getPrice(String symbol, String type) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/finance/investments/price/?symbol=$symbol&type=$type'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  if (response.statusCode == 200) {
    return PriceData.fromJson(jsonDecode(response.body));
  }
  throw Exception('Price not found');
}
```

---

### 5. Add Transaction

```dart
Future<void> addTransaction({
  required String investmentId,
  required String transactionType,
  required double quantity,
  required double price,
  required DateTime transactionDate,
  String? notes,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/finance/investments/$investmentId/add-transaction/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'transaction_type': transactionType,
      'quantity': quantity,
      'price': price,
      'transaction_date': transactionDate.toIso8601String(),
      'notes': notes,
    }),
  );
  
  if (response.statusCode != 201) {
    throw Exception('Failed to add transaction');
  }
}
```

---

## 🎨 UI/UX Suggestions

### Portfolio Dashboard
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
│  🪙 BTC - Bitcoin                         │
│  0.5 BTC @ Rp 700.000.000                │
│                                          │
│  Current: Rp 720.000.000 (+2.5% ↗️)      │
│  Value:   Rp 360.000.000                 │
│  P/L:     +Rp 10.000.000 (+2.86%)       │
│                                          │
│  [View Details] [Add Transaction]        │
└──────────────────────────────────────────┘
```

---

## ⚙️ Setup & Migration

### 1. Run Migrations

```bash
python manage.py makemigrations finance
python manage.py migrate
```

### 2. Test API

```bash
# Get portfolio summary
curl -X GET http://127.0.0.1:8000/api/finance/investments/portfolio-summary/ \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get BTC price
curl -X GET "http://127.0.0.1:8000/api/finance/investments/price/?symbol=BTC&type=crypto" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🔐 Security & Best Practices

### Rate Limiting
- Cache prices untuk 5 menit
- Batch fetch untuk multiple assets
- Graceful fallback jika API down

### Error Handling
- Handle API timeouts
- Show last known price jika API error
- User-friendly error messages

### Data Validation
- Quantity > 0
- Buy price > 0
- Symbol format validation
- Transaction date validation

---

## 📈 Supported Assets

### Crypto (via CoinGecko)
- ✅ Bitcoin (BTC)
- ✅ Ethereum (ETH)
- ✅ Binance Coin (BNB)
- ✅ Cardano (ADA)
- ✅ Solana (SOL)
- ✅ Dogecoin (DOGE)
- ✅ Polygon (MATIC)
- ✅ 10,000+ lainnya

### Saham Indonesia (via Yahoo Finance)
- ✅ Bank BCA (BBCA)
- ✅ Bank BRI (BBRI)
- ✅ Bank Mandiri (BMRI)
- ✅ Telkom (TLKM)
- ✅ Astra (ASII)
- ✅ Unilever (UNVR)
- ✅ Semua saham IDX (.JK)

---

## 🎯 Future Enhancements

- [ ] Portfolio analytics & insights
- [ ] Price alerts
- [ ] Dividend tracking (saham)
- [ ] Staking rewards (crypto)
- [ ] Auto-import dari exchange/broker
- [ ] Tax calculation
- [ ] Comparison dengan index (IHSG, BTC)

---

**🚀 Investment Portfolio API siap digunakan!**

*Dokumentasi dibuat: 12 Juni 2026*
