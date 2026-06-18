"""
Script untuk menguji API Transaction dengan input suara dan gambar
"""
import requests
import json
import os
from pathlib import Path

# Konfigurasi Base URL
BASE_URL = "http://127.0.0.1:8000"  # Sesuaikan dengan server Django Anda
API_URL = f"{BASE_URL}/api/finance"

# Token autentikasi - Ganti dengan token valid Anda
AUTH_TOKEN = "YOUR_AUTH_TOKEN_HERE"  # Anda perlu login dulu untuk mendapatkan token

HEADERS = {
    "Authorization": f"Bearer {AUTH_TOKEN}"
}


def print_separator(title):
    """Cetak separator untuk output yang lebih jelas"""
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)


def test_scan_receipt_image():
    """
    Test endpoint: POST /api/finance/transactions/scan-receipt/
    Menggunakan gambar struk belanja
    """
    print_separator("TEST 1: Scan Receipt Image")
    
    # Path ke file gambar test (Anda perlu membuat atau menyediakan gambar struk)
    # Untuk testing, saya akan membuat file dummy atau gunakan gambar yang ada
    image_path = Path(__file__).parent / "test_receipt.jpg"
    
    if not image_path.exists():
        print(f"⚠️  File gambar tidak ditemukan: {image_path}")
        print("   Silakan letakkan gambar struk dengan nama 'test_receipt.jpg'")
        print("   di folder yang sama dengan script ini.")
        return False
    
    try:
        # Buka file gambar
        with open(image_path, "rb") as img_file:
            files = {
                "receipt_image": ("receipt.jpg", img_file, "image/jpeg")
            }
            
            # Kirim request ke API
            response = requests.post(
                f"{API_URL}/transactions/scan-receipt/",
                headers=HEADERS,
                files=files,
                timeout=30
            )
        
        print(f"\n📤 Request URL: {response.url}")
        print(f"📥 Status Code: {response.status_code}")
        
        # Parse response
        result = response.json()
        print(f"\n📄 Response Body:")
        print(json.dumps(result, indent=2, ensure_ascii=False))
        
        if response.status_code == 200:
            print("\n✅ TEST BERHASIL: Gambar struk berhasil dianalisis!")
            extracted = result.get("extracted_data", {})
            print(f"\n   💰 Amount: Rp {extracted.get('amount', 0):,.0f}")
            print(f"   📝 Description: {extracted.get('description', 'N/A')}")
            print(f"   🏷️  Category: {extracted.get('category_hint', 'N/A')}")
            return True
        else:
            print(f"\n❌ TEST GAGAL: {result.get('error', 'Unknown error')}")
            return False
            
    except FileNotFoundError:
        print(f"❌ File tidak ditemukan: {image_path}")
        return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Request error: {str(e)}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {str(e)}")
        return False


def test_scan_voice_audio():
    """
    Test endpoint: POST /api/finance/transactions/scan-voice/
    Menggunakan file audio rekaman suara
    """
    print_separator("TEST 2: Scan Voice Audio")
    
    # Path ke file audio test (format: mp3, wav, m4a, webm, dll)
    audio_path = Path(__file__).parent / "test_voice.mp3"
    
    if not audio_path.exists():
        print(f"⚠️  File audio tidak ditemukan: {audio_path}")
        print("   Silakan letakkan file audio dengan nama 'test_voice.mp3'")
        print("   di folder yang sama dengan script ini.")
        print("   Contoh isi audio: 'Saya beli makan siang lima puluh ribu rupiah'")
        return False
    
    try:
        # Buka file audio
        with open(audio_path, "rb") as audio_file:
            files = {
                "audio_file": ("voice.mp3", audio_file, "audio/mpeg")
            }
            
            # Kirim request ke API
            response = requests.post(
                f"{API_URL}/transactions/scan-voice/",
                headers=HEADERS,
                files=files,
                timeout=60  # Timeout lebih lama untuk processing audio
            )
        
        print(f"\n📤 Request URL: {response.url}")
        print(f"📥 Status Code: {response.status_code}")
        
        # Parse response
        result = response.json()
        print(f"\n📄 Response Body:")
        print(json.dumps(result, indent=2, ensure_ascii=False))
        
        if response.status_code == 200:
            print("\n✅ TEST BERHASIL: Audio suara berhasil dianalisis!")
            print(f"\n   🎤 Transcription: {result.get('transcription', 'N/A')}")
            
            extracted = result.get("extracted_data", {})
            print(f"\n   💰 Amount: Rp {extracted.get('amount', 0):,.0f}")
            print(f"   📝 Description: {extracted.get('description', 'N/A')}")
            print(f"   🏷️  Category: {extracted.get('category_hint', 'N/A')}")
            print(f"   📊 Type: {extracted.get('type', 'N/A')}")
            return True
        else:
            print(f"\n❌ TEST GAGAL: {result.get('error', 'Unknown error')}")
            return False
            
    except FileNotFoundError:
        print(f"❌ File tidak ditemukan: {audio_path}")
        return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Request error: {str(e)}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {str(e)}")
        return False


def test_chat_input_text():
    """
    Test endpoint: POST /api/finance/transactions/chat-input/
    Menggunakan input teks biasa
    """
    print_separator("TEST 3: Chat Input Text (Bonus)")
    
    # Test data
    test_messages = [
        "Tadi pagi saya beli nasi goreng 25 ribu",
        "Kemarin transfer gaji 5 juta rupiah",
        "Bayar parkir 5000"
    ]
    
    for idx, message in enumerate(test_messages, 1):
        print(f"\n--- Test Message {idx} ---")
        print(f"📝 Message: '{message}'")
        
        try:
            response = requests.post(
                f"{API_URL}/transactions/chat-input/",
                headers=HEADERS,
                json={"text": message},
                timeout=30
            )
            
            print(f"📥 Status Code: {response.status_code}")
            result = response.json()
            
            if response.status_code == 201:
                print("✅ Berhasil!")
                extracted = result.get("extracted_data", {})
                print(f"   💰 Amount: Rp {extracted.get('amount', 0):,.0f}")
                print(f"   📝 Description: {extracted.get('description', 'N/A')}")
                print(f"   🏷️  Category: {extracted.get('category_hint', 'N/A')}")
                print(f"   📅 Date: {extracted.get('date', 'N/A')}")
            else:
                print(f"❌ Gagal: {result.get('error', 'Unknown error')}")
                
        except Exception as e:
            print(f"❌ Error: {str(e)}")
    
    return True


def check_server_running():
    """Cek apakah Django server sedang berjalan"""
    print_separator("Checking Django Server")
    
    try:
        response = requests.get(BASE_URL, timeout=5)
        print(f"✅ Server berjalan di {BASE_URL}")
        return True
    except requests.exceptions.RequestException:
        print(f"❌ Server tidak berjalan di {BASE_URL}")
        print("   Jalankan server dengan: python manage.py runserver")
        return False


def main():
    """Main function untuk menjalankan semua test"""
    print("\n" + "=" * 70)
    print("  🧪 TESTING API MULTIMODAL TRANSACTION")
    print("=" * 70)
    print("\n📌 Script ini akan menguji:")
    print("   1. Scan Receipt Image (gambar struk)")
    print("   2. Scan Voice Audio (rekaman suara)")
    print("   3. Chat Input Text (bonus - input teks biasa)")
    
    # Cek server
    if not check_server_running():
        return
    
    # Cek token
    if AUTH_TOKEN == "YOUR_AUTH_TOKEN_HERE":
        print("\n⚠️  WARNING: Anda belum mengatur AUTH_TOKEN!")
        print("   1. Login ke aplikasi untuk mendapatkan token")
        print("   2. Edit script ini dan ganti AUTH_TOKEN dengan token valid")
        print("\n   Atau jika tidak menggunakan autentikasi, hapus header Authorization")
        
        # Tanyakan apakah ingin lanjut tanpa auth
        response = input("\n   Lanjut tanpa autentikasi? (y/n): ")
        if response.lower() != 'y':
            return
        HEADERS.pop("Authorization", None)
    
    print("\n\n")
    
    # Jalankan test
    results = []
    
    # Test 1: Image
    results.append(("Scan Receipt Image", test_scan_receipt_image()))
    
    # Test 2: Voice
    results.append(("Scan Voice Audio", test_scan_voice_audio()))
    
    # Test 3: Text (bonus)
    results.append(("Chat Input Text", test_chat_input_text()))
    
    # Summary
    print_separator("TEST SUMMARY")
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"  {status}  {test_name}")
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    print(f"\n  Total: {passed}/{total} tests passed")
    print("=" * 70 + "\n")


if __name__ == "__main__":
    main()
