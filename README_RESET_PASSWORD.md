# 🔐 Quick Guide: Reset Password & Email OTP

## 🚀 Quick Start

### 1. Jalankan Migration
```bash
python manage.py migrate
```

### 2. Jalankan Server
```bash
python manage.py runserver
```

### 3. Test API
```bash
python test_reset_password_api.py
```

---

## 📋 API Endpoints Baru

### 1. **Request Password Reset**
```
POST /api/auth/request-password-reset/
Body: {"email": "user@example.com"}
```

### 2. **Reset Password**
```
POST /api/auth/reset-password/
Body: {
  "token": "uuid-token-from-email",
  "new_password": "newpass123",
  "confirm_password": "newpass123"
}
```

### 3. **Resend OTP**
```
POST /api/auth/resend-otp/
Body: {"email": "user@example.com"}
```

---

## 🎨 Fitur Email Baru

✅ **Template HTML Modern**
- Gradient headers yang menarik
- Responsive design
- Security warnings
- Tips keamanan

✅ **3 Jenis Email**
1. OTP Verification (Gradient Ungu)
2. Password Reset (Gradient Pink)
3. Password Changed Confirmation (Gradient Hijau)

---

## 🔧 Configuration Email

Edit `core/settings.py`:

```python
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'your-email@gmail.com'
EMAIL_HOST_PASSWORD = 'your-app-password'  # Gmail App Password
DEFAULT_FROM_EMAIL = 'ManKu App <noreply@manku.app>'
```

---

## 📚 Dokumentasi Lengkap

Lihat file: **`API_RESET_PASSWORD_DOCS.md`**

---

## ✅ Checklist

- [x] Model PasswordResetToken
- [x] Model OTPVerification (updated)
- [x] Email HTML templates
- [x] API endpoints
- [x] Database migration
- [x] Testing script
- [x] Dokumentasi

---

## 🧪 Testing

### Manual Testing
```bash
# 1. Register user
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Test","email":"test@example.com","password":"pass123"}'

# 2. Request reset password
curl -X POST http://127.0.0.1:8000/api/auth/request-password-reset/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'

# 3. Reset password (dengan token dari email)
curl -X POST http://127.0.0.1:8000/api/auth/reset-password/ \
  -H "Content-Type: application/json" \
  -d '{"token":"uuid-here","new_password":"newpass","confirm_password":"newpass"}'
```

### Automated Testing
```bash
python test_reset_password_api.py
```

---

## 📧 Troubleshooting

### Email tidak terkirim?
1. Cek settings.py untuk konfigurasi SMTP
2. Gunakan App Password untuk Gmail (bukan password biasa)
3. Cek spam folder
4. Lihat console Django untuk error

### Token tidak valid?
1. Token expired (max 1 jam)
2. Token sudah dipakai
3. Salah copy token dari email

### OTP expired?
1. OTP berlaku 10 menit
2. Gunakan endpoint resend-otp untuk mendapat OTP baru

---

**🎉 Selesai! API Reset Password siap digunakan.**

*Dibuat: 12 Juni 2026*
