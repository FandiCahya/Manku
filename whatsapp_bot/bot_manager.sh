#!/bin/bash

# ============================================================================
# ManKu WhatsApp Bot - Management Script
# Quick commands to manage the bot
# ============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_DIR="/var/log/manku"

show_help() {
    echo "============================================================================"
    echo "🤖 ManKu WhatsApp Bot Manager"
    echo "============================================================================"
    echo ""
    echo "Usage: ./bot_manager.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start         Start bot services"
    echo "  stop          Stop bot services"
    echo "  restart       Restart bot services"
    echo "  status        Show service status"
    echo "  logs          Show all logs (real-time)"
    echo "  logs-node     Show Node.js logs"
    echo "  logs-python   Show Python logs"
    echo "  logs-bot      Show bot application logs"
    echo "  errors        Show error logs"
    echo "  qr            Show QR code from logs"
    echo "  test          Test bot health"
    echo "  clean-logs    Clean old logs"
    echo ""
    echo "Examples:"
    echo "  ./bot_manager.sh start"
    echo "  ./bot_manager.sh logs"
    echo "  ./bot_manager.sh restart"
    echo ""
}

start_services() {
    echo -e "${YELLOW}Starting WhatsApp Bot services...${NC}"
    sudo systemctl start manku-whatsapp-node
    sleep 5
    sudo systemctl start manku-whatsapp-python
    echo -e "${GREEN}✅ Services started${NC}"
    show_status
}

stop_services() {
    echo -e "${YELLOW}Stopping WhatsApp Bot services...${NC}"
    sudo systemctl stop manku-whatsapp-python
    sudo systemctl stop manku-whatsapp-node
    echo -e "${GREEN}✅ Services stopped${NC}"
}

restart_services() {
    echo -e "${YELLOW}Restarting WhatsApp Bot services...${NC}"
    sudo systemctl restart manku-whatsapp-node
    sleep 5
    sudo systemctl restart manku-whatsapp-python
    echo -e "${GREEN}✅ Services restarted${NC}"
    show_status
}

show_status() {
    echo ""
    echo -e "${BLUE}📊 Service Status:${NC}"
    echo "----------------------------------------"
    
    if sudo systemctl is-active --quiet manku-whatsapp-node; then
        echo -e "Node.js:  ${GREEN}●${NC} Running"
    else
        echo -e "Node.js:  ${RED}●${NC} Stopped"
    fi
    
    if sudo systemctl is-active --quiet manku-whatsapp-python; then
        echo -e "Python:   ${GREEN}●${NC} Running"
    else
        echo -e "Python:   ${RED}●${NC} Stopped"
    fi
    
    echo "----------------------------------------"
    echo ""
    
    # Show uptime
    echo -e "${BLUE}⏱️  Uptime:${NC}"
    sudo systemctl show manku-whatsapp-node --property=ActiveEnterTimestamp | cut -d= -f2
    echo ""
}

show_logs() {
    echo -e "${YELLOW}📜 Showing all logs (Ctrl+C to exit)...${NC}"
    tail -f $LOG_DIR/whatsapp-python.log \
            $LOG_DIR/whatsapp-node.log \
            $LOG_DIR/whatsapp_bot.log 2>/dev/null
}

show_node_logs() {
    echo -e "${YELLOW}📜 Showing Node.js logs (Ctrl+C to exit)...${NC}"
    tail -f $LOG_DIR/whatsapp-node.log
}

show_python_logs() {
    echo -e "${YELLOW}📜 Showing Python logs (Ctrl+C to exit)...${NC}"
    tail -f $LOG_DIR/whatsapp-python.log
}

show_bot_logs() {
    echo -e "${YELLOW}📜 Showing bot application logs (Ctrl+C to exit)...${NC}"
    tail -f $LOG_DIR/whatsapp_bot.log
}

show_errors() {
    echo -e "${RED}❌ Recent Errors:${NC}"
    echo "----------------------------------------"
    echo -e "${YELLOW}Node.js Errors:${NC}"
    tail -20 $LOG_DIR/whatsapp-node.error.log 2>/dev/null || echo "No errors"
    echo ""
    echo -e "${YELLOW}Python Errors:${NC}"
    tail -20 $LOG_DIR/whatsapp-python.error.log 2>/dev/null || echo "No errors"
    echo "----------------------------------------"
}

show_qr() {
    echo -e "${YELLOW}📱 Looking for QR code in recent logs...${NC}"
    echo "----------------------------------------"
    tail -100 $LOG_DIR/whatsapp-node.log | grep -A 20 "QR Code" || echo "QR code not found. Bot might be already authenticated."
    echo "----------------------------------------"
}

test_bot() {
    echo -e "${BLUE}🧪 Testing Bot Health...${NC}"
    echo "----------------------------------------"
    
    # Check if ports are listening
    echo -n "Port 3000 (Node.js): "
    if sudo netstat -tulpn | grep -q ":3000"; then
        echo -e "${GREEN}✅ Listening${NC}"
    else
        echo -e "${RED}❌ Not listening${NC}"
    fi
    
    echo -n "Port 8001 (Python):  "
    if sudo netstat -tulpn | grep -q ":8001"; then
        echo -e "${GREEN}✅ Listening${NC}"
    else
        echo -e "${RED}❌ Not listening${NC}"
    fi
    
    # Check if authenticated
    echo -n "WhatsApp Auth:       "
    if tail -100 $LOG_DIR/whatsapp-node.log | grep -q "ready"; then
        echo -e "${GREEN}✅ Authenticated${NC}"
    else
        echo -e "${YELLOW}⚠️  Not authenticated (need QR scan)${NC}"
    fi
    
    # Check recent activity
    echo ""
    echo "Recent Activity (last 5 lines):"
    tail -5 $LOG_DIR/whatsapp-python.log 2>/dev/null || echo "No recent activity"
    
    echo "----------------------------------------"
}

clean_logs() {
    echo -e "${YELLOW}🧹 Cleaning old logs...${NC}"
    
    # Backup current logs
    BACKUP_DIR="$LOG_DIR/backup_$(date +%Y%m%d)"
    sudo mkdir -p "$BACKUP_DIR"
    sudo cp $LOG_DIR/*.log "$BACKUP_DIR/" 2>/dev/null
    
    # Clear logs
    sudo truncate -s 0 $LOG_DIR/*.log 2>/dev/null
    
    echo -e "${GREEN}✅ Logs cleaned and backed up to $BACKUP_DIR${NC}"
}

# Main
case "$1" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    logs-node)
        show_node_logs
        ;;
    logs-python)
        show_python_logs
        ;;
    logs-bot)
        show_bot_logs
        ;;
    errors)
        show_errors
        ;;
    qr)
        show_qr
        ;;
    test)
        test_bot
        ;;
    clean-logs)
        clean_logs
        ;;
    *)
        show_help
        ;;
esac
