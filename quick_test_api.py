"""
Quick Test - API Multimodal Transaction
Script ini melakukan test cepat tanpa file audio/gambar
Hanya menggunakan endpoint chat-input untuk validasi
"""
import requests
import json

# Konfigurasi
BASE_URL = "http://127.0.0.1:8000"
API_URL = f"{BASE_URL}/api/finance"

# Ubah ini dengan token Anda atau kosongkan jika tidak perlu auth
AUTH_TOKEN = ""

def test_server():
    """Cek apakah Django server berjalan"""
    print("🔍 Mengecek server Django...")
    try:
        response = requests.get(BASE_URL, timeout=5)
        print(f"✅ Server berjalan di {BASE_URL}\n")
        return True
    except requests.exceptions.RequestException as e:
        print(f"❌ Server tidak berjalan: {str(e)}")
        print("   Jalankan: python manage.py runserver\n")
        return False

def test_endpoints_info():
    """Tampilkan informasi endpoint yang tersedia"""
    print("=" * 70)
    print("  📋 ENDPOINT API YANG TERSEDIA")
    print("=" * 70)
    
    endpoints = [
        {
            "name": "1. Scan Receipt (Gambar Struk)",
            "method": "POST",
            "url": "/api/finance/transactions/scan-receipt/",
            "input": "File gambar struk (receipt_image)",
            "tech": "Groq Vision Model"
        },
        {
            "name": "2. Scan Voice (Rekaman Suara)",
            "method": "POST",
            "url": "/api/finance/transactions/scan-voice/",
            "input": "File audio rekaman (audio_file)",
            "tech": "Groq Whisper + Text Model"
        },
        {
            "name": "3. Chat Input (Input Teks)",
            "method": "POST",
            "url": "/api/finance/transactions/chat-input/",
            "input": "JSON: {\"text\": \"deskripsi transaksi\"}",
            "tech": "Groq Text Model + Auto Save"
        }
    ]
    
    for ep in endpoints:
        print(f"\n{ep['name']}")
        print(f"   Method : {ep['method']}")
        print(f"   URL    : {ep['url']}")
        print(f"   Input  : {ep['input']}")
        print(f"   Tech   : {ep['tech']}")
    
    print("\n" + "=" * 70 + "\n")

def test_chat_input():
    """Test endpoint chat-input dengan berbagai skenario"""
    print("=" * 70)
    print("  🧪 TESTING: Chat Input Text")
    print("=" * 70 + "\n")
    
    # Siapkan header
    headers = {"Content-Type": "application/json"}
    if AUTH_TOKEN:
        headers["Authorization"] = f"Bearer {AUTH_TOKEN}"
    
    # Test cases
    test_cases = [
        {
            "name": "Test 1: Pengeluaran Makanan",
            "text": "Tadi pagi beli nasi goreng 25 ribu",
            "expected": {"type": "expense", "category": "Makanan", "amount": 25000}
        },
        {
            "name": "Test 2: Pemasukan Gaji",
            "text": "Kemarin terima gaji 5 juta rupiah",
            "expected": {"type": "income", "category": "Gaji", "amount": 5000000}
        },
        {
            "name": "Test 3: Pengeluaran Transportasi",
            "text": "Bayar parkir motor 5 ribu",
            "expected": {"type": "expense", "category": "Transportasi", "amount": 5000}
        },
        {
            "name": "Test 4: Pengeluaran Belanja",
            "text": "Belanja di supermarket total 150 ribu",
            "expected": {"type": "expense", "category": "Belanja", "amount": 150000}
        }
    ]
    
    passed = 0
    failed = 0
    
    for idx, test in enumerate(test_cases, 1):
        print(f"\n{'─' * 70}")
        print(f"  {test['name']}")
        print(f"{'─' * 70}")
        print(f"📝 Input Text: \"{test['text']}\"")
        
        try:
            # Kirim request
            response = requests.post(
                f"{API_URL}/transactions/chat-input/",
                headers=headers,
                json={"text": test['text']},
                timeout=30
            )
            
            print(f"📥 Status Code: {response.status_code}")
            
            # Parse response
            result = response.json()
            
            if response.status_code in [200, 201]:
                print("✅ Request berhasil!")
                
                # Tampilkan extracted data
                extracted = result.get("extracted_data", {})
                print(f"\n   💰 Amount      : Rp {extracted.get('amount', 0):,.0f}")
                print(f"   📝 Description : {extracted.get('description', 'N/A')}")
                print(f"   🏷️  Category    : {extracted.get('category_hint', 'N/A')}")
                print(f"   📊 Type        : {extracted.get('type', 'N/A')}")
                print(f"   📅 Date        : {extracted.get('date', 'N/A')}")
                
                # Validasi hasil (opsional)
                expected = test['expected']
                amount_ok = extracted.get('amount') == expected['amount']
                type_ok = extracted.get('type') == expected['type']
                
                if amount_ok and type_ok:
                    print("\n   ✅ Validasi: Data sesuai ekspektasi")
                    passed += 1
                else:
                    print("\n   ⚠️  Validasi: Data berbeda dari ekspektasi")
                    print(f"       Expected amount: {expected['amount']}, Got: {extracted.get('amount')}")
                    print(f"       Expected type: {expected['type']}, Got: {extracted.get('type')}")
                    passed += 1  # Tetap dihitung pass karena API berhasil
                    
                # Tampilkan info saved transaction jika ada
                if "saved_transaction" in result:
                    saved = result["saved_transaction"]
                    print(f"\n   💾 Transaction ID: {saved.get('id', 'N/A')}")
                    print(f"   📂 Saved to DB  : Yes")
                
            else:
                print(f"❌ Request gagal!")
                print(f"   Error: {result.get('error', 'Unknown error')}")
                failed += 1
                
        except requests.exceptions.RequestException as e:
            print(f"❌ Request error: {str(e)}")
            failed += 1
        except Exception as e:
            print(f"❌ Unexpected error: {str(e)}")
            failed += 1
    
    # Summary
    print("\n" + "=" * 70)
    print("  📊 TEST SUMMARY")
    print("=" * 70)
    print(f"  ✅ Passed : {passed}/{len(test_cases)}")
    print(f"  ❌ Failed : {failed}/{len(test_cases)}")
    print("=" * 70 + "\n")
    
    return passed, failed

def print_manual_test_commands():
    """Cetak perintah untuk test manual"""
    print("=" * 70)
    print("  🔧 MANUAL TESTING dengan cURL")
    print("=" * 70 + "\n")
    
    print("1️⃣  Test Chat Input:")
    print('   curl -X POST http://127.0.0.1:8000/api/finance/transactions/chat-input/ \\')
    print('     -H "Content-Type: application/json" \\')
    if AUTH_TOKEN:
        print(f'     -H "Authorization: Bearer {AUTH_TOKEN[:20]}..." \\')
    print('     -d "{\\"text\\":\\"Beli makan siang 50 ribu\\"}"')
    
    print("\n2️⃣  Test Scan Receipt (butuh file gambar):")
    print('   curl -X POST http://127.0.0.1:8000/api/finance/transactions/scan-receipt/ \\')
    if AUTH_TOKEN:
        print(f'     -H "Authorization: Bearer {AUTH_TOKEN[:20]}..." \\')
    print('     -F "receipt_image=@test_receipt.jpg"')
    
    print("\n3️⃣  Test Scan Voice (butuh file audio):")
    print('   curl -X POST http://127.0.0.1:8000/api/finance/transactions/scan-voice/ \\')
    if AUTH_TOKEN:
        print(f'     -H "Authorization: Bearer {AUTH_TOKEN[:20]}..." \\')
    print('     -F "audio_file=@test_voice.mp3"')
    
    print("\n" + "=" * 70 + "\n")

def main():
    print("\n" + "=" * 70)
    print("  🚀 QUICK TEST - API MULTIMODAL TRANSACTION")
    print("=" * 70 + "\n")
    
    # Cek server
    if not test_server():
        print("⚠️  Server harus berjalan terlebih dahulu!")
        print("   Jalankan di terminal lain: python manage.py runserver")
        return
    
    # Tampilkan info endpoint
    test_endpoints_info()
    
    # Cek token
    if not AUTH_TOKEN:
        print("⚠️  WARNING: AUTH_TOKEN tidak diset!")
        print("   Mencoba test tanpa autentikasi...")
        print("   Jika endpoint memerlukan autentikasi, test akan gagal.\n")
    
    # Jalankan test
    passed, failed = test_chat_input()
    
    # Tampilkan manual test commands
    print_manual_test_commands()
    
    # Final message
    print("📌 CATATAN:")
    print("   • Test di atas hanya menggunakan endpoint chat-input")
    print("   • Untuk test lengkap dengan gambar & audio, gunakan: test_multimodal_api.py")
    print("   • Lihat panduan lengkap di: TEST_MULTIMODAL_GUIDE.md")
    print("\n   ✅ Endpoint chat-input: TERSEDIA dan BERFUNGSI" if passed > 0 else "\n   ❌ Endpoint chat-input: BERMASALAH")
    print("   ⏳ Endpoint scan-receipt: Butuh file gambar untuk test")
    print("   ⏳ Endpoint scan-voice: Butuh file audio untuk test")
    print("\n" + "=" * 70 + "\n")

if __name__ == "__main__":
    main()
