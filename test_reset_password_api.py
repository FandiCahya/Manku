"""
Script Testing untuk API Reset Password & Email OTP
"""
import requests
import json
from time import sleep

BASE_URL = "http://127.0.0.1:8000"
API_URL = f"{BASE_URL}/api/auth"

def print_header(title):
    """Print header untuk section"""
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70 + "\n")

def print_response(response):
    """Print response dengan format yang bagus"""
    print(f"📥 Status Code: {response.status_code}")
    try:
        data = response.json()
        print(f"📄 Response:")
        print(json.dumps(data, indent=2, ensure_ascii=False))
    except:
        print(f"📄 Response: {response.text[:200]}")

# ══════════════════════════════════════════════════════════════════════════════
# TEST DATA
# ══════════════════════════════════════════════════════════════════════════════

TEST_USER = {
    "first_name": "Test User",
    "email": "testuser@example.com",
    "password": "testpass123"
}

# ══════════════════════════════════════════════════════════════════════════════
# TEST FUNCTIONS
# ══════════════════════════════════════════════════════════════════════════════

def test_1_register():
    """Test 1: Register user baru"""
    print_header("TEST 1: Register User Baru")
    
    response = requests.post(
        f"{API_URL}/register/",
        json=TEST_USER
    )
    
    print_response(response)
    
    if response.status_code == 201:
        print("\n✅ Registrasi berhasil!")
        print("📧 Cek email untuk kode OTP")
        return True
    elif response.status_code == 400:
        data = response.json()
        if "sudah terdaftar" in data.get("error", ""):
            print("\n⚠️  Email sudah terdaftar, lanjut ke test berikutnya")
            return True
    else:
        print("\n❌ Registrasi gagal!")
        return False

def test_2_resend_otp():
    """Test 2: Resend OTP"""
    print_header("TEST 2: Resend OTP")
    
    print(f"📧 Email: {TEST_USER['email']}")
    
    response = requests.post(
        f"{API_URL}/resend-otp/",
        json={"email": TEST_USER["email"]}
    )
    
    print_response(response)
    
    if response.status_code == 200:
        print("\n✅ OTP baru berhasil dikirim!")
        print("📧 Cek email untuk kode OTP baru")
        return True
    else:
        print("\n❌ Gagal kirim OTP!")
        return False

def test_3_verify_otp():
    """Test 3: Verify OTP (manual input)"""
    print_header("TEST 3: Verify OTP")
    
    print(f"📧 Email: {TEST_USER['email']}")
    print("\n⚠️  Silakan cek email Anda dan masukkan kode OTP:")
    
    otp_code = input("Masukkan kode OTP (6 digit): ").strip()
    
    if not otp_code or len(otp_code) != 6:
        print("\n❌ Kode OTP harus 6 digit!")
        return False
    
    response = requests.post(
        f"{API_URL}/verify-otp/",
        json={
            "email": TEST_USER["email"],
            "code": otp_code
        }
    )
    
    print_response(response)
    
    if response.status_code == 200:
        print("\n✅ Verifikasi berhasil!")
        data = response.json()
        access_token = data.get("tokens", {}).get("access")
        if access_token:
            print(f"\n🔑 Access Token (simpan ini):")
            print(access_token[:50] + "...")
        return True
    else:
        print("\n❌ Verifikasi gagal!")
        return False

def test_4_request_password_reset():
    """Test 4: Request password reset"""
    print_header("TEST 4: Request Password Reset")
    
    print(f"📧 Email: {TEST_USER['email']}")
    
    response = requests.post(
        f"{API_URL}/request-password-reset/",
        json={"email": TEST_USER["email"]}
    )
    
    print_response(response)
    
    if response.status_code == 200:
        print("\n✅ Request berhasil!")
        print("📧 Cek email untuk link reset password")
        return True
    else:
        print("\n❌ Request gagal!")
        return False

def test_5_reset_password():
    """Test 5: Reset password dengan token"""
    print_header("TEST 5: Reset Password")
    
    print("⚠️  Silakan cek email Anda untuk link reset password")
    print("    Format: manku://reset-password?token=...")
    print("\n📝 Salin token dari email (atau dari database)")
    
    token = input("Masukkan token UUID: ").strip()
    
    if not token:
        print("\n❌ Token tidak boleh kosong!")
        return False
    
    new_password = "newpassword123"
    
    response = requests.post(
        f"{API_URL}/reset-password/",
        json={
            "token": token,
            "new_password": new_password,
            "confirm_password": new_password
        }
    )
    
    print_response(response)
    
    if response.status_code == 200:
        print("\n✅ Password berhasil direset!")
        print(f"🔑 Password baru: {new_password}")
        print("📧 Cek email untuk konfirmasi")
        
        # Update password di TEST_USER
        TEST_USER["password"] = new_password
        return True
    else:
        print("\n❌ Reset password gagal!")
        return False

def test_6_login_with_new_password():
    """Test 6: Login dengan password baru"""
    print_header("TEST 6: Login dengan Password Baru")
    
    print(f"📧 Email: {TEST_USER['email']}")
    print(f"🔑 Password: {TEST_USER['password']}")
    
    response = requests.post(
        f"{API_URL}/login/",
        json={
            "email": TEST_USER["email"],
            "password": TEST_USER["password"]
        }
    )
    
    print_response(response)
    
    if response.status_code == 200:
        print("\n✅ Login berhasil dengan password baru!")
        data = response.json()
        access_token = data.get("tokens", {}).get("access")
        if access_token:
            print(f"\n🔑 Access Token:")
            print(access_token[:50] + "...")
        return True
    else:
        print("\n❌ Login gagal!")
        return False

# ══════════════════════════════════════════════════════════════════════════════
# MENU INTERAKTIF
# ══════════════════════════════════════════════════════════════════════════════

def show_menu():
    """Tampilkan menu testing"""
    print("\n" + "=" * 70)
    print("  🧪 TESTING API RESET PASSWORD & EMAIL OTP")
    print("=" * 70)
    print("\n📌 Test yang tersedia:")
    print("  1. Register User Baru")
    print("  2. Resend OTP")
    print("  3. Verify OTP")
    print("  4. Request Password Reset")
    print("  5. Reset Password dengan Token")
    print("  6. Login dengan Password Baru")
    print("  7. Run All Tests (Sequential)")
    print("  0. Exit")
    print("\n" + "=" * 70)

def run_all_tests():
    """Jalankan semua test secara sequential"""
    print_header("🚀 Running All Tests")
    
    results = []
    
    # Test 1: Register
    result = test_1_register()
    results.append(("Register", result))
    if not result:
        print("\n⚠️  Test dihentikan karena registrasi gagal")
        return results
    
    sleep(2)
    
    # Test 2: Resend OTP
    result = test_2_resend_otp()
    results.append(("Resend OTP", result))
    
    sleep(2)
    
    # Test 3: Verify OTP (butuh manual input)
    print("\n⏸️  Test dilanjutkan dengan manual input...")
    result = test_3_verify_otp()
    results.append(("Verify OTP", result))
    
    if not result:
        print("\n⚠️  Test dihentikan karena verifikasi gagal")
        return results
    
    sleep(2)
    
    # Test 4: Request Password Reset
    result = test_4_request_password_reset()
    results.append(("Request Reset", result))
    
    sleep(2)
    
    # Test 5: Reset Password (butuh manual input token)
    print("\n⏸️  Test dilanjutkan dengan manual input...")
    result = test_5_reset_password()
    results.append(("Reset Password", result))
    
    if not result:
        print("\n⚠️  Test dihentikan karena reset gagal")
        return results
    
    sleep(2)
    
    # Test 6: Login with new password
    result = test_6_login_with_new_password()
    results.append(("Login New Pass", result))
    
    return results

def print_summary(results):
    """Print summary hasil testing"""
    print_header("📊 TEST SUMMARY")
    
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"  {status}  {test_name}")
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    print(f"\n  Total: {passed}/{total} tests passed")
    print("=" * 70 + "\n")

def main():
    """Main function"""
    # Cek server
    try:
        requests.get(BASE_URL, timeout=5)
        print(f"✅ Server berjalan di {BASE_URL}")
    except:
        print(f"❌ Server tidak berjalan di {BASE_URL}")
        print("   Jalankan: python manage.py runserver")
        return
    
    while True:
        show_menu()
        choice = input("Pilih menu (0-7): ").strip()
        
        if choice == "0":
            print("\n👋 Terima kasih!\n")
            break
        elif choice == "1":
            test_1_register()
        elif choice == "2":
            test_2_resend_otp()
        elif choice == "3":
            test_3_verify_otp()
        elif choice == "4":
            test_4_request_password_reset()
        elif choice == "5":
            test_5_reset_password()
        elif choice == "6":
            test_6_login_with_new_password()
        elif choice == "7":
            results = run_all_tests()
            print_summary(results)
        else:
            print("\n❌ Pilihan tidak valid!")
        
        input("\nTekan Enter untuk kembali ke menu...")

if __name__ == "__main__":
    main()
