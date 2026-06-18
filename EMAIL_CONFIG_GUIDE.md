# 📧 Panduan Konfigurasi Email untuk ManKu

## 🎯 Overview

Panduan ini akan membantu Anda mengkonfigurasi email untuk fitur OTP dan Reset Password di aplikasi ManKu.

---

## 📋 Pilihan Provider Email

### 1. Gmail (Recommended untuk Development)
- ✅ Gratis
- ✅ Mudah setup
- ✅ Reliable
- ⚠️ Limit: 500 email/hari

### 2. SendGrid
- ✅ 100 email/hari gratis
- ✅ Reliable delivery
- ✅ Good for production

### 3. Mailgun
- ✅ 5000 email/bulan gratis
- ✅ Developer-friendly
- ✅ Good analytics

### 4. AWS SES
- ✅ Pay as you go
- ✅ Scalable
- ✅ Best for production

---

## 🔧 Konfigurasi Gmail (Development)

### Step 1: Enable 2-Factor Authentication

1. Buka [Google Account](https://myaccount.google.com/)
2. Pilih **Security**
3. Enable **2-Step Verification**

### Step 2: Generate App Password

1. Buka [App Passwords](https://myaccount.google.com/apppasswords)
2. Select app: **Mail**
3. Select device: **Other (Custom name)**
4. Input name: **ManKu Django**
5. Click **Generate**
6. Copy 16-digit password (tanpa spasi)

### Step 3: Update Django Settings

Edit `core/settings.py`:

```python
# ══════════════════════════════════════════════════════════════════════════════
# EMAIL CONFIGURATION
# ══════════════════════════════════════════════════════════════════════════════

EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'your-email@gmail.com'  # Ganti dengan email Anda
EMAIL_HOST_PASSWORD = 'xxxx xxxx xxxx xxxx'  # App password 16 digit
DEFAULT_FROM_EMAIL = 'ManKu App <your-email@gmail.com>'
SERVER_EMAIL = DEFAULT_FROM_EMAIL
```

### Step 4: Update .env File (Recommended)

Edit `.env`:

```env
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=xxxxxxxxxxxxxxxx
DEFAULT_FROM_EMAIL=ManKu App <your-email@gmail.com>
```

Update `settings.py`:

```python
import os
from dotenv import load_dotenv

load_dotenv()

EMAIL_HOST_USER = os.getenv('EMAIL_HOST_USER')
EMAIL_HOST_PASSWORD = os.getenv('EMAIL_HOST_PASSWORD')
DEFAULT_FROM_EMAIL = os.getenv('DEFAULT_FROM_EMAIL')
```

---

## 🧪 Testing Email Configuration

### Option 1: Django Shell

```bash
python manage.py shell
```

```python
from django.core.mail import send_mail

send_mail(
    subject='Test Email ManKu',
    message='Ini adalah test email dari ManKu.',
    from_email='ManKu App <your-email@gmail.com>',
    recipient_list=['recipient@example.com'],
    fail_silently=False,
)
```

### Option 2: Test Script

Buat file `test_email.py`:

```python
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from django.core.mail import send_mail

print("Mengirim test email...")
try:
    send_mail(
        subject='Test Email ManKu',
        message='Email configuration berhasil!',
        from_email='ManKu App <your-email@gmail.com>',
        recipient_list=['your-email@gmail.com'],
        fail_silently=False,
    )
    print("✅ Email berhasil dikirim!")
except Exception as e:
    print(f"❌ Error: {str(e)}")
```

Jalankan:
```bash
python test_email.py
```

---

## 🚀 Konfigurasi SendGrid (Production)

### Step 1: Daftar SendGrid

1. Buka [SendGrid](https://sendgrid.com/)
2. Sign up untuk free account
3. Verify email Anda

### Step 2: Create API Key

1. Buka **Settings > API Keys**
2. Click **Create API Key**
3. Name: **ManKu Django**
4. Permissions: **Full Access**
5. Copy API Key

### Step 3: Install Package

```bash
pip install sendgrid
```

### Step 4: Update Settings

```python
# settings.py
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.sendgrid.net'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'apikey'  # Harus 'apikey'
EMAIL_HOST_PASSWORD = 'SG.xxxxx...'  # SendGrid API Key
DEFAULT_FROM_EMAIL = 'ManKu App <noreply@manku.app>'
```

---

## 🔥 Konfigurasi Mailgun (Production)

### Step 1: Daftar Mailgun

1. Buka [Mailgun](https://www.mailgun.com/)
2. Sign up untuk free tier
3. Verify domain (atau gunakan sandbox domain)

### Step 2: Get SMTP Credentials

1. Buka **Sending > Domain Settings**
2. Select your domain
3. Copy **SMTP credentials**

### Step 3: Update Settings

```python
# settings.py
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.mailgun.org'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'postmaster@your-domain.mailgun.org'
EMAIL_HOST_PASSWORD = 'your-mailgun-password'
DEFAULT_FROM_EMAIL = 'ManKu App <noreply@your-domain.com>'
```

---

## ☁️ Konfigurasi AWS SES (Production)

### Step 1: Setup AWS SES

1. Login ke AWS Console
2. Buka **Amazon SES**
3. Verify email atau domain
4. Request production access (keluar dari sandbox)

### Step 2: Create SMTP Credentials

1. Buka **SMTP Settings**
2. Click **Create SMTP Credentials**
3. Download credentials

### Step 3: Install Boto3

```bash
pip install boto3
```

### Step 4: Update Settings

```python
# settings.py
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'email-smtp.us-east-1.amazonaws.com'  # Sesuaikan region
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'AKIAXXXXXXXXXXXXX'  # AWS SMTP username
EMAIL_HOST_PASSWORD = 'xxxxxxxxxxxxxxxxxxx'  # AWS SMTP password
DEFAULT_FROM_EMAIL = 'ManKu App <noreply@manku.app>'
```

---

## 🛠️ Troubleshooting

### Issue: "SMTPAuthenticationError"

**Penyebab**: Kredensial email salah

**Solusi**:
- Cek EMAIL_HOST_USER dan EMAIL_HOST_PASSWORD
- Untuk Gmail: pastikan menggunakan App Password, bukan password biasa
- Cek apakah 2FA sudah diaktifkan (Gmail)

---

### Issue: Email tidak sampai

**Solusi**:
1. Cek spam folder
2. Verify email sender di provider
3. Cek domain reputation
4. Test dengan email berbeda

---

### Issue: "SMTPServerDisconnected"

**Penyebab**: Connection error ke SMTP server

**Solusi**:
- Cek EMAIL_HOST dan EMAIL_PORT
- Cek firewall/network
- Cek EMAIL_USE_TLS = True

---

### Issue: Rate limit exceeded

**Solusi**:
- Gmail: Max 500 email/hari
- Upgrade ke paid plan
- Gunakan provider lain

---

## 🔒 Security Best Practices

### 1. Jangan Hardcode Credentials

❌ **JANGAN**:
```python
EMAIL_HOST_PASSWORD = 'mypassword123'
```

✅ **LAKUKAN**:
```python
EMAIL_HOST_PASSWORD = os.getenv('EMAIL_HOST_PASSWORD')
```

### 2. Gunakan .env File

```env
# .env
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=xxxxxxxxxxxx
```

Tambahkan ke `.gitignore`:
```
.env
*.env
```

### 3. Different Config untuk Development & Production

```python
# settings.py
if DEBUG:
    # Development
    EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
else:
    # Production
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    # ... other settings
```

---

## 📊 Email Limits Comparison

| Provider   | Free Tier       | Delivery Rate | Setup Difficulty |
|-----------|-----------------|---------------|------------------|
| Gmail     | 500/day         | Good          | Easy ⭐⭐⭐       |
| SendGrid  | 100/day         | Excellent     | Medium ⭐⭐       |
| Mailgun   | 5000/month      | Excellent     | Medium ⭐⭐       |
| AWS SES   | 62,000/month    | Excellent     | Hard ⭐          |

---

## ✅ Checklist Setup Email

- [ ] Pilih email provider
- [ ] Generate credentials/API key
- [ ] Update settings.py dengan config email
- [ ] Pindahkan credentials ke .env file
- [ ] Test kirim email dengan Django shell
- [ ] Test endpoint register (OTP email)
- [ ] Test endpoint reset password
- [ ] Verify email di inbox (cek spam juga)
- [ ] Test HTML template tampil dengan baik
- [ ] Setup monitoring untuk email delivery

---

## 🎯 Recommended Setup

### Development:
```
Gmail + App Password
✅ Mudah setup
✅ Gratis
✅ Cukup untuk testing
```

### Production:
```
SendGrid atau Mailgun
✅ Reliable delivery
✅ Analytics dashboard
✅ Good reputation
✅ Affordable
```

### Enterprise:
```
AWS SES
✅ Scalable
✅ Pay as you grow
✅ AWS ecosystem integration
```

---

## 📞 Need Help?

Jika masih ada kendala:
1. Cek Django logs: `python manage.py runserver`
2. Cek email provider logs/dashboard
3. Test dengan provider berbeda
4. Lihat dokumentasi provider

---

**🎉 Selamat! Email configuration siap digunakan.**

*Panduan ini dibuat: 12 Juni 2026*
