# Setup Halaman Login & Register dengan Firebase

Saya telah membuat sistem authentication lengkap untuk aplikasi My Manage dengan fitur:
- ✅ Login dengan email & password
- ✅ Login dengan Google  
- ✅ Register akun baru dengan validasi
- ✅ Email verification otomatis
- ✅ Resend email verification
- ✅ Auto-check email verification status

## File yang Telah Dibuat

### 1. **Auth Service** (`lib/services/auth_service.dart`)
- Firebase Authentication service
- Google Sign-In integration
- Email verification handling
- Session management

### 2. **Login Page** (`lib/pages/login_page.dart`)
- Login dengan email & password
- Login dengan Google
- Error handling & validation
- Link ke halaman register

### 3. **Register Page** (`lib/pages/register_page.dart`)
- Form registrasi lengkap (Nama, Email, Password, Konfirmasi Password)
- Validasi password (minimal 6 karakter)
- Terms & conditions checkbox
- Daftar dengan Google
- Link ke halaman login

### 4. **Email Verification Page** (`lib/pages/email_verification_page.dart`)
- Auto-check email verification setiap 3 detik
- Manual verification check
- Resend email verification (dengan countdown 60 detik)
- Clear instructions untuk user
- Opsi gunakan email lain

### 5. **Firebase Options** (`lib/firebase_options.dart`)
- Template konfigurasi Firebase untuk semua platform

## Dependency yang Ditambahkan

```yaml
firebase_core: ^3.0.0      # Firebase core
firebase_auth: ^5.0.0      # Firebase Authentication
google_sign_in: ^6.2.0     # Google Sign-In
go_router: ^14.0.0         # Routing (untuk navigasi yang lebih baik)
```

## Setup Steps

### Step 1: Firebase Project Setup

1. **Buat Firebase Project**
   - Buka [Firebase Console](https://console.firebase.google.com/)
   - Klik "Add Project"
   - Ikuti langkah-langkahnya

2. **Enable Authentication Methods**
   - Di Firebase Console → Authentication → Sign-in method
   - Enable "Email/Password"
   - Enable "Google"

3. **Setup untuk Android**
   - Download `google-services.json` dari Firebase Console
   - Letakkan di: `android/app/`
   - File ini sudah disiapkan oleh Flutter setup, tinggal replace dengan yang dari Firebase

4. **Setup untuk iOS**
   - Download `GoogleService-Info.plist` dari Firebase Console
   - Buka Xcode: `open ios/Runner.xcworkspace`
   - Drag & drop file ke Xcode (pastikan "Copy items if needed" ter-check)
   - Pilih target: Runner

### Step 2: Update Firebase Options

Edit file `lib/firebase_options.dart` dan isikan credentials Firebase Anda untuk setiap platform:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY_FROM_FIREBASE',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  databaseURL: 'YOUR_DATABASE_URL',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);
// ... dan seterusnya untuk platform lain
```

### Step 3: Setup Google Sign-In

#### Android Setup:

1. **Dapatkan SHA-1 Certificate Fingerprint**
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy SHA-1 dari "debug key certificate"

2. **Add to Firebase Console**
   - Firebase Console → Project Settings → Your App (Android)
   - Paste SHA-1 ke "SHA certificate fingerprints"
   - Download `google-services.json` yang updated
   - Replace file di `android/app/`

#### iOS Setup:

1. **Update Info.plist**
   - Xcode → Runner → Info → URL Types
   - Tambah URL Scheme dari Firebase (lihat Firebase Console → Project Settings)

2. **Add GoogleService-Info.plist** (sudah dijelaskan di atas)

#### Web Setup (jika diperlukan):

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  appId: 'YOUR_WEB_APP_ID',
);
```

### Step 4: Update main.dart

File `lib/main.dart` sudah di-update dengan:
- Firebase initialization
- StreamBuilder untuk listen auth state
- Conditional routing (login page atau home page)

### Step 5: Jalankan Aplikasi

```bash
# Install dependencies
flutter pub get

# Run aplikasi
flutter run
```

## Fitur Navigation

### Auth Flow:

1. **Belum Login** → Login Page
   - Masuk dengan Email
   - Masuk dengan Google
   - Daftar ke Register Page

2. **Register** → Email Verification Page
   - Auto-check setiap 3 detik
   - Bisa manual check
   - Resend email verification
   - Gunakan email lain

3. **Email Verified** → Home Page
   - Aplikasi berfungsi normal
   - Bisa logout dari menu profile

## Troubleshooting

### Google Sign-In tidak bekerja di Android
- ❌ Pastikan SHA-1 certificate sudah ditambahkan ke Firebase Console
- ❌ Pastikan `google-services.json` sudah di-download dan di-update

### Email tidak terkirim
- ❌ Cek Firebase Console → Authentication → Templates
- ❌ Pastikan email sender sudah ter-setup dengan benar
- ❌ Cek folder Spam

### "User tidak ditemukan" saat login
- ❌ Pastikan email sudah terdaftar
- ❌ Case-sensitive? Coba dengan huruf kecil

## Customization

### Ubah Theme Login Page
Edit colors di `lib/constants/colors.dart`:
- Primary color untuk button
- Secondary color untuk accent
- Background color

### Ubah Error Messages
Edit string error di setiap page (login_page.dart, register_page.dart, dll)

### Tambah Validasi Custom
Edit fungsi `_handleLogin()` dan `_handleRegister()` di masing-masing page

## Security Notes

⚠️ **PENTING:**
1. Jangan hardcode Firebase credentials di aplikasi
2. Setup Firebase Security Rules di Firestore/Realtime Database
3. Aktifkan "One account per email" di Firebase Authentication settings
4. Enable CAPTCHA untuk prevent brute-force attacks
5. Setup email verification expiration time sesuai kebutuhan

## File Structure

```
lib/
├── services/
│   └── auth_service.dart          # Authentication logic
├── pages/
│   ├── login_page.dart            # Login UI
│   ├── register_page.dart         # Register UI
│   ├── email_verification_page.dart # Verification UI
│   ├── index.dart                 # Export all pages
│   └── ... (existing pages)
├── firebase_options.dart          # Firebase configuration
└── main.dart                      # App entry point (updated)
```

## Next Steps (Optional)

1. **Tambah Forgot Password Page**
   - Reset password functionality
   - Recovery email instructions

2. **Tambah Profile Setup Page**
   - After email verification
   - User data collection (phone, address, etc.)

3. **Tambah Two-Factor Authentication (2FA)**
   - SMS verification
   - Authenticator app support

4. **Tambah Social Login Options**
   - Facebook login
   - Apple Sign-In (untuk iOS)

---

Untuk pertanyaan atau masalah, lihat [Firebase Documentation](https://firebase.flutter.dev/)
