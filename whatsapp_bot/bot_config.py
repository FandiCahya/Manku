"""
WhatsApp Bot Configuration
"""
import os
from dotenv import load_dotenv

load_dotenv()

# ══════════════════════════════════════════════════════════════════════════════
# BOT CONFIGURATION
# ══════════════════════════════════════════════════════════════════════════════

# WhatsApp Configuration
WHATSAPP_ENABLED = True
BOT_PHONE_NUMBER = os.getenv('BOT_PHONE_NUMBER', '')  # Nomor bot (e.g., 628123456789)

# Command Prefix
COMMAND_PREFIX = '/manku'  # Perintah harus diawali dengan ini
ALTERNATIVE_PREFIX = '!m'   # Alternatif prefix yang lebih pendek

# Allowed Phone Numbers (Whitelist)
# Format: 628xxx (tanpa +, tanpa spasi) - loaded from ALLOWED_PHONE_NUMBERS env variable
ALLOWED_PHONE_NUMBERS = [
    num.strip() for num in os.getenv('ALLOWED_PHONE_NUMBERS', '628123456789').split(',') if num.strip()
]

# Backend Configuration
BACKEND_URL = os.getenv('BACKEND_URL', 'http://127.0.0.1:8000')
BACKEND_API_URL = f'{BACKEND_URL}/api'

# AI Configuration (Groq)
GROQ_API_KEY = os.getenv('GROQ_API_KEY', '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')
AI_MODEL = 'llama-3.3-70b-versatile'

# Bot Features
FEATURES = {
    'transaction_input': True,      # Input transaksi
    'balance_check': True,          # Cek saldo
    'report_summary': True,         # Lihat report
    'investment_check': True,       # Cek investasi
    'help_command': True,           # Command /help
}

# Security
RATE_LIMIT_PER_MINUTE = 10  # Maksimal 10 pesan per menit per user
SESSION_TIMEOUT = 3600       # Session timeout (1 jam)

# Logging
LOG_LEVEL = 'INFO'
LOG_FILE = 'whatsapp_bot.log'

# ══════════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ══════════════════════════════════════════════════════════════════════════════

def is_phone_allowed(phone_number):
    """Check if phone number is in whitelist"""
    # Normalize phone number
    phone = phone_number.replace('+', '').replace('-', '').replace(' ', '')
    return phone in ALLOWED_PHONE_NUMBERS

def has_valid_prefix(message):
    """Check if message has valid command prefix"""
    message = message.strip()
    return message.startswith(COMMAND_PREFIX) or message.startswith(ALTERNATIVE_PREFIX)

def remove_prefix(message):
    """Remove command prefix from message"""
    message = message.strip()
    if message.startswith(COMMAND_PREFIX):
        return message[len(COMMAND_PREFIX):].strip()
    elif message.startswith(ALTERNATIVE_PREFIX):
        return message[len(ALTERNATIVE_PREFIX):].strip()
    return message
