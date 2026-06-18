"""
Script untuk mendapatkan JWT Token untuk testing
"""
import requests
import json

BASE_URL = "http://127.0.0.1:8000"

def register_user(username, email, password):
    """Register user baru"""
    print(f"\n📝 Registering user: {username}")
    
    response = requests.post(
        f"{BASE_URL}/api/auth/register/",
        json={
            "username": username,
            "email": email,
            "password": password
        }
    )
    
    if response.status_code in [200, 201]:
        print(f"✅ User berhasil didaftarkan")
        return True
    else:
        print(f"⚠️  Registrasi gagal: {response.status_code}")
        try:
            print(f"   {response.json()}")
        except:
            print(f"   {response.text}")
        return False

def login_user(username, password):
    """Login dan dapatkan token"""
    print(f"\n🔐 Login as: {username}")
    
    response = requests.post(
        f"{BASE_URL}/api/auth/login/",
        json={
            "username": username,
            "password": password
        }
    )
    
    if response.status_code == 200:
        data = response.json()
        access_token = data.get('access')
        refresh_token = data.get('refresh')
        
        print(f"✅ Login berhasil!")
        print(f"\n📋 Token Information:")
        print(f"─" * 70)
        print(f"Access Token:")
        print(f"{access_token}")
        print(f"\nRefresh Token:")
        print(f"{refresh_token}")
        print(f"─" * 70)
        
        # Simpan ke file
        with open("auth_token.txt", "w") as f:
            f.write(f"ACCESS_TOKEN={access_token}\n")
            f.write(f"REFRESH_TOKEN={refresh_token}\n")
        
        print(f"\n💾 Token disimpan ke file: auth_token.txt")
        
        return access_token
    else:
        print(f"❌ Login gagal: {response.status_code}")
        try:
            print(f"   {response.json()}")
        except:
            print(f"   {response.text}")
        return None

def main():
    print("=" * 70)
    print("  🔑 GET AUTHENTICATION TOKEN")
    print("=" * 70)
    
    # Cek server
    try:
        requests.get(BASE_URL, timeout=5)
        print(f"✅ Server berjalan di {BASE_URL}")
    except:
        print(f"❌ Server tidak berjalan!")
        print("   Jalankan: python manage.py runserver")
        return
    
    # Test credentials
    username = "testuser"
    email = "test@example.com"
    password = "testpass123"
    
    print(f"\n📌 Test Credentials:")
    print(f"   Username: {username}")
    print(f"   Email   : {email}")
    print(f"   Password: {password}")
    
    # Coba register (jika belum ada user)
    register_user(username, email, password)
    
    # Login dan dapatkan token
    token = login_user(username, password)
    
    if token:
        print("\n✅ SUCCESS! Anda sekarang bisa menggunakan token untuk testing.")
        print("\n📝 Cara menggunakan:")
        print("   1. Copy access token di atas")
        print("   2. Edit file quick_test_api.py")
        print("   3. Set variable AUTH_TOKEN dengan access token")
        print("   4. Jalankan: python quick_test_api.py")
        print("\n   Atau gunakan token dari file auth_token.txt")
    else:
        print("\n❌ Gagal mendapatkan token")
        print("   Pastikan endpoint /api/auth/login/ berfungsi dengan benar")
    
    print("\n" + "=" * 70 + "\n")

if __name__ == "__main__":
    main()
