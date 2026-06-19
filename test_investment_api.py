"""
Script Testing untuk Investment API
Test dengan data real dari CoinGecko & Yahoo Finance
"""
import requests
import json
from datetime import datetime, date

BASE_URL = "http://127.0.0.1:8000"
API_URL = f"{BASE_URL}/api/finance"

# Token - ganti dengan token valid
AUTH_TOKEN = ""

HEADERS = {
    "Authorization": f"Bearer {AUTH_TOKEN}",
    "Content-Type": "application/json"
}

def print_header(title):
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)

def print_response(response):
    print(f"\n📥 Status: {response.status_code}")
    try:
        data = response.json()
        print(f"📄 Response:")
        print(json.dumps(data, indent=2, ensure_ascii=False))
    except:
        print(response.text)

# ══════════════════════════════════════════════════════════════════════════════
# TEST FUNCTIONS
# ══════════════════════════════════════════════════════════════════════════════

def test_1_get_crypto_price():
    """Test 1: Get harga crypto real-time"""
    print_header("TEST 1: Get Crypto Price (Bitcoin)")
    
    response = requests.get(
        f"{API_URL}/investments/price/?symbol=BTC&type=crypto",
        headers=HEADERS
    )
    
    print_response(response)
    
    if response.status_code == 200:
        data = response.json()
        print(f"\n✅ Harga BTC saat ini: Rp {data['current_price']:,.0f}")
        print(f"   Perubahan 24h: {data['price_change_24h']}%")
        return True
    return False

def test_2_get_stock_price():
    """Test 2: Get harga saham IDX"""
    print_header("TEST 2: Get Stock Price (BBCA)")
    
    response = requests.get(
        f"{API_URL}/investments/price/?symbol=BBCA&type=stock",
        headers=HEADERS
    )
    
    print_response(response)
    
    if response.status_code == 200:
        data = response.json()
        print(f"\n✅ Harga BBCA saat ini: Rp {data['current_price']:,.0f}")
        return True
    return False

def test_3_search_crypto():
    """Test 3: Search crypto"""
    print_header("TEST 3: Search Crypto")
    
    query = "ethereum"
    response = requests.get(
        f"{API_URL}/investments/search-crypto/?q={query}",
        headers=HEADERS
    )
    
    print_response(response)
    
    if response.status_code == 200:
        results = response.json()
        print(f"\n✅ Found {len(results)} results for '{query}'")
        return True
    return False

def test_4_add_crypto_investment():
    """Test 4: Tambah investasi crypto"""
    print_header("TEST 4: Add Crypto Investment (BTC)")
    
    investment_data = {
        "asset_type": "crypto",
        "symbol": "BTC",
        "name": "Bitcoin",
        "quantity": 0.01,
        "buy_price": 700000000,
        "purchase_date": "2026-01-15",
        "notes": "First crypto investment"
    }
    
    response = requests.post(
        f"{API_URL}/investments/",
        headers=HEADERS,
        json=investment_data
    )
    
    print_response(response)
    
    if response.status_code == 201:
        data = response.json()
        print(f"\n✅ Investment created with ID: {data['id']}")
        return data['id']
    return None

def test_5_add_stock_investment():
    """Test 5: Tambah investasi saham"""
    print_header("TEST 5: Add Stock Investment (BBCA)")
    
    investment_data = {
        "asset_type": "stock",
        "symbol": "BBCA",
        "name": "Bank BCA",
        "quantity": 10,
        "buy_price": 9000,
        "purchase_date": "2026-02-10",
        "notes": "Blue chip stock"
    }
    
    response = requests.post(
        f"{API_URL}/investments/",
        headers=HEADERS,
        json=investment_data
    )
    
    print_response(response)
    
    if response.status_code == 201:
        data = response.json()
        print(f"\n✅ Investment created with ID: {data['id']}")
        return data['id']
    return None

def test_6_list_investments():
    """Test 6: List semua investasi dengan harga real-time"""
    print_header("TEST 6: List All Investments")
    
    response = requests.get(
        f"{API_URL}/investments/",
        headers=HEADERS
    )
    
    print_response(response)
    
    if response.status_code == 200:
        data = response.json()
        print(f"\n✅ Total investments: {len(data)}")
        
        for inv in data:
            print(f"\n   📊 {inv['symbol']} - {inv['name']}")
            print(f"      Quantity: {inv['quantity']}")
            print(f"      Buy Price: Rp {float(inv['buy_price']):,.0f}")
            print(f"      Current Price: Rp {float(inv['current_price']):,.0f}")
            print(f"      Current Value: Rp {inv['current_value']:,.0f}")
            print(f"      Profit/Loss: Rp {inv['profit_loss']:,.0f} ({inv['profit_loss_percentage']}%)")
        
        return True
    return False

def test_7_portfolio_summary():
    """Test 7: Portfolio summary"""
    print_header("TEST 7: Portfolio Summary")
    
    response = requests.get(
        f"{API_URL}/investments/portfolio-summary/",
        headers=HEADERS
    )
    
    print_response(response)
    
    if response.status_code == 200:
        data = response.json()
        print(f"\n✅ Portfolio Summary:")
        print(f"   Total Investment: Rp {data['total_investment']:,.0f}")
        print(f"   Current Value: Rp {data['current_value']:,.0f}")
        print(f"   Profit/Loss: Rp {data['total_profit_loss']:,.0f} ({data['profit_loss_percentage']}%)")
        print(f"   Total Assets: {data['total_assets']}")
        
        print(f"\n   📊 By Type:")
        print(f"      Crypto: Rp {data['by_type']['crypto']['current_value']:,.0f} ({data['by_type']['crypto']['count']} assets)")
        print(f"      Stock:  Rp {data['by_type']['stock']['current_value']:,.0f} ({data['by_type']['stock']['count']} assets)")
        
        return True
    return False

def test_8_add_transaction(investment_id):
    """Test 8: Tambah transaksi buy"""
    print_header("TEST 8: Add Buy Transaction")
    
    if not investment_id:
        print("⚠️  Investment ID required")
        return False
    
    transaction_data = {
        "transaction_type": "buy",
        "quantity": 0.005,
        "price": 680000000,
        "transaction_date": datetime.now().isoformat(),
        "notes": "Buy the dip"
    }
    
    response = requests.post(
        f"{API_URL}/investments/{investment_id}/add-transaction/",
        headers=HEADERS,
        json=transaction_data
    )
    
    print_response(response)
    
    if response.status_code == 201:
        print(f"\n✅ Transaction added successfully")
        return True
    return False

def test_9_refresh_prices():
    """Test 9: Refresh all prices"""
    print_header("TEST 9: Refresh Prices (Force)")
    
    response = requests.get(
        f"{API_URL}/investments/refresh-prices/",
        headers=HEADERS
    )
    
    print_response(response)
    
    if response.status_code == 200:
        print(f"\n✅ Prices refreshed successfully")
        return True
    return False

# ══════════════════════════════════════════════════════════════════════════════
# MAIN MENU
# ══════════════════════════════════════════════════════════════════════════════

def show_menu():
    print("\n" + "=" * 70)
    print("  🧪 TESTING INVESTMENT API")
    print("=" * 70)
    print("\n  Price API Tests:")
    print("  1. Get Crypto Price (BTC)")
    print("  2. Get Stock Price (BBCA)")
    print("  3. Search Crypto")
    print("\n  Investment Tests:")
    print("  4. Add Crypto Investment (BTC)")
    print("  5. Add Stock Investment (BBCA)")
    print("  6. List All Investments")
    print("  7. Portfolio Summary")
    print("  8. Add Buy Transaction")
    print("  9. Refresh Prices")
    print("\n  All:")
    print("  0. Run All Tests")
    print("  x. Exit")
    print("=" * 70)

def main():
    # Cek server
    try:
        requests.get(BASE_URL, timeout=5)
        print(f"✅ Server running at {BASE_URL}")
    except:
        print(f"❌ Server not running at {BASE_URL}")
        print("   Run: python manage.py runserver")
        return
    
    # Cek token
    if not AUTH_TOKEN:
        print("\n⚠️  WARNING: AUTH_TOKEN not set!")
        print("   Set AUTH_TOKEN in this script first")
        print("   Run: python get_auth_token.py")
        
        choice = input("\n   Continue without auth? (y/n): ")
        if choice.lower() != 'y':
            return
        HEADERS.pop("Authorization", None)
    
    investment_id = None
    
    while True:
        show_menu()
        choice = input("\nChoice (0-9/x): ").strip().lower()
        
        if choice == 'x':
            print("\n👋 Bye!\n")
            break
        elif choice == '1':
            test_1_get_crypto_price()
        elif choice == '2':
            test_2_get_stock_price()
        elif choice == '3':
            test_3_search_crypto()
        elif choice == '4':
            investment_id = test_4_add_crypto_investment()
        elif choice == '5':
            test_5_add_stock_investment()
        elif choice == '6':
            test_6_list_investments()
        elif choice == '7':
            test_7_portfolio_summary()
        elif choice == '8':
            if not investment_id:
                print("\n⚠️  Please create an investment first (option 4 or 5)")
            else:
                test_8_add_transaction(investment_id)
        elif choice == '9':
            test_9_refresh_prices()
        elif choice == '0':
            # Run all tests
            print_header("🚀 RUNNING ALL TESTS")
            
            test_1_get_crypto_price()
            input("\nPress Enter to continue...")
            
            test_2_get_stock_price()
            input("\nPress Enter to continue...")
            
            test_3_search_crypto()
            input("\nPress Enter to continue...")
            
            investment_id = test_4_add_crypto_investment()
            input("\nPress Enter to continue...")
            
            test_5_add_stock_investment()
            input("\nPress Enter to continue...")
            
            test_6_list_investments()
            input("\nPress Enter to continue...")
            
            test_7_portfolio_summary()
            input("\nPress Enter to continue...")
            
            if investment_id:
                test_8_add_transaction(investment_id)
            
            print_header("✅ ALL TESTS COMPLETED")
        else:
            print("\n❌ Invalid choice!")
        
        if choice != '0' and choice != 'x':
            input("\nPress Enter to continue...")

if __name__ == "__main__":
    main()
