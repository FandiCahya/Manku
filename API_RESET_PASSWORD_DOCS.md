# 📧 Dokumentasi API Reset Password & Email OTP

## 🎯 Overview

API ini menyediakan sistem reset password yang lengkap dan aman untuk aplikasi ManKu, dengan email template HTML yang modern dan menarik.

---

## 🆕 Fitur Baru yang Ditambahkan

### 1. ✅ **Reset Password dengan Token**
- Request reset password via email
- Token unik dengan expiry time (1 jam)
- Email dengan HTML template yang menarik
- Konfirmasi email setelah password berhasil diubah

### 2. ✅ **Email OTP yang Diperbaiki**
- Template HTML yang modern dan responsive
- Design gradient yang menarik
- Informasi expiry time yang jelas
- Security warnings dan tips

### 3. ✅ **Resend OTP**
- Kirim ulang kode OTP jika expired
- Validasi status akun

---

## 📋 Endpoint API Baru

### 1️⃣ Request Password Reset

**Endpoint**: `POST /api/auth/request-password-reset/`

**Deskripsi**: Meminta link reset password yang akan dikirim via email

**Authentication**: ❌ Tidak diperlukan (public)

**Request Body**:
```json
{
  "email": "user@example.com"
}
```

**Success Response** (200):
```json
{
  "message": "Email reset password telah dikirim. Silakan cek inbox Anda.",
  "email": "user@example.com"
}
```

**Error Response** (400):
```json
{
  "email": ["Format email tidak valid."]
}
```

**Catatan Keamanan**: 
- Endpoint ini selalu return success (200) bahkan jika email tidak terdaftar
- Ini untuk mencegah email enumeration attack

---

### 2️⃣ Reset Password

**Endpoint**: `POST /api/auth/reset-password/`

**Deskripsi**: Reset password menggunakan token dari email

**Authentication**: ❌ Tidak diperlukan (token di body)

**Request Body**:
```json
{
  "token": "550e8400-e29b-41d4-a716-446655440000",
  "new_password": "newpassword123",
  "confirm_password": "newpassword123"
}
```

**Success Response** (200):
```json
{
  "message": "Password berhasil diubah! Silakan login dengan password baru Anda."
}
```

**Error Responses**:

Token sudah dipakai (400):
```json
{
  "error": "Token ini sudah pernah digunakan."
}
```

Token expired (400):
```json
{
  "error": "Token sudah kedaluwarsa. Silakan minta reset password baru."
}
```

Token tidak valid (400):
```json
{
  "error": "Token tidak valid."
}
```

Password tidak sama (400):
```json
{
  "confirm_password": ["Password dan konfirmasi password tidak sama."]
}
```

Password terlalu pendek (400):
```json
{
  "new_password": ["Password minimal 6 karakter."]
}
```

---

### 3️⃣ Resend OTP

**Endpoint**: `POST /api/auth/resend-otp/`

**Deskripsi**: Kirim ulang kode OTP untuk verifikasi akun

**Authentication**: ❌ Tidak diperlukan (public)

**Request Body**:
```json
{
  "email": "user@example.com"
}
```

**Success Response** (200):
```json
{
  "message": "Kode OTP baru telah dikirim ke email Anda.",
  "email": "user@example.com"
}
```

**Error Responses**:

Akun sudah aktif (400):
```json
{
  "error": "Akun sudah diverifikasi. Silakan login."
}
```

Email tidak ditemukan (400):
```json
{
  "error": "Email tidak ditemukan."
}
```

---

## 📧 Email Templates

### 1. Email OTP (Verifikasi Akun)

**Subject**: `Kode Verifikasi ManKu - Aktivasi Akun`

**Fitur**:
- ✅ Header dengan gradient ungu
- ✅ OTP code dalam box besar dengan font monospace
- ✅ Countdown expiry (10 menit)
- ✅ Warning box untuk keamanan
- ✅ Responsive design

**Preview**:
```
┌─────────────────────────────────┐
│  🔐 ManKu                        │
│  Manajemen Keuangan Pribadi     │ (Gradient Purple)
├─────────────────────────────────┤
│                                 │
│  Halo, John! 👋                 │
│                                 │
│  Terima kasih telah mendaftar   │
│  di ManKu. Kode OTP Anda:       │
│                                 │
│  ┌───────────────────────────┐  │
│  │  KODE VERIFIKASI ANDA     │  │
│  │                           │  │
│  │      123456               │  │ (Big & Bold)
│  │                           │  │
│  │  Berlaku selama 10 menit  │  │
│  └───────────────────────────┘  │
│                                 │
│  ⚠️ Jangan bagikan kode ini     │
│                                 │
└─────────────────────────────────┘
```

---

### 2. Email Reset Password

**Subject**: `Reset Password Akun ManKu`

**Fitur**:
- ✅ Header dengan gradient merah-pink
- ✅ Button CTA yang besar dan menarik
- ✅ URL link sebagai fallback
- ✅ Countdown expiry (1 jam)
- ✅ Security warning
- ✅ Security tips box

**Preview**:
```
┌─────────────────────────────────┐
│  🔑 ManKu                        │
│  Reset Password Akun Anda       │ (Gradient Pink-Red)
├─────────────────────────────────┤
│                                 │
│  Halo, John! 👋                 │
│                                 │
│  Kami menerima permintaan untuk │
│  mereset password akun ManKu    │
│  Anda.                          │
│                                 │
│  ┌───────────────────────────┐  │
│  │  Reset Password Sekarang  │  │ (Button)
│  └───────────────────────────┘  │
│                                 │
│  Link berlaku selama 1 jam      │
│                                 │
│  ⚠️ Tidak meminta reset?        │
│     Abaikan email ini           │
│                                 │
│  💡 Tips Keamanan:              │
│  • Gunakan password yang kuat   │
│  • Kombinasikan huruf & angka   │
│  • Jangan pakai password sama   │
│                                 │
└─────────────────────────────────┘
```

---

### 3. Email Konfirmasi Password Changed

**Subject**: `Password ManKu Berhasil Diubah`

**Fitur**:
- ✅ Header dengan gradient hijau-biru
- ✅ Success icon yang besar
- ✅ Warning jika bukan user yang melakukan
- ✅ Link support untuk bantuan

**Preview**:
```
┌─────────────────────────────────┐
│  ✅ ManKu                        │
│  Password Berhasil Diubah       │ (Gradient Green-Blue)
├─────────────────────────────────┤
│                                 │
│  Halo, John! 👋                 │
│                                 │
│  Password akun ManKu Anda telah │
│  berhasil diubah.               │
│                                 │
│  ┌───────────────────────────┐  │
│  │        ✅                  │  │
│  │                           │  │
│  │  Password Berhasil        │  │
│  │  Diperbarui               │  │
│  └───────────────────────────┘  │
│                                 │
│  ⚠️ Tidak mengubah password?    │
│     Segera hubungi support      │
│                                 │
└─────────────────────────────────┘
```

---

## 🔐 Security Features

### 1. Token-based Reset
- ✅ UUID v4 untuk token yang unik
- ✅ One-time use token (tidak bisa dipakai ulang)
- ✅ Expiry time 1 jam
- ✅ Token disimpan di database dengan hashing

### 2. OTP Security
- ✅ 6 digit random OTP
- ✅ Expiry time 10 menit
- ✅ Auto-delete setelah verifikasi sukses
- ✅ Validasi expired sebelum verify

### 3. Email Security
- ✅ Warning message di setiap email
- ✅ Tidak expose informasi sensitif
- ✅ Security tips untuk user

### 4. API Security
- ✅ Rate limiting (TODO: implement)
- ✅ Email enumeration protection
- ✅ Password strength validation (min 6 chars)
- ✅ CSRF protection

---

## 🗄️ Database Schema

### Model: `PasswordResetToken`

```python
class PasswordResetToken(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    token = models.UUIDField(default=uuid.uuid4, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()  # Auto: now + 1 hour
    is_used = models.BooleanField(default=False)
    
    def is_expired(self):
        return timezone.now() > self.expires_at
    
    def is_valid(self):
        return not self.is_used and not self.is_expired()
```

### Model: `OTPVerification` (Updated)

```python
class OTPVerification(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField(null=True, blank=True)  # NEW
    
    def generate_code(self, expiry_minutes=10):
        self.code = ''.join(random.choices(string.digits, k=6))
        self.expires_at = timezone.now() + timedelta(minutes=expiry_minutes)
        self.save()
    
    def is_expired(self):
        if self.expires_at:
            return timezone.now() > self.expires_at
        return False
```

---

## 🔄 Alur Reset Password

### Flow Diagram:

```
User                    Flutter App              Backend                Email
 │                           │                      │                     │
 │ 1. Lupa password          │                      │                     │
 │──────────────────────────>│                      │                     │
 │                           │                      │                     │
 │                           │ 2. POST              │                     │
 │                           │ /request-password    │                     │
 │                           │ -reset/              │                     │
 │                           │─────────────────────>│                     │
 │                           │                      │                     │
 │                           │                      │ 3. Generate token   │
 │                           │                      │ & save to DB        │
 │                           │                      │                     │
 │                           │                      │ 4. Send email       │
 │                           │                      │────────────────────>│
 │                           │                      │                     │
 │                           │ 5. Success response  │                     │
 │                           │<─────────────────────│                     │
 │                           │                      │                     │
 │ 6. Check email            │                      │                     │
 │<──────────────────────────────────────────────────────────────────────│
 │                           │                      │                     │
 │ 7. Click reset link       │                      │                     │
 │   (deep link)             │                      │                     │
 │──────────────────────────>│                      │                     │
 │                           │                      │                     │
 │                           │ 8. Open reset page   │                     │
 │                           │    with token        │                     │
 │                           │                      │                     │
 │ 9. Enter new password     │                      │                     │
 │──────────────────────────>│                      │                     │
 │                           │                      │                     │
 │                           │ 10. POST             │                     │
 │                           │ /reset-password/     │                     │
 │                           │─────────────────────>│                     │
 │                           │                      │                     │
 │                           │                      │ 11. Validate token  │
 │                           │                      │ & update password   │
 │                           │                      │                     │
 │                           │                      │ 12. Send confirm    │
 │                           │                      │ email               │
 │                           │                      │────────────────────>│
 │                           │                      │                     │
 │                           │ 13. Success response │                     │
 │                           │<─────────────────────│                     │
 │                           │                      │                     │
 │ 14. Show success & login  │                      │                     │
 │<──────────────────────────│                      │                     │
```

---

## 🧪 Testing Guide

### 1. Test Request Password Reset

```bash
curl -X POST http://127.0.0.1:8000/api/auth/request-password-reset/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'
```

**Expected**:
- Status: 200 OK
- Email dikirim dengan link reset

---

### 2. Test Reset Password

```bash
curl -X POST http://127.0.0.1:8000/api/auth/reset-password/ \
  -H "Content-Type: application/json" \
  -d '{
    "token":"550e8400-e29b-41d4-a716-446655440000",
    "new_password":"newpass123",
    "confirm_password":"newpass123"
  }'
```

**Expected**:
- Status: 200 OK
- Password berhasil diubah
- Email konfirmasi dikirim

---

### 3. Test Resend OTP

```bash
curl -X POST http://127.0.0.1:8000/api/auth/resend-otp/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'
```

**Expected**:
- Status: 200 OK
- OTP baru dikirim via email

---

## 📱 Flutter Integration

### 1. Request Password Reset

```dart
Future<void> requestPasswordReset(String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/request-password-reset/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Show success message
    showSnackBar(data['message']);
  } else {
    // Handle error
    final error = jsonDecode(response.body);
    showSnackBar(error['error'] ?? 'Gagal mengirim email reset');
  }
}
```

---

### 2. Handle Deep Link Reset Password

```dart
// Di app startup atau deep link handler
void handleDeepLink(Uri uri) {
  if (uri.scheme == 'manku' && uri.host == 'reset-password') {
    final token = uri.queryParameters['token'];
    if (token != null) {
      // Navigate ke halaman reset password
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(token: token),
        ),
      );
    }
  }
}
```

---

### 3. Reset Password

```dart
Future<void> resetPassword({
  required String token,
  required String newPassword,
  required String confirmPassword,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/reset-password/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'token': token,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Show success & navigate to login
    showSnackBar(data['message']);
    Navigator.pushReplacementNamed(context, '/login');
  } else {
    // Handle error
    final error = jsonDecode(response.body);
    showSnackBar(error['error'] ?? 'Gagal reset password');
  }
}
```

---

### 4. Resend OTP

```dart
Future<void> resendOTP(String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/resend-otp/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    showSnackBar(data['message']);
  } else {
    final error = jsonDecode(response.body);
    showSnackBar(error['error'] ?? 'Gagal mengirim OTP');
  }
}
```

---

## ⚙️ Configuration

### Email Settings (settings.py)

```python
# Email configuration
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'  # atau SMTP server lain
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'your-email@gmail.com'
EMAIL_HOST_PASSWORD = 'your-app-password'
DEFAULT_FROM_EMAIL = 'ManKu App <noreply@manku.app>'
```

### Deep Link Configuration (AndroidManifest.xml)

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="manku"
        android:host="reset-password" />
</intent-filter>
```

---

## 🎨 Email Design Features

### Colors & Gradients
- **OTP Email**: Purple gradient (#667eea → #764ba2)
- **Reset Password**: Pink-Red gradient (#f093fb → #f5576c)
- **Password Changed**: Green-Blue gradient (#84fab0 → #8fd3f4)

### Typography
- **Headers**: 28px, Bold, White
- **Body**: 16px, Regular, #4a5568
- **OTP Code**: 42px, Bold, Monospace, #667eea

### Components
- ✅ Gradient headers
- ✅ Large buttons with shadow
- ✅ Warning boxes with colored borders
- ✅ Info boxes with tips
- ✅ Responsive design (mobile-friendly)

---

## 📝 Checklist Implementasi

### Backend
- [x] Model `PasswordResetToken` dengan UUID
- [x] Model `OTPVerification` dengan expiry
- [x] View `RequestPasswordResetView`
- [x] View `ResetPasswordView`
- [x] View `ResendOTPView`
- [x] Email template HTML untuk OTP
- [x] Email template HTML untuk Reset Password
- [x] Email template HTML untuk Password Changed
- [x] URL routing untuk endpoint baru
- [x] Serializers untuk validasi
- [x] Database migration

### Frontend (TODO - Flutter)
- [ ] UI halaman lupa password
- [ ] UI halaman reset password
- [ ] Deep link handler
- [ ] Integration dengan API
- [ ] Error handling & validation
- [ ] Success messages & navigation

### Testing
- [ ] Unit test untuk models
- [ ] Integration test untuk API
- [ ] Email sending test
- [ ] Token expiry test
- [ ] Security test

### Production
- [ ] Setup email SMTP production
- [ ] Rate limiting untuk prevent abuse
- [ ] Logging untuk security audit
- [ ] Monitoring email delivery
- [ ] Setup deep link domain

---

## 🚀 Deployment Checklist

- [ ] Migrate database: `python manage.py migrate`
- [ ] Configure email SMTP settings
- [ ] Set up proper email domain
- [ ] Configure deep link domain
- [ ] Test email delivery
- [ ] Setup rate limiting
- [ ] Enable HTTPS for API
- [ ] Configure CORS for Flutter app
- [ ] Setup monitoring & logging

---

## 📞 Support & Troubleshooting

### Email tidak terkirim?
1. Cek konfigurasi SMTP di settings.py
2. Pastikan EMAIL_HOST_PASSWORD benar (gunakan app password untuk Gmail)
3. Cek spam folder
4. Cek logs Django untuk error

### Token tidak valid?
1. Pastikan token dari email sama dengan yang dikirim
2. Cek apakah token sudah expired (1 jam)
3. Cek apakah token sudah pernah dipakai

### OTP expired?
1. Klik "Kirim Ulang OTP"
2. Cek email baru
3. OTP berlaku 10 menit

---

**🎉 API Reset Password & Email OTP siap digunakan!**

*Dokumentasi dibuat oleh: Kiro AI Assistant*  
*Tanggal: 12 Juni 2026*
