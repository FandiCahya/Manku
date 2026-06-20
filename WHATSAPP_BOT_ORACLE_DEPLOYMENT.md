# 🚀 WhatsApp Bot Deployment - Oracle Cloud

Panduan lengkap deploy WhatsApp Bot di Oracle Cloud untuk backend ManKu yang sudah running di `https://151.145.68.195.nip.io`.

---

## 📋 Prerequisites

### On Oracle Cloud Server:
- ✅ Django backend running di `https://151.145.68.195.nip.io`
- ✅ Python 3.8+ installed
- ✅ Node.js 16+ installed
- ✅ PostgreSQL/Database sudah setup
- ✅ SSL/HTTPS already configured

### Check Server:
```bash
# SSH ke Oracle Cloud
ssh your-user@151.145.68.195

# Check Python
python3 --version

# Check Node.js (if not installed, install first)
node --version
npm --version
```

---

## 📦 Step 1: Install Node.js (Jika Belum Ada)

```bash
# Install Node.js 18.x LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version  # Should be v18.x
npm --version   # Should be 9.x+
```

---

## 📂 Step 2: Upload WhatsApp Bot Files

### Option A: Via Git (Recommended)

```bash
# SSH ke server
ssh your-user@151.145.68.195

# Navigate to your project
cd /path/to/ManKu

# Pull latest changes (if using git)
git pull origin main

# Or clone if fresh
# git clone <your-repo-url> ManKu
# cd ManKu
```

### Option B: Via SCP/SFTP

Di local machine:
```bash
# Upload whatsapp_bot folder
scp -r whatsapp_bot your-user@151.145.68.195:/path/to/ManKu/

# Upload new files
scp WHATSAPP_BOT_*.md your-user@151.145.68.195:/path/to/ManKu/
```

---

## ⚙️ Step 3: Configure Bot for Production

SSH ke server, lalu edit konfigurasi:

```bash
cd /path/to/ManKu/whatsapp_bot
nano bot_config.py
```

**Update konfigurasi:**

```python
import os
from dotenv import load_dotenv

load_dotenv()

# ══════════════════════════════════════════════════════════════════════════════
# PRODUCTION CONFIGURATION
# ══════════════════════════════════════════════════════════════════════════════

# WhatsApp Configuration
WHATSAPP_ENABLED = True
BOT_PHONE_NUMBER = os.getenv('BOT_PHONE_NUMBER', '')

# Command Prefix
COMMAND_PREFIX = '/manku'
ALTERNATIVE_PREFIX = '!m'

# ⚠️ IMPORTANT: Tambahkan nomor WhatsApp yang diizinkan
ALLOWED_PHONE_NUMBERS = [
    '628123456789',  # 🔴 GANTI DENGAN NOMOR ANDA
    # Tambahkan nomor lain di sini
]

# Backend Configuration - PRODUCTION URL
BACKEND_URL = os.getenv('BACKEND_URL', 'https://151.145.68.195.nip.io')
BACKEND_API_URL = f'{BACKEND_URL}/api'

# AI Configuration (Groq)
GROQ_API_KEY = os.getenv('GROQ_API_KEY', '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')
AI_MODEL = 'llama-3.3-70b-versatile'

# Bot Features
FEATURES = {
    'transaction_input': True,
    'balance_check': True,
    'report_summary': True,
    'investment_check': True,
    'help_command': True,
}

# Security - Production Settings
RATE_LIMIT_PER_MINUTE = 10
SESSION_TIMEOUT = 3600

# Logging
LOG_LEVEL = 'INFO'
LOG_FILE = '/var/log/manku/whatsapp_bot.log'  # Production log path

# Helper functions tetap sama...
def is_phone_allowed(phone_number):
    phone = phone_number.replace('+', '').replace('-', '').replace(' ', '')
    return phone in ALLOWED_PHONE_NUMBERS

def has_valid_prefix(message):
    message = message.strip()
    return message.startswith(COMMAND_PREFIX) or message.startswith(ALTERNATIVE_PREFIX)

def remove_prefix(message):
    message = message.strip()
    if message.startswith(COMMAND_PREFIX):
        return message[len(COMMAND_PREFIX):].strip()
    elif message.startswith(ALTERNATIVE_PREFIX):
        return message[len(ALTERNATIVE_PREFIX):].strip()
    return message
```

**Simpan dan keluar** (Ctrl+X, Y, Enter)

---

## 🔧 Step 4: Setup Environment Variables

```bash
# Edit .env file
cd /path/to/ManKu
nano .env
```

**Tambahkan:**

```bash
# WhatsApp Bot Configuration
BACKEND_URL=https://151.145.68.195.nip.io
BOT_PHONE_NUMBER=628xxx  # Nomor WA yang akan jadi bot
GROQ_API_KEY=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
```

---

## 📦 Step 5: Install Dependencies

```bash
cd /path/to/ManKu/whatsapp_bot

# Install Python dependencies
pip3 install -r requirements.txt

# Install Node.js dependencies
npm install
```

---

## 🗄️ Step 6: Database Migration

```bash
cd /path/to/ManKu

# Activate virtual environment (if using)
source venv/bin/activate

# Run migrations
python manage.py makemigrations accounts
python manage.py migrate

# Verify WhatsAppUser table created
python manage.py dbshell
\dt  # List tables, should see accounts_whatsappuser
\q   # Quit
```

---

## 👤 Step 7: Register WhatsApp Numbers

### Via Django Admin (Recommended):

1. **Access admin panel:**
   ```
   https://151.145.68.195.nip.io/admin/
   ```

2. **Login dengan superuser**

3. **Go to:** Accounts → WhatsApp Users → Add WhatsApp User

4. **Fill in:**
   - **User**: Select user
   - **Phone number**: `628123456789` (format: 628xxx)
   - **Is active**: ✅ Check

5. **Save**

### Via Django Shell:

```bash
cd /path/to/ManKu
python manage.py shell
```

```python
from django.contrib.auth.models import User
from accounts.models import WhatsAppUser

# Get user
user = User.objects.get(username='your_username')

# Register WA number
WhatsAppUser.objects.create(
    user=user,
    phone_number='628123456789'  # Ganti dengan nomor Anda
)

print("✅ WhatsApp number registered!")
exit()
```

---

## 📁 Step 8: Create Log Directory

```bash
# Create log directory
sudo mkdir -p /var/log/manku
sudo chown $USER:$USER /var/log/manku
```

---

## 🔥 Step 9: Setup Firewall

```bash
# Open ports for WhatsApp bot
sudo firewall-cmd --permanent --add-port=3000/tcp   # Node.js server
sudo firewall-cmd --permanent --add-port=8001/tcp   # Python server
sudo firewall-cmd --reload

# Verify
sudo firewall-cmd --list-ports
```

---

## 🚀 Step 10: Run Bot (Testing)

### Test Manual Run First:

```bash
cd /path/to/ManKu/whatsapp_bot

# Run bot
python3 run_bot.py
```

**Expected output:**
```
================================================================================
🤖 ManKu WhatsApp Bot
================================================================================

🐍 Python server started on http://localhost:8001
🚀 WhatsApp Bot Server running on http://localhost:3000
📱 Starting WhatsApp client...
📱 QR Code received! Please scan with WhatsApp:
```

### Scan QR Code:

1. Open WhatsApp on your phone
2. Go to: **Settings → Linked Devices → Link a Device**
3. Scan QR code from terminal
4. Wait for: **"✅ WhatsApp Bot is ready!"**

### Test Bot:

Kirim pesan ke nomor WA yang di-scan:
```
/manku help
```

Jika berhasil, bot akan membalas!

**Jika berhasil, proceed ke Step 11 untuk production setup.**

---

## 🔧 Step 11: Setup Systemd Services (Production)

### A. Create Node.js Service

```bash
sudo nano /etc/systemd/system/manku-whatsapp-node.service
```

**Content:**

```ini
[Unit]
Description=ManKu WhatsApp Bot - Node.js Server
After=network.target

[Service]
Type=simple
User=your-username
WorkingDirectory=/path/to/ManKu/whatsapp_bot
Environment="NODE_ENV=production"
ExecStart=/usr/bin/node whatsapp_server.js
Restart=always
RestartSec=10
StandardOutput=append:/var/log/manku/whatsapp-node.log
StandardError=append:/var/log/manku/whatsapp-node.error.log

[Install]
WantedBy=multi-user.target
```

**Replace:**
- `your-username` → your actual username
- `/path/to/ManKu` → actual path

### B. Create Python Service

```bash
sudo nano /etc/systemd/system/manku-whatsapp-python.service
```

**Content:**

```ini
[Unit]
Description=ManKu WhatsApp Bot - Python Server
After=network.target manku-whatsapp-node.service
Requires=manku-whatsapp-node.service

[Service]
Type=simple
User=your-username
WorkingDirectory=/path/to/ManKu/whatsapp_bot
Environment="PYTHONUNBUFFERED=1"
ExecStart=/usr/bin/python3 run_bot.py
Restart=always
RestartSec=10
StandardOutput=append:/var/log/manku/whatsapp-python.log
StandardError=append:/var/log/manku/whatsapp-python.error.log

[Install]
WantedBy=multi-user.target
```

---

## ▶️ Step 12: Start Services

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable services (auto-start on boot)
sudo systemctl enable manku-whatsapp-node
sudo systemctl enable manku-whatsapp-python

# Start Node.js service
sudo systemctl start manku-whatsapp-node

# Check status
sudo systemctl status manku-whatsapp-node

# Wait 10 seconds, then start Python service
sleep 10
sudo systemctl start manku-whatsapp-python

# Check status
sudo systemctl status manku-whatsapp-python
```

---

## 🔍 Step 13: Monitor & Check Logs

### Check Service Status:

```bash
# Node.js service
sudo systemctl status manku-whatsapp-node

# Python service
sudo systemctl status manku-whatsapp-python
```

### View Logs:

```bash
# Node.js logs
tail -f /var/log/manku/whatsapp-node.log

# Python logs
tail -f /var/log/manku/whatsapp-python.log

# Error logs
tail -f /var/log/manku/whatsapp-node.error.log
tail -f /var/log/manku/whatsapp-python.error.log

# Bot application logs
tail -f /var/log/manku/whatsapp_bot.log
```

### Check if Ports are Listening:

```bash
# Check port 3000 (Node.js)
sudo netstat -tulpn | grep 3000

# Check port 8001 (Python)
sudo netstat -tulpn | grep 8001
```

---

## 🔄 Step 14: Restart/Stop Services

### Restart:

```bash
# Restart Node.js
sudo systemctl restart manku-whatsapp-node

# Restart Python
sudo systemctl restart manku-whatsapp-python

# Restart both
sudo systemctl restart manku-whatsapp-node manku-whatsapp-python
```

### Stop:

```bash
# Stop services
sudo systemctl stop manku-whatsapp-python
sudo systemctl stop manku-whatsapp-node
```

### View Logs After Restart:

```bash
# Follow logs
journalctl -u manku-whatsapp-node -f
journalctl -u manku-whatsapp-python -f
```

---

## 📱 Step 15: Re-scan QR Code (If Needed)

**⚠️ PENTING:** Setelah deploy pertama kali, Anda perlu scan QR code.

### Method 1: Via Logs

```bash
# Watch Node.js logs for QR code
tail -f /var/log/manku/whatsapp-node.log
```

QR code akan muncul di log. Scan dengan WhatsApp.

### Method 2: Run Manually (Easier for First Time)

```bash
# Stop services temporarily
sudo systemctl stop manku-whatsapp-python
sudo systemctl stop manku-whatsapp-node

# Run manually to see QR code
cd /path/to/ManKu/whatsapp_bot
python3 run_bot.py
```

Scan QR code yang muncul, tunggu sampai authenticated.

**Ctrl+C** untuk stop.

```bash
# Start services again
sudo systemctl start manku-whatsapp-node
sleep 10
sudo systemctl start manku-whatsapp-python
```

**Session will be saved!** Next restart tidak perlu scan lagi.

---

## ✅ Step 16: Test Bot

Kirim pesan WhatsApp ke nomor yang sudah di-scan:

```
/manku help
```

**Expected response:**
```
🤖 ManKu Bot - Bantuan

Perintah yang tersedia:
...
```

### Test All Commands:

```bash
# Balance
/manku saldo

# Transaction
/manku beli kopi 25000

# Report
/manku report

# Investment
/manku investasi
```

---

## 🔧 Troubleshooting

### Problem 1: Service Failed to Start

**Check logs:**
```bash
journalctl -u manku-whatsapp-node -n 50
journalctl -u manku-whatsapp-python -n 50
```

**Common issues:**
- Node.js not installed: Install Node.js
- Python dependencies missing: Run `pip3 install -r requirements.txt`
- Port already in use: Kill process or change port

### Problem 2: Bot Not Responding

**Check:**
```bash
# 1. Are services running?
sudo systemctl status manku-whatsapp-node
sudo systemctl status manku-whatsapp-python

# 2. Are ports listening?
sudo netstat -tulpn | grep 3000
sudo netstat -tulpn | grep 8001

# 3. Check Django backend
curl https://151.145.68.195.nip.io/api/auth/whatsapp-user/628xxx/

# 4. Check logs
tail -f /var/log/manku/whatsapp-python.log
```

**Common solutions:**
- Restart services
- Check whitelist in `bot_config.py`
- Verify WA number registered in Django Admin
- Check prefix usage (`/manku` or `!m`)

### Problem 3: QR Code Not Showing

**Solution:**
Run bot manually to see QR:
```bash
sudo systemctl stop manku-whatsapp-python manku-whatsapp-node
cd /path/to/ManKu/whatsapp_bot
python3 run_bot.py
```

### Problem 4: Authentication Session Lost

**WhatsApp session stored in:**
```bash
/path/to/ManKu/whatsapp_bot/.wwebjs_auth/
```

**If session corrupted:**
```bash
# Remove session
rm -rf /path/to/ManKu/whatsapp_bot/.wwebjs_auth/

# Restart and re-scan
sudo systemctl restart manku-whatsapp-node manku-whatsapp-python
```

### Problem 5: Cannot Connect to Backend

**Check:**
```bash
# Test from server
curl https://151.145.68.195.nip.io/api/finance/dashboard/ \
  -H "Authorization: Bearer YOUR_TOKEN"

# Check bot_config.py
cat /path/to/ManKu/whatsapp_bot/bot_config.py | grep BACKEND_URL
# Should be: https://151.145.68.195.nip.io
```

---

## 🔐 Security Checklist

- [x] Firewall configured (ports 3000, 8001)
- [x] Whitelist configured in `bot_config.py`
- [x] Rate limiting enabled (10 msg/min)
- [x] HTTPS backend (already setup)
- [x] Environment variables secured
- [x] Services run as non-root user
- [x] Logs directory secured (`/var/log/manku`)

---

## 📊 Monitoring Commands

```bash
# Check service status
sudo systemctl status manku-whatsapp-*

# View logs (real-time)
tail -f /var/log/manku/*.log

# Check resource usage
htop  # Filter by 'node' and 'python3'

# Check disk space
df -h

# Check memory
free -h

# Restart if needed
sudo systemctl restart manku-whatsapp-node manku-whatsapp-python
```

---

## 🔄 Auto-restart on Failure

Services already configured with `Restart=always` in systemd.

**If service crashes, it will auto-restart after 10 seconds.**

Check restart count:
```bash
systemctl show manku-whatsapp-python | grep NRestarts
systemctl show manku-whatsapp-node | grep NRestarts
```

---

## 📝 Maintenance Tasks

### Daily:
```bash
# Check logs for errors
tail -100 /var/log/manku/whatsapp-python.error.log
tail -100 /var/log/manku/whatsapp-node.error.log
```

### Weekly:
```bash
# Restart services
sudo systemctl restart manku-whatsapp-node manku-whatsapp-python

# Clean old logs (optional)
find /var/log/manku -name "*.log" -mtime +30 -delete
```

### Monthly:
```bash
# Update dependencies
cd /path/to/ManKu/whatsapp_bot
pip3 install --upgrade -r requirements.txt
npm update

# Restart
sudo systemctl restart manku-whatsapp-node manku-whatsapp-python
```

---

## 🎯 Quick Reference

### Service Commands:
```bash
# Start
sudo systemctl start manku-whatsapp-node manku-whatsapp-python

# Stop
sudo systemctl stop manku-whatsapp-python manku-whatsapp-node

# Restart
sudo systemctl restart manku-whatsapp-node manku-whatsapp-python

# Status
sudo systemctl status manku-whatsapp-*

# Logs
journalctl -u manku-whatsapp-python -f
```

### File Locations:
```
Service files:
  /etc/systemd/system/manku-whatsapp-node.service
  /etc/systemd/system/manku-whatsapp-python.service

Logs:
  /var/log/manku/whatsapp-node.log
  /var/log/manku/whatsapp-python.log
  /var/log/manku/whatsapp_bot.log

Bot files:
  /path/to/ManKu/whatsapp_bot/

Session data:
  /path/to/ManKu/whatsapp_bot/.wwebjs_auth/
```

---

## 🎉 Deployment Complete!

Jika semua steps berhasil:

✅ Node.js service running (port 3000)
✅ Python service running (port 8001)
✅ WhatsApp authenticated
✅ Bot responding to commands
✅ Auto-restart on failure configured
✅ Logs configured

**Test final:**
```
/manku help
/manku saldo
/manku beli kopi 25000
```

**Bot siap production! 🚀**

---

## 📞 Need Help?

**Check:**
1. Logs: `tail -f /var/log/manku/*.log`
2. Service status: `sudo systemctl status manku-whatsapp-*`
3. Backend: `https://151.145.68.195.nip.io/api/`

**Common commands:**
```bash
# Full restart
sudo systemctl restart manku-whatsapp-node manku-whatsapp-python

# View all logs
tail -f /var/log/manku/*.log

# Check if authenticated
cat /var/log/manku/whatsapp-node.log | grep "ready"
```

---

**Happy deploying! 🎉📱💰**
