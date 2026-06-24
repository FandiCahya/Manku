#!/bin/bash

# ============================================================================
# Quick Setup Script - Create WhatsApp Bot Files on Server
# Run this on Oracle Cloud server to create all necessary files
# ============================================================================

echo "🚀 Creating WhatsApp Bot files..."

PROJECT_DIR="/var/www/ManKu"
BOT_DIR="$PROJECT_DIR/whatsapp_bot"

# Create directory
mkdir -p "$BOT_DIR"
cd "$BOT_DIR"

echo "📁 Directory created: $BOT_DIR"

# Create __init__.py
cat > __init__.py << 'EOF'
"""
ManKu WhatsApp Bot Package
"""
__version__ = '1.0.0'
EOF

echo "✅ Created __init__.py"

# Create requirements.txt
cat > requirements.txt << 'EOF'
# WhatsApp Bot Python Dependencies

# Groq AI
groq>=0.4.0

# HTTP client
requests>=2.31.0

# Async HTTP server
aiohttp>=3.9.0

# Environment variables
python-dotenv>=1.0.0
EOF

echo "✅ Created requirements.txt"

# Create package.json
cat > package.json << 'EOF'
{
  "name": "manku-whatsapp-bot",
  "version": "1.0.0",
  "description": "WhatsApp Bot for ManKu Finance App",
  "main": "whatsapp_server.js",
  "scripts": {
    "start": "node whatsapp_server.js"
  },
  "keywords": ["whatsapp", "bot", "finance", "manku"],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "whatsapp-web.js": "^1.23.0",
    "qrcode-terminal": "^0.12.0",
    "express": "^4.18.2",
    "body-parser": "^1.20.2",
    "axios": "^1.6.0"
  }
}
EOF

echo "✅ Created package.json"

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Copy Python files to $BOT_DIR/"
echo "   - bot_config.py"
echo "   - whatsapp_client.py"
echo "   - message_handler.py"
echo "   - ai_parser.py"
echo "   - backend_integration.py"
echo "   - bot_commands.py"
echo "   - run_bot.py"
echo "   - whatsapp_server.js"
echo ""
echo "2. Install dependencies:"
echo "   cd $BOT_DIR"
echo "   pip3 install -r requirements.txt"
echo "   npm install"
echo ""
echo "3. Run deploy script"
echo ""
