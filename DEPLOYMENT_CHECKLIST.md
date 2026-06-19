# ✅ Deployment Checklist - ManKu Backend

## 📋 Pre-Deployment Checklist

### 1. Database Migration
```bash
# Run all migrations
python manage.py makemigrations
python manage.py migrate

# Verify migrations
python manage.py showmigrations
```

**Expected Migrations**:
- [x] accounts: 0001_initial, 0002_otpverification_expires_at_passwordresettoken
- [x] finance: 0001_initial, 0002_..., 0003_..., 0004_pricecache_investment_...

---

### 2. Environment Variables

Create `.env` file:
```env
# Django
SECRET_KEY=your-secret-key-here
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# Database
DB_NAME=manku_db
DB_USER=manku_user
DB_PASSWORD=strong-password-here
DB_HOST=localhost
DB_PORT=5432

# Email
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=ManKu App <noreply@manku.app>

# AI
GROQ_API_KEY=your-groq-api-key-here

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
```

---

### 3. Security Settings

Update `core/settings.py`:

```python
# PRODUCTION SETTINGS

# Security
DEBUG = False
SECRET_KEY = os.getenv('SECRET_KEY')
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', '').split(',')

# HTTPS
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'

# HSTS
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
```

---

### 4. Static Files

```bash
# Collect static files
python manage.py collectstatic --noinput

# Configure nginx/apache to serve static files
```

Update `settings.py`:
```python
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATIC_URL = '/static/'
```

---

### 5. CORS Configuration

Update for production domains:
```python
CORS_ALLOWED_ORIGINS = [
    "https://yourdomain.com",
    "https://www.yourdomain.com",
    "https://app.yourdomain.com",
]
```

---

### 6. Database

**PostgreSQL Setup**:
```bash
# Install PostgreSQL
sudo apt-get install postgresql postgresql-contrib

# Create database
sudo -u postgres psql
CREATE DATABASE manku_db;
CREATE USER manku_user WITH PASSWORD 'strong-password';
GRANT ALL PRIVILEGES ON DATABASE manku_db TO manku_user;
\q
```

Update `settings.py`:
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('DB_NAME'),
        'USER': os.getenv('DB_USER'),
        'PASSWORD': os.getenv('DB_PASSWORD'),
        'HOST': os.getenv('DB_HOST'),
        'PORT': os.getenv('DB_PORT'),
    }
}
```

---

### 7. API Keys & Secrets

- [ ] Move Groq API key to `.env`
- [ ] Setup Google OAuth production credentials
- [ ] Configure email SMTP for production
- [ ] Add API rate limiting

---

### 8. Logging

Setup logging in `settings.py`:
```python
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'ERROR',
            'class': 'logging.FileHandler',
            'filename': '/var/log/manku/error.log',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'ERROR',
            'propagate': True,
        },
    },
}
```

---

### 9. Rate Limiting

Install and configure:
```bash
pip install django-ratelimit
```

Add to views:
```python
from django_ratelimit.decorators import ratelimit

@ratelimit(key='user', rate='100/h')
def my_view(request):
    ...
```

---

### 10. Caching (Redis)

```bash
# Install Redis
pip install django-redis

# Configure in settings.py
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}
```

---

## 🚀 Deployment Steps

### Option 1: Traditional Server (Ubuntu + Nginx + Gunicorn)

#### 1. Install Dependencies
```bash
sudo apt-get update
sudo apt-get install python3-pip python3-dev nginx
pip install gunicorn
```

#### 2. Install Requirements
```bash
pip install -r requirements.txt
```

#### 3. Configure Gunicorn
Create `gunicorn_config.py`:
```python
bind = "127.0.0.1:8000"
workers = 3
accesslog = "/var/log/manku/access.log"
errorlog = "/var/log/manku/error.log"
```

#### 4. Create Systemd Service
Create `/etc/systemd/system/manku.service`:
```ini
[Unit]
Description=ManKu Django App
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/manku
Environment="PATH=/var/www/manku/venv/bin"
ExecStart=/var/www/manku/venv/bin/gunicorn --config gunicorn_config.py core.wsgi:application

[Install]
WantedBy=multi-user.target
```

#### 5. Configure Nginx
Create `/etc/nginx/sites-available/manku`:
```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location /static/ {
        alias /var/www/manku/staticfiles/;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### 6. Enable and Start
```bash
sudo ln -s /etc/nginx/sites-available/manku /etc/nginx/sites-enabled
sudo systemctl start manku
sudo systemctl enable manku
sudo systemctl restart nginx
```

#### 7. Setup SSL (Let's Encrypt)
```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

---

### Option 2: Docker

#### 1. Create `Dockerfile`
```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "core.wsgi:application"]
```

#### 2. Create `docker-compose.yml`
```yaml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: manku_db
      POSTGRES_USER: manku_user
      POSTGRES_PASSWORD: strong-password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine

  web:
    build: .
    command: gunicorn core.wsgi:application --bind 0.0.0.0:8000
    volumes:
      - .:/app
      - static_volume:/app/staticfiles
    ports:
      - "8000:8000"
    env_file:
      - .env
    depends_on:
      - db
      - redis

volumes:
  postgres_data:
  static_volume:
```

#### 3. Build and Run
```bash
docker-compose up -d
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
```

---

### Option 3: Cloud Platform (Heroku, Railway, Render)

#### Railway.app
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Initialize
railway init

# Deploy
railway up
```

#### Render.com
1. Connect GitHub repo
2. Set environment variables
3. Add build command: `pip install -r requirements.txt`
4. Add start command: `gunicorn core.wsgi:application`

---

## 🧪 Post-Deployment Testing

### 1. Health Check
```bash
curl https://yourdomain.com/admin/
```

### 2. API Test
```bash
# Register
curl -X POST https://yourdomain.com/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Test","email":"test@example.com","password":"test123"}'

# Get crypto price
curl https://yourdomain.com/api/finance/investments/price/?symbol=BTC&type=crypto \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 3. Email Test
- Send test OTP email
- Send test reset password email

### 4. Investment API Test
- Get crypto price
- Get stock price
- Create investment
- Get portfolio summary

---

## 📊 Monitoring

### 1. Setup Monitoring Tools
- **Sentry** untuk error tracking
- **New Relic** atau **DataDog** untuk APM
- **Uptime Robot** untuk uptime monitoring

### 2. Setup Logging
```bash
# Create log directory
sudo mkdir -p /var/log/manku
sudo chown www-data:www-data /var/log/manku
```

### 3. Log Rotation
Create `/etc/logrotate.d/manku`:
```
/var/log/manku/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
}
```

---

## 🔒 Security Checklist

- [ ] DEBUG = False
- [ ] Strong SECRET_KEY
- [ ] HTTPS enabled
- [ ] HSTS enabled
- [ ] Secure cookies
- [ ] CORS configured properly
- [ ] Rate limiting enabled
- [ ] SQL injection prevention (ORM)
- [ ] XSS protection enabled
- [ ] CSRF protection enabled
- [ ] API keys in environment variables
- [ ] Database credentials secure
- [ ] Regular backups scheduled

---

## 💾 Backup Strategy

### 1. Database Backup
```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -U manku_user manku_db > /backups/manku_$DATE.sql
find /backups -name "manku_*.sql" -mtime +7 -delete
```

### 2. Schedule with Cron
```bash
crontab -e
# Add:
0 2 * * * /path/to/backup_script.sh
```

---

## 📈 Performance Optimization

### 1. Database Indexing
```python
# Add indexes to frequently queried fields
class Transaction(models.Model):
    transaction_date = models.DateTimeField(db_index=True)
    user = models.ForeignKey(User, on_delete=CASCADE, db_index=True)
```

### 2. Query Optimization
```python
# Use select_related for foreign keys
Transaction.objects.select_related('category', 'user')

# Use prefetch_related for reverse relations
User.objects.prefetch_related('transactions')
```

### 3. Caching
```python
from django.core.cache import cache

# Cache expensive queries
portfolio = cache.get('portfolio_user_{user.id}')
if not portfolio:
    portfolio = calculate_portfolio(user)
    cache.set('portfolio_user_{user.id}', portfolio, 300)
```

---

## ✅ Final Checklist

### Pre-Launch:
- [ ] All migrations applied
- [ ] Environment variables set
- [ ] Static files collected
- [ ] Database configured
- [ ] Email configured and tested
- [ ] API keys configured
- [ ] HTTPS enabled
- [ ] Security settings enabled
- [ ] Logging configured
- [ ] Monitoring setup

### Post-Launch:
- [ ] Test all endpoints
- [ ] Monitor error logs
- [ ] Check email delivery
- [ ] Test investment price APIs
- [ ] Monitor API rate limits
- [ ] Setup backup schedule
- [ ] Configure CDN (optional)
- [ ] Setup CI/CD (optional)

---

## 📞 Support

### Documentation:
- API Docs: `INVESTMENT_API_DOCS.md`
- Auth Docs: `API_RESET_PASSWORD_DOCS.md`
- Email Setup: `EMAIL_CONFIG_GUIDE.md`

### Monitoring:
- Server logs: `/var/log/manku/`
- Django admin: `https://yourdomain.com/admin/`
- Error tracking: Sentry dashboard

---

**🚀 Ready for Production Deployment!**

*Checklist Created: 12 Juni 2026*
