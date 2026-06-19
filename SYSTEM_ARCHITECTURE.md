# 🏗️ ManKu System Architecture

Complete system architecture diagram untuk ManKu Finance App with WhatsApp Bot.

---

## 📊 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INTERFACES                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Flutter    │  │  WhatsApp    │  │  Web Browser │          │
│  │  Mobile App  │  │   Messenger  │  │   (Admin)    │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                  │                  │                   │
└─────────┼──────────────────┼──────────────────┼──────────────────┘
          │                  │                  │
          │ REST API         │ WhatsApp Web     │ HTTP
          │                  │ Protocol         │
          ↓                  ↓                  ↓
┌─────────────────────────────────────────────────────────────────┐
│                     APPLICATION LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Django REST Framework Backend               │   │
│  │                                                           │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐        │   │
│  │  │  accounts  │  │  finance   │  │  whatsapp  │        │   │
│  │  │    app     │  │    app     │  │   bot      │        │   │
│  │  └────────────┘  └────────────┘  └────────────┘        │   │
│  │         │                │                │              │   │
│  │         └────────────────┴────────────────┘              │   │
│  │                          │                                │   │
│  │                 ┌────────▼────────┐                      │   │
│  │                 │  Django Models  │                      │   │
│  │                 │   (ORM Layer)   │                      │   │
│  │                 └────────┬────────┘                      │   │
│  └──────────────────────────┼──────────────────────────────┘   │
│                              │                                   │
└──────────────────────────────┼───────────────────────────────────┘
                               │
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│                      DATABASE LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              PostgreSQL / SQLite Database                 │  │
│  │                                                            │  │
│  │  ┌──────┐ ┌────────┐ ┌──────┐ ┌──────────┐ ┌─────────┐ │  │
│  │  │Users │ │Transac-│ │Budget│ │Investment│ │WhatsApp │ │  │
│  │  │      │ │tions   │ │      │ │          │ │User     │ │  │
│  │  └──────┘ └────────┘ └──────┘ └──────────┘ └─────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │
│  │  Groq AI   │  │ CoinGecko  │  │   Yahoo    │  │  Gmail   │ │
│  │  (Vision,  │  │   (Crypto  │  │  Finance   │  │  (SMTP)  │ │
│  │  Whisper,  │  │   Prices)  │  │  (Stocks)  │  │          │ │
│  │  LLaMA)    │  │            │  │            │  │          │ │
│  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

---

## 🤖 WhatsApp Bot Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    WHATSAPP USER                                 │
│              (Sends message to bot number)                       │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      │ WhatsApp Protocol
                      ↓
┌─────────────────────────────────────────────────────────────────┐
│                  WHATSAPP WEB (QR Scan)                          │
│           Authenticated session with bot number                  │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      │ WebSocket
                      ↓
┌─────────────────────────────────────────────────────────────────┐
│              NODE.JS SERVER (whatsapp_server.js)                 │
│                    Port: 3000                                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  • Receive messages from WhatsApp Web                     │  │
│  │  • Send messages to WhatsApp users                        │  │
│  │  • Handle QR code authentication                          │  │
│  │  • Manage WhatsApp session                                │  │
│  │  • Provide HTTP API endpoints:                            │  │
│  │    - POST /send-message                                   │  │
│  │    - GET  /status                                         │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      │ HTTP POST (Forward incoming messages)
                      ↓
┌─────────────────────────────────────────────────────────────────┐
│           PYTHON SERVER (run_bot.py - aiohttp)                   │
│                    Port: 8001                                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Endpoint: POST /whatsapp/incoming                        │  │
│  │  • Receives message data from Node.js                     │  │
│  │  • Forwards to MessageHandler                             │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ↓
┌─────────────────────────────────────────────────────────────────┐
│              MESSAGE HANDLER (message_handler.py)                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  STEP 1: Security Checks                                  │  │
│  │  ├─ Whitelist validation (is_phone_allowed)              │  │
│  │  ├─ Prefix validation (has_valid_prefix)                 │  │
│  │  └─ Rate limiting (10 msg/min)                           │  │
│  │                                                            │  │
│  │  STEP 2: User Lookup                                      │  │
│  │  └─ Query WhatsAppUser model via backend API             │  │
│  │                                                            │  │
│  │  STEP 3: Command Routing                                  │  │
│  │  ├─ help      → Help command                             │  │
│  │  ├─ saldo     → Balance check                            │  │
│  │  ├─ report    → Monthly report                           │  │
│  │  ├─ investasi → Investment portfolio                     │  │
│  │  └─ default   → Transaction input (AI parsing)           │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────┬───────────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
        ↓             ↓             ↓
┌──────────────┐ ┌──────────┐ ┌─────────────────┐
│  AI PARSER   │ │ BACKEND  │ │ BOT COMMANDS    │
│ (ai_parser)  │ │   API    │ │ (bot_commands)  │
│              │ │(backend_ │ │                 │
│ • Groq AI    │ │integrat) │ │ • Balance check │
│ • LLaMA 3.3  │ │          │ │ • Report        │
│ • Parse      │ │ • Auth   │ │ • Investment    │
│   natural    │ │ • API    │ │ • Transaction   │
│   language   │ │   calls  │ │   save          │
└──────┬───────┘ └────┬─────┘ └────────┬────────┘
       │              │                 │
       │              ↓                 │
       │    ┌────────────────────┐     │
       │    │   Django Backend   │     │
       │    │   (Port 8000)      │     │
       │    │                    │     │
       │    │ • JWT Auth         │     │
       │    │ • Transaction API  │     │
       │    │ • Dashboard API    │     │
       │    │ • Investment API   │     │
       │    └────────────────────┘     │
       │                                │
       └────────────────────────────────┘
                      │
                      ↓
        ┌─────────────────────────┐
        │  Format Response         │
        │  (whatsapp_client.py)    │
        └─────────────┬─────────────┘
                      │
                      │ HTTP POST to Node.js
                      ↓
        ┌─────────────────────────┐
        │  Node.js Server          │
        │  POST /send-message      │
        └─────────────┬─────────────┘
                      │
                      ↓
        ┌─────────────────────────┐
        │  WhatsApp Web            │
        └─────────────┬─────────────┘
                      │
                      ↓
        ┌─────────────────────────┐
        │  WhatsApp User           │
        │  (Receives response)     │
        └──────────────────────────┘
```

---

## 💾 Database Schema

```
┌─────────────────────────────────────────────────────────────────┐
│                      DATABASE MODELS                             │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────┐         ┌──────────────────┐
│      User        │◄───────┤  WhatsAppUser    │
├──────────────────┤  1:1    ├──────────────────┤
│ • id             │         │ • user_id (FK)   │
│ • username       │         │ • phone_number   │
│ • email          │         │ • is_active      │
│ • password       │         │ • created_at     │
│ • first_name     │         │ • last_interaction│
│ • last_name      │         └──────────────────┘
└────────┬─────────┘
         │
         │ 1:N
         │
┌────────▼──────────┐         ┌──────────────────┐
│  Transaction      │─────────┤   Category       │
├───────────────────┤  N:1    ├──────────────────┤
│ • id              │         │ • id             │
│ • user_id (FK)    │         │ • name           │
│ • category_id(FK) │         │ • user_id (FK)   │
│ • amount          │         │ • icon           │
│ • description     │         └──────────────────┘
│ • type (I/E)      │
│ • date            │
└───────────────────┘

┌───────────────────┐         ┌──────────────────┐
│     Budget        │─────────┤   Category       │
├───────────────────┤  N:1    └──────────────────┘
│ • id              │
│ • user_id (FK)    │
│ • category_id(FK) │
│ • amount          │
│ • month_year      │
└───────────────────┘

┌───────────────────┐
│  SavingsGoal      │
├───────────────────┤
│ • id              │
│ • user_id (FK)    │
│ • name            │
│ • target_amount   │
│ • current_amount  │
│ • target_date     │
└───────────────────┘

┌───────────────────┐         ┌──────────────────────┐
│   Investment      │◄───────┤InvestmentTransaction │
├───────────────────┤  1:N    ├──────────────────────┤
│ • id              │         │ • investment_id (FK) │
│ • user_id (FK)    │         │ • type (BUY/SELL)    │
│ • asset_symbol    │         │ • quantity           │
│ • asset_type      │         │ • price_per_unit     │
│ • quantity        │         │ • date               │
│ • avg_buy_price   │         └──────────────────────┘
└───────────────────┘

┌───────────────────┐
│   PriceCache      │
├───────────────────┤
│ • asset_symbol    │
│ • asset_type      │
│ • price           │
│ • cached_at       │
└───────────────────┘

┌───────────────────┐
│ OTPVerification   │
├───────────────────┤
│ • user_id (FK)    │
│ • code            │
│ • created_at      │
│ • expires_at      │
└───────────────────┘

┌────────────────────┐
│PasswordResetToken │
├────────────────────┤
│ • user_id (FK)     │
│ • token (UUID)     │
│ • created_at       │
│ • expires_at       │
│ • is_used          │
└────────────────────┘
```

---

## 🔄 Data Flow Examples

### Example 1: Transaction Input via WhatsApp

```
1. User sends: "/manku beli kopi 25000"
          ↓
2. WhatsApp Web receives message
          ↓
3. Node.js forwards to Python (port 8001)
          ↓
4. MessageHandler checks:
   - Is phone in whitelist? ✅
   - Has valid prefix? ✅
   - Rate limit OK? ✅
          ↓
5. Look up user by phone number
   - Query: GET /api/auth/whatsapp-user/628xxx/
   - Response: {username, token}
          ↓
6. AI Parser (Groq LLaMA 3.3):
   - Input: "beli kopi 25000"
   - Output: {
       amount: 25000,
       description: "beli kopi",
       type: "expense",
       category_hint: "Makanan & Minuman"
     }
          ↓
7. Backend API call:
   - POST /api/finance/transactions/save-transaction/
   - Authorization: Bearer {token}
   - Body: transaction data
          ↓
8. Django saves to database
          ↓
9. Response formatted by whatsapp_client
          ↓
10. Node.js sends WhatsApp message
          ↓
11. User receives: "✅ Transaksi Berhasil Disimpan!"
```

### Example 2: Balance Check via WhatsApp

```
1. User sends: "/manku saldo"
          ↓
2-5. [Same security & auth flow]
          ↓
6. Command Router → Balance command
          ↓
7. Backend API call:
   - GET /api/finance/dashboard/
   - Authorization: Bearer {token}
          ↓
8. Django queries database:
   - Sum all income transactions
   - Sum all expense transactions
   - Calculate balance
          ↓
9. Response: {
     total_balance: 5000000,
     total_income: 10000000,
     total_expense: 5000000
   }
          ↓
10. Format as WhatsApp message:
    "💰 Saldo Anda
     📈 Total Balance: Rp 5,000,000
     ..."
          ↓
11. User receives formatted message
```

### Example 3: Investment Portfolio Check

```
1. User sends: "/manku investasi"
          ↓
2-5. [Same security & auth flow]
          ↓
6. Command Router → Investment command
          ↓
7. Backend API call:
   - GET /api/finance/investments/portfolio-summary/
          ↓
8. Django:
   - Query all user investments
   - For each investment:
     * Fetch current price (CoinGecko/Yahoo Finance)
     * Calculate profit/loss
   - Aggregate totals
          ↓
9. Response with portfolio data
          ↓
10. Format & send to user
```

---

## 🔒 Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     SECURITY LAYERS                              │
└─────────────────────────────────────────────────────────────────┘

Layer 1: WhatsApp Bot Entry Point
├─ Phone Number Whitelist
│  └─ Only pre-approved numbers can interact
│
├─ Command Prefix Requirement
│  └─ All messages must start with /manku or !m
│
└─ Rate Limiting
   └─ 10 messages per minute per user

Layer 2: User Authentication
├─ Phone Number → User Mapping (WhatsAppUser table)
│  └─ Only registered WA numbers can access
│
└─ JWT Token Generation
   └─ Each request authenticated with JWT

Layer 3: Django Backend
├─ JWT Authentication (IsAuthenticated)
│  └─ All API endpoints require valid token
│
├─ User Isolation
│  └─ Users can only access their own data
│
└─ Input Validation
   └─ All inputs validated by serializers

Layer 4: Database
├─ Foreign Key Constraints
│  └─ Data integrity enforced at DB level
│
└─ User-scoped Queries
   └─ All queries filtered by user_id

External Services
├─ HTTPS for all external API calls
├─ API keys stored in environment variables
└─ Rate limiting on external API usage
```

---

## 🌐 API Endpoint Organization

```
/api/
├── auth/
│   ├── register/                    POST
│   ├── verify-otp/                  POST
│   ├── resend-otp/                  POST
│   ├── login/                       POST
│   ├── google-login/                POST
│   ├── request-password-reset/      POST
│   ├── reset-password/              POST
│   └── whatsapp-user/{phone}/       GET  (WhatsApp Bot)
│
└── finance/
    ├── dashboard/                   GET
    ├── report/                      GET
    │
    ├── transactions/
    │   ├── /                        GET, POST
    │   ├── /{id}/                   GET, PUT, DELETE
    │   ├── save-transaction/        POST
    │   ├── scan-receipt/            POST  (Multimodal)
    │   ├── scan-voice/              POST  (Multimodal)
    │   ├── chat-input/              POST  (Multimodal)
    │   ├── monthly-summary/         GET
    │   └── all-time-stats/          GET
    │
    ├── categories/                  CRUD
    ├── budgets/                     CRUD
    ├── savings-goals/               CRUD
    │
    └── investments/
        ├── /                        GET, POST
        ├── /{id}/                   GET, PUT, DELETE
        ├── portfolio-summary/       GET
        ├── /{id}/add-transaction/   POST
        └── search-crypto/           GET
```

---

## 🚀 Deployment Architecture (Future)

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRODUCTION DEPLOYMENT                         │
└─────────────────────────────────────────────────────────────────┘

Internet
   │
   ↓
┌──────────────┐
│ Load Balancer│
│  (Nginx)     │
└──────┬───────┘
       │
       ├─────────────────┬─────────────────┐
       ↓                 ↓                 ↓
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│ Django App  │   │ Django App  │   │ Django App  │
│ Instance 1  │   │ Instance 2  │   │ Instance 3  │
└──────┬──────┘   └──────┬──────┘   └──────┬──────┘
       │                 │                 │
       └─────────────────┴─────────────────┘
                        │
                        ↓
              ┌──────────────────┐
              │   PostgreSQL     │
              │   (Primary DB)   │
              └──────────────────┘

WhatsApp Bot (Separate Server)
   │
   ├─ Node.js Server (PM2)
   └─ Python Server (systemd)
```

---

## 📊 Component Responsibilities

### Django Backend
- **Responsibilities:**
  - User authentication & authorization
  - Business logic
  - Data persistence
  - API endpoints
  - Email sending

- **Technologies:**
  - Django 4.x
  - Django REST Framework
  - JWT Authentication
  - PostgreSQL/SQLite

### WhatsApp Bot (Node.js)
- **Responsibilities:**
  - WhatsApp Web connection
  - QR code authentication
  - Message sending/receiving
  - Session management

- **Technologies:**
  - Node.js + Express
  - whatsapp-web.js
  - Puppeteer

### WhatsApp Bot (Python)
- **Responsibilities:**
  - Message handling & routing
  - Security checks (whitelist, prefix, rate limit)
  - AI parsing
  - Backend API integration
  - Response formatting

- **Technologies:**
  - Python 3.8+
  - aiohttp (async HTTP)
  - Groq AI
  - requests

### External Services
- **Groq AI:**
  - Vision model (receipt scanning)
  - Whisper (speech-to-text)
  - LLaMA 3.3 (text parsing)

- **CoinGecko:**
  - Cryptocurrency prices

- **Yahoo Finance:**
  - Stock prices

- **Gmail SMTP:**
  - Email sending

---

## 🔧 Configuration Files

```
ManKu/
├── .env                          # Environment variables
│   ├── SECRET_KEY
│   ├── DATABASE_URL
│   ├── EMAIL_HOST_USER
│   ├── EMAIL_HOST_PASSWORD
│   ├── GROQ_API_KEY
│   └── GOOGLE_CLIENT_ID
│
├── core/settings.py              # Django settings
├── whatsapp_bot/bot_config.py   # Bot configuration
├── whatsapp_bot/package.json    # Node.js dependencies
└── requirements.txt              # Python dependencies
```

---

## 📈 Scalability Considerations

### Current Architecture (Single Server):
- ✅ Good for: <100 concurrent users
- ✅ Easy to setup & maintain
- ✅ Cost-effective

### Future Scaling Options:

1. **Horizontal Scaling (Multiple Django Instances)**
   - Add load balancer (Nginx)
   - Run multiple Django instances
   - Share database & cache

2. **Database Optimization**
   - Add database indexes
   - Implement query caching
   - Use read replicas

3. **WhatsApp Bot Scaling**
   - Multiple bot instances (different phone numbers)
   - Queue system for message processing
   - Redis for session management

4. **Caching Layer**
   - Redis for:
     - Price cache
     - User sessions
     - API rate limiting
     - Frequent queries

---

**System Architecture Complete! 🎉**
