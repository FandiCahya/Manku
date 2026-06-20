#!/bin/bash

# ============================================================================
# ManKu WhatsApp Bot - Oracle Cloud Deployment Script
# ============================================================================

echo "============================================================================"
echo "🚀 ManKu WhatsApp Bot - Oracle Cloud Deployment"
echo "============================================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/path/to/ManKu"  # 🔴 CHANGE THIS
VENV_DIR="$PROJECT_DIR/venv"
BOT_DIR="$PROJECT_DIR/whatsapp_bot"
LOG_DIR="/var/log/manku"

echo -e "${YELLOW}📋 Configuration:${NC}"
echo "   Project Directory: $PROJECT_DIR"
echo "   Bot Directory: $BOT_DIR"
echo "   Log Directory: $LOG_DIR"
echo ""

# Function to check command status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1 failed!${NC}"
        exit 1
    fi
}

# Step 1: Check prerequisites
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"

command -v python3 >/dev/null 2>&1
check_status "Python3 installed"

command -v node >/dev/null 2>&1
check_status "Node.js installed"

command -v npm >/dev/null 2>&1
check_status "npm installed"

echo ""

# Step 2: Install Python dependencies
echo -e "${YELLOW}Step 2: Installing Python dependencies...${NC}"
cd "$BOT_DIR"

if [ -d "$VENV_DIR" ]; then
    source "$VENV_DIR/bin/activate"
    echo "   Virtual environment activated"
fi

pip3 install -r requirements.txt > /dev/null 2>&1
check_status "Python dependencies installed"

echo ""

# Step 3: Install Node.js dependencies
echo -e "${YELLOW}Step 3: Installing Node.js dependencies...${NC}"
npm install > /dev/null 2>&1
check_status "Node.js dependencies installed"

echo ""

# Step 4: Create log directory
echo -e "${YELLOW}Step 4: Creating log directory...${NC}"
sudo mkdir -p "$LOG_DIR" 2>/dev/null
sudo chown $USER:$USER "$LOG_DIR" 2>/dev/null
check_status "Log directory created"

echo ""

# Step 5: Run database migrations
echo -e "${YELLOW}Step 5: Running database migrations...${NC}"
cd "$PROJECT_DIR"

if [ -d "$VENV_DIR" ]; then
    source "$VENV_DIR/bin/activate"
fi

python manage.py makemigrations accounts > /dev/null 2>&1
python manage.py migrate > /dev/null 2>&1
check_status "Database migrations completed"

echo ""

# Step 6: Setup systemd services
echo -e "${YELLOW}Step 6: Setting up systemd services...${NC}"

# Create Node.js service
sudo tee /etc/systemd/system/manku-whatsapp-node.service > /dev/null <<EOF
[Unit]
Description=ManKu WhatsApp Bot - Node.js Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$BOT_DIR
Environment="NODE_ENV=production"
ExecStart=/usr/bin/node whatsapp_server.js
Restart=always
RestartSec=10
StandardOutput=append:$LOG_DIR/whatsapp-node.log
StandardError=append:$LOG_DIR/whatsapp-node.error.log

[Install]
WantedBy=multi-user.target
EOF

check_status "Node.js service created"

# Create Python service
sudo tee /etc/systemd/system/manku-whatsapp-python.service > /dev/null <<EOF
[Unit]
Description=ManKu WhatsApp Bot - Python Server
After=network.target manku-whatsapp-node.service
Requires=manku-whatsapp-node.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$BOT_DIR
Environment="PYTHONUNBUFFERED=1"
ExecStart=/usr/bin/python3 run_bot.py
Restart=always
RestartSec=10
StandardOutput=append:$LOG_DIR/whatsapp-python.log
StandardError=append:$LOG_DIR/whatsapp-python.error.log

[Install]
WantedBy=multi-user.target
EOF

check_status "Python service created"

echo ""

# Step 7: Reload systemd
echo -e "${YELLOW}Step 7: Reloading systemd...${NC}"
sudo systemctl daemon-reload
check_status "Systemd reloaded"

echo ""

# Step 8: Enable services
echo -e "${YELLOW}Step 8: Enabling services...${NC}"
sudo systemctl enable manku-whatsapp-node > /dev/null 2>&1
check_status "Node.js service enabled"

sudo systemctl enable manku-whatsapp-python > /dev/null 2>&1
check_status "Python service enabled"

echo ""

# Step 9: Start services
echo -e "${YELLOW}Step 9: Starting services...${NC}"

sudo systemctl start manku-whatsapp-node
check_status "Node.js service started"

echo "   Waiting 10 seconds for Node.js to initialize..."
sleep 10

sudo systemctl start manku-whatsapp-python
check_status "Python service started"

echo ""

# Step 10: Check service status
echo -e "${YELLOW}Step 10: Checking service status...${NC}"

if sudo systemctl is-active --quiet manku-whatsapp-node; then
    echo -e "${GREEN}✅ Node.js service is running${NC}"
else
    echo -e "${RED}❌ Node.js service is not running${NC}"
fi

if sudo systemctl is-active --quiet manku-whatsapp-python; then
    echo -e "${GREEN}✅ Python service is running${NC}"
else
    echo -e "${RED}❌ Python service is not running${NC}"
fi

echo ""

# Summary
echo "============================================================================"
echo -e "${GREEN}🎉 Deployment Complete!${NC}"
echo "============================================================================"
echo ""
echo "📋 Next Steps:"
echo "   1. Check logs: tail -f $LOG_DIR/whatsapp-python.log"
echo "   2. Look for QR code in logs to scan with WhatsApp"
echo "   3. Test bot by sending: /manku help"
echo ""
echo "🔧 Useful Commands:"
echo "   • View logs:    tail -f $LOG_DIR/*.log"
echo "   • Check status: sudo systemctl status manku-whatsapp-*"
echo "   • Restart:      sudo systemctl restart manku-whatsapp-node manku-whatsapp-python"
echo ""
echo "📱 To scan QR code:"
echo "   tail -f $LOG_DIR/whatsapp-node.log"
echo ""
echo "============================================================================"
