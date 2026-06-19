# 📈 Quick Guide: Investment Portfolio API

## 🚀 Quick Start

### 1. Run Migration
```bash
python manage.py migrate
```

### 2. Install Required Package
```bash
pip install requests  # Untuk API calls
```

### 3. Start Server
```bash
python manage.py runserver
```

### 4. Test API
```bash
python test_investment_api.py
```

---

## 🎯 Fitur Utama

✅ **Track Crypto** dengan harga real-time dari CoinGecko
✅ **Track Saham Indonesia** dengan harga dari Yahoo Finance
✅ **Auto-calculate** profit/loss
✅ **Portfolio summary** dengan breakdown
✅ **Transaction history** (buy/sell)
✅ **Search crypto** by name
✅ **Refresh prices** on-demand

---

## 📋 API Endpoints

### Investment CRUD
- `GET /api/finance/investments/` - List investments
- `POST /api/finance/investments/` - Add investment
- `GET /api/finance/investments/{id}/` - Detail
- `PUT /api/finance/investments/{id}/` - Update
- `DELETE /api/finance/investments/{id}/` - Delete

### Portfolio & Analytics
- `GET /api/finance/investments/portfolio-summary/` - Summary
- `GET /api/finance/investments/refresh-prices/` - Refresh prices

### Transactions
- `POST /api/finance/investments/{id}/add-transaction/` - Buy/Sell
- `GET /api/finance/investments/{id}/transactions/` - History

### Price API
- `GET /api/finance/investments/price/?symbol=BTC&type=crypto`
- `GET /api/finance/investments/search-crypto/?q=bitcoin`

---

## 📊 Example: Add Investment

### Crypto (Bitcoin)
```bash
curl -X POST http://127.0.0.1:8000/api/finance/investments/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "asset_type": "crypto",
    "symbol": "BTC",
    "name": "Bitcoin",
    "quantity": 0.01,
    "buy_price": 700000000,
    "purchase_date": "2026-01-15",
    "notes": "My first crypto"
  }'
```

### Stock (Bank BCA)
```bash
curl -X POST http://127.0.0.1:8000/api/finance/investments/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "asset_type": "stock",
    "symbol": "BBCA",
    "name": "Bank BCA",
    "quantity": 10,
    "buy_price": 9000,
    "purchase_date": "2026-02-10",
    "notes": "Blue chip"
  }'
```

---

## 💰 Example: Portfolio Summary

**Response**:
```json
{
  "total_investment": 7090000,
  "current_value": 7200000,
  "total_profit_loss": 110000,
  "profit_loss_percentage": 1.55,
  "total_assets": 2,
  "by_type": {
    "crypto": {
      "total_investment": 7000000,
      "current_value": 7100000,
      "profit_loss": 100000,
      "count": 1
    },
    "stock": {
      "total_investment": 90000,
      "current_value": 100000,
      "profit_loss": 10000,
      "count": 1
    }
  }
}
```

---

## 🌐 Supported Assets

### Crypto (10,000+)
- Bitcoin (BTC)
- Ethereum (ETH)
- Binance Coin (BNB)
- Cardano (ADA)
- Solana (SOL)
- Dogecoin (DOGE)
- Polygon (MATIC)
- dll...

### Saham IDX (Semua)
- Bank BCA (BBCA)
- Bank BRI (BBRI)
- Bank Mandiri (BMRI)
- Telkom (TLKM)
- Astra (ASII)
- Unilever (UNVR)
- dll...

---

## 🔧 Price API Sources

### CoinGecko (Crypto)
- **URL**: https://api.coingecko.com/api/v3
- **Free**: ✅ No API key
- **Rate**: 10,000-50,000 req/month
- **Currency**: IDR
- **Update**: 1-2 minutes

### Yahoo Finance (Stock)
- **URL**: https://query1.finance.yahoo.com
- **Free**: ✅ Unofficial API
- **Symbol**: SYMBOL.JK (e.g., BBCA.JK)
- **Update**: Real-time (market hours)

---

## 📝 Models

### Investment
- `id` - UUID
- `user` - ForeignKey
- `asset_type` - crypto/stock
- `symbol` - BTC, BBCA, dll
- `name` - Full name
- `quantity` - Amount owned
- `buy_price` - Average buy price
- `purchase_date` - First purchase date

### InvestmentTransaction
- `id` - UUID
- `investment` - ForeignKey
- `transaction_type` - buy/sell
- `quantity` - Amount
- `price` - Price per unit
- `total_amount` - Auto-calculated
- `transaction_date` - DateTime

---

## 🧪 Testing

### Interactive Test
```bash
python test_investment_api.py
```

### Manual Test - Get Price
```bash
# Crypto
curl "http://127.0.0.1:8000/api/finance/investments/price/?symbol=BTC&type=crypto" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Stock
curl "http://127.0.0.1:8000/api/finance/investments/price/?symbol=BBCA&type=stock" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## ⚡ Features

### Auto-Calculate
- Current value = quantity × current_price
- Profit/Loss = current_value - total_cost
- P/L % = (profit_loss / total_cost) × 100

### Price Caching
- Cache duration: 5 minutes (market hours)
- Batch fetching untuk efisiensi
- Fallback untuk API errors

### Transaction Auto-Update
- **Buy**: Increase quantity, recalculate avg price
- **Sell**: Decrease quantity

---

## 📚 Documentation

Full documentation: `INVESTMENT_API_DOCS.md`

---

## 🎯 Next Steps

1. ☐ Run migration: `python manage.py migrate`
2. ☐ Test price API: `python test_investment_api.py`
3. ☐ Add investments via API
4. ☐ Integrate dengan Flutter app
5. ☐ Setup periodic price refresh (optional)

---

**🚀 Investment Portfolio API ready to use!**

*Created: June 12, 2026*
