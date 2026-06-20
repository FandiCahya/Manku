# ⚡ WhatsApp Bot - Oracle Cloud Quick Start

Panduan cepat deploy WhatsApp Bot di Oracle Cloud untuk backend yang sudah running di `https://151.145.68.195.nip.io`.

---

## 🚀 Quick Deploy (5 Steps)

### 1️⃣ SSH ke Server

```bash
ssh your-user@151.145.68.195
```

### 2️⃣ Navigate to Project

```bash
cd /path/to/ManKu
```

### 3️⃣ Configure Whitelist

```bash
nano whatsapp_bot/bot_config.py
```

**Edit:**
```python
ALLOWED_PHONE_NUMBERS = [
    '628123456789',  # 🔴 GANTI DENGAN NOMOR ANDA
]

BACKEND_URL = 'https://151.145.68.195.nip.io'  # ✅ Already correct
```

Save: `Ctrl+X`, `Y`, `Enter`

### 4️⃣ Run Deploy Script

```bash
# Make script executable
chmod +x whatsapp_bot/deploy_oracle.sh

# Edit script - change PROJECT_DIR
nano whatsapp_bot/deploy_oracle.sh
# Change: PROJECT_DIR="/path/to/ManKu"  → Actual path

# Run deployment
./whatsapp_bot/deploy_oracle.sh
```

### 5️⃣ Scan QR Code

```bash
# View logs to see QR code
tail -f /var/log/manku/whatsapp-node.log
```

**Scan QR code dengan WhatsApp:**
- Settings → Linked Devices → Link a Device
- Scan QR code

**Wait for:** `✅ WhatsApp Bot is ready!`

---

## ✅ Test Bot

Kirim pesan WhatsApp:

```
/manku help
```

✅ **Done! Bot is live!** 🎉

---

## 🔧 Management Commands

```bash
# Make bot manager executable
chmod +x whatsapp_bot/bot_manager.sh

# Use bot manager
./whatsapp_bot/bot_manager.sh status    # Check status
./whatsapp_bot/bot_manager.sh logs      # View logs
./whatsapp_bot/bot_manager.sh restart   # Restart bot
./whatsapp_bot/bot_manager.sh test      # Test health
```

---

## 📋 Common Commands

### Start/Stop:
```bash
# Start
sudo systemctl start manku-whatsapp-node manku-whatsapp-python

# Stop
sudo systemctl stop manku-whatsapp-python manku-whatsapp-node

# Restart
sudo systemctl restart manku-whatsapp-node manku-whatsapp-python
```

### Check Status:
```bash
sudo systemctl status manku-whatsapp-*
```

### View Logs:
```bash
# All logs
tail -f /var/log/manku/*.log

# Python only
tail -f /var/log/manku/whatsapp-python.log

# Node.js only
tail -f /var/log/manku/whatsapp-node.log

# Errors
tail -f /var/log/manku/*.error.log
```

---

## 👤 Register WhatsApp Numbers

### Via Django Admin:

1. Open: `https://151.145.68.195.nip.io/admin/`
2. Login
3. Go to: **Accounts → WhatsApp Users → Add**
4. Select user + enter phone: `628123456789`
5. Check "Is active"
6. Save

### Via Command Line:

```bash
cd /path/to/ManKu
source venv/bin/activate  # if using venv
python manage.py shell
```

```python
from django.contrib.auth.models import User
from accounts.models import WhatsAppUser

user = User.objects.get(username='your_username')
WhatsAppUser.objects.create(user=user, phone_number='628123456789')
exit()
```

---

## 🔥 Firewall (If Not Open)

```bash
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=8001/tcp
sudo firewall-cmd --reload
```

---

## 🐛 Troubleshooting

### Bot not responding?

```bash
# 1. Check services
sudo systemctl status manku-whatsapp-*

# 2. Check logs
tail -f /var/log/manku/whatsapp-python.log

# 3. Restart
sudo systemctl restart manku-whatsapp-node manku-whatsapp-python
```

### Need to re-scan QR?

```bash
# Remove session
rm -rf /path/to/ManKu/whatsapp_bot/.wwebjs_auth/

# Restart
sudo systemctl restart manku-whatsapp-node manku-whatsapp-python

# View logs for QR
tail -f /var/log/manku/whatsapp-node.log
```

### User not found error?

Register WA number in Django Admin (see above).

---

## 📊 Architecture

```
WhatsApp User
      ↓
WhatsApp Web (Scan QR)
      ↓
Oracle Cloud Server (151.145.68.195)
      ├─ Node.js (Port 3000) → WhatsApp Web
      ├─ Python (Port 8001) → Message Handler
      └─ Django (HTTPS) → Backend API
            ↓
      PostgreSQL Database
```

---

## 📝 File Locations

```
Services:
  /etc/systemd/system/manku-whatsapp-node.service
  /etc/systemd/system/manku-whatsapp-python.service

Logs:
  /var/log/manku/whatsapp-node.log
  /var/log/manku/whatsapp-python.log
  /var/log/manku/whatsapp_bot.log

Bot Files:
  /path/to/ManKu/whatsapp_bot/

Session:
  /path/to/ManKu/whatsapp_bot/.wwebjs_auth/
```

---

## 🎯 Quick Tests

### Test 1: Services Running
```bash
sudo systemctl status manku-whatsapp-*
# Both should show: active (running)
```

### Test 2: Ports Listening
```bash
sudo netstat -tulpn | grep -E "3000|8001"
# Should show both ports
```

### Test 3: Bot Health
```bash
./whatsapp_bot/bot_manager.sh test
```

### Test 4: Send Message
```
/manku help
```

Should receive response from bot.

---

## 🔄 Auto-restart

Services configured to auto-restart on failure.

Check restart count:
```bash
systemctl show manku-whatsapp-python | grep NRestarts
```

---

## 📚 Full Documentation

- **Complete Guide:** `WHATSAPP_BOT_ORACLE_DEPLOYMENT.md`
- **Bot Features:** `WHATSAPP_BOT_GUIDE.md`
- **Commands:** `whatsapp_bot/QUICK_REFERENCE.md`
- **Architecture:** `SYSTEM_ARCHITECTURE.md`

---

## ✅ Deployment Checklist

- [ ] SSH access to Oracle Cloud
- [ ] Python 3.8+ installed
- [ ] Node.js 16+ installed
- [ ] Whitelist configured in `bot_config.py`
- [ ] Deploy script executed
- [ ] Services started
- [ ] QR code scanned
- [ ] WA numbers registered in Django Admin
- [ ] Bot tested with `/manku help`

---

## 🎉 Success!

If bot responds to `/manku help`, deployment is complete!

**Bot Commands:**
```
/manku help       - Show help
/manku saldo      - Check balance
/manku report     - Monthly report
/manku investasi  - Investment portfolio
/manku beli kopi 25000  - Add transaction
```

---

**Need detailed guide? See:** `WHATSAPP_BOT_ORACLE_DEPLOYMENT.md`

**Happy deploying! 🚀📱💰**
