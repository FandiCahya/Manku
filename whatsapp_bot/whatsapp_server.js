/**
 * WhatsApp Web Server using whatsapp-web.js
 * This Node.js server handles WhatsApp Web connection and message forwarding
 */

const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const express = require('express');
const bodyParser = require('body-parser');

// Initialize Express server for API endpoints
const app = express();
app.use(bodyParser.json());

const path = require('path');
// Load environment variables from root .env file
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

// Puppeteer configuration that automatically adapts to Windows/Linux VPS environment
const puppeteerOptions = {
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
};

if (process.platform === 'linux') {
    puppeteerOptions.executablePath = process.env.PUPPETEER_EXECUTABLE_PATH || '/usr/bin/chromium-browser';
    puppeteerOptions.args.push(
        '--disable-dev-shm-usage',
        '--disable-accelerated-2d-canvas',
        '--no-first-run',
        '--no-zygote',
        '--single-process',
        '--disable-gpu'
    );
}

// Initialize WhatsApp client
const client = new Client({
    authStrategy: new LocalAuth({
        clientId: 'manku-bot'
    }),
    authTimeoutMs: 120000,
    puppeteer: puppeteerOptions
});

// Store message handler callback
let pythonMessageHandler = null;

// ══════════════════════════════════════════════════════════════════════════════
// WHATSAPP CLIENT EVENTS
// ══════════════════════════════════════════════════════════════════════════════

client.on('qr', (qr) => {
    console.log('📱 QR Code received! Please scan with WhatsApp:');
    qrcode.generate(qr, { small: true });
});

client.on('ready', () => {
    console.log('✅ WhatsApp Bot is ready!');
    console.log('🤖 Bot is now listening for messages...');
});

client.on('authenticated', () => {
    console.log('✅ Authenticated with WhatsApp');
});

client.on('auth_failure', (msg) => {
    console.error('❌ Authentication failed:', msg);
});

client.on('disconnected', (reason) => {
    console.log('❌ WhatsApp disconnected:', reason);
});

// Handle incoming messages
client.on('message', async (message) => {
    try {
        const contact = await message.getContact();
        const chat = await message.getChat();
        
        // Get phone number (without @c.us)
        const fromNumber = message.from.split('@')[0];
        
        // Message data
        const messageData = {
            from: message.from,
            body: message.body,
            timestamp: message.timestamp,
            name: contact.pushname || contact.name || 'Unknown',
            isGroup: chat.isGroup
        };
        
        console.log(`📩 Message from ${messageData.name} (${fromNumber}): ${message.body}`);
        
        // Skip group messages
        if (chat.isGroup) {
            console.log('⏭️ Skipping group message');
            return;
        }
        
        // Forward to Python handler via HTTP
        forwardMessageToPython(messageData);
        
    } catch (error) {
        console.error('❌ Error handling message:', error);
    }
});

// ══════════════════════════════════════════════════════════════════════════════
// HTTP API ENDPOINTS
// ══════════════════════════════════════════════════════════════════════════════

// Endpoint to send message
app.post('/send-message', async (req, res) => {
    try {
        const { chatId, message } = req.body;
        
        if (!chatId || !message) {
            return res.status(400).json({ 
                success: false, 
                error: 'chatId and message are required' 
            });
        }
        
        // Send message via WhatsApp
        await client.sendMessage(chatId, message);
        
        console.log(`📤 Sent message to ${chatId}`);
        
        res.json({ 
            success: true, 
            message: 'Message sent successfully' 
        });
        
    } catch (error) {
        console.error('❌ Error sending message:', error);
        res.status(500).json({ 
            success: false, 
            error: error.message 
        });
    }
});

// Endpoint to check bot status
app.get('/status', (req, res) => {
    const isConnected = client.info !== undefined;
    res.json({
        success: true,
        connected: isConnected,
        info: client.info
    });
});

// Endpoint to get QR code (for web interface)
app.get('/qr', (req, res) => {
    if (client.info) {
        res.json({ success: true, message: 'Already authenticated' });
    } else {
        res.json({ success: false, message: 'Waiting for QR code...' });
    }
});

// ══════════════════════════════════════════════════════════════════════════════
// MESSAGE FORWARDING TO PYTHON
// ══════════════════════════════════════════════════════════════════════════════

async function forwardMessageToPython(messageData) {
    try {
        // Forward message to Python handler via HTTP
        const axios = require('axios');
        
        await axios.post('http://localhost:8001/whatsapp/incoming', messageData, {
            timeout: 5000
        });
        
        console.log('✅ Message forwarded to Python handler');
        
    } catch (error) {
        console.error('❌ Error forwarding to Python:', error.message);
        // Continue even if forwarding fails
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// START SERVER
// ══════════════════════════════════════════════════════════════════════════════

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`🚀 WhatsApp Bot Server running on http://localhost:${PORT}`);
    console.log('📱 Starting WhatsApp client...');
    
    // Initialize WhatsApp client
    client.initialize();
});

// Graceful shutdown
process.on('SIGINT', async () => {
    console.log('\n🛑 Shutting down gracefully...');
    await client.destroy();
    process.exit(0);
});
