"""
WhatsApp Client using whatsapp-web.js
Wrapper untuk integrasi dengan Node.js WhatsApp Web client
"""
import json
import subprocess
import time
from typing import Optional, Dict, Any


class WhatsAppClient:
    """
    WhatsApp Client untuk mengirim dan menerima pesan
    Menggunakan whatsapp-web.js di Node.js
    """
    
    def __init__(self, session_name='manku-bot'):
        self.session_name = session_name
        self.is_ready = False
        self.qr_code = None
    
    def start(self):
        """Start WhatsApp client (via Node.js process)"""
        print("📱 Starting WhatsApp Bot...")
        print("⏳ Please scan QR code with your WhatsApp...")
        # Node.js process akan di-start secara terpisah
        # Lihat whatsapp_bot_node.js
        pass
    
    def send_message(self, phone_number: str, message: str) -> bool:
        """
        Send message to phone number
        
        Args:
            phone_number: Phone number with country code (e.g., 628123456789)
            message: Message text
        
        Returns:
            bool: True if sent successfully
        """
        try:
            # Format phone number untuk WhatsApp
            # WhatsApp format: 628123456789@c.us
            wa_id = f"{phone_number}@c.us"
            
            # Kirim via HTTP API ke Node.js server
            import requests
            response = requests.post(
                'http://localhost:3000/send-message',
                json={
                    'chatId': wa_id,
                    'message': message
                },
                timeout=10
            )
            
            return response.status_code == 200
            
        except Exception as e:
            print(f"❌ Error sending message: {str(e)}")
            return False
    
    def send_formatted_message(self, phone_number: str, data: Dict[str, Any]) -> bool:
        """
        Send formatted message (untuk response yang lebih terstruktur)
        
        Args:
            phone_number: Phone number
            data: Data untuk di-format
        
        Returns:
            bool: Success status
        """
        message = self._format_message(data)
        return self.send_message(phone_number, message)
    
    def _format_message(self, data: Dict[str, Any]) -> str:
        """Format data menjadi WhatsApp message yang rapi"""
        
        msg_type = data.get('type', 'text')
        
        if msg_type == 'transaction_saved':
            return f"""✅ *Transaksi Berhasil Disimpan!*

💰 *Nominal:* Rp {data['amount']:,.0f}
📝 *Deskripsi:* {data['description']}
🏷️ *Kategori:* {data['category']}
📊 *Tipe:* {data['type'].upper()}
📅 *Tanggal:* {data['date']}

Terima kasih sudah menggunakan ManKu! 🎉"""
        
        elif msg_type == 'balance':
            return f"""💰 *Saldo Anda*

📈 *Total Balance:* Rp {data['total_balance']:,.0f}
📊 *Total Income:* Rp {data['total_income']:,.0f}
📊 *Total Expense:* Rp {data['total_expense']:,.0f}

_Update: {data['timestamp']}_"""
        
        elif msg_type == 'report':
            monthly_income = data.get('monthly_income', 0)
            monthly_expense = data.get('monthly_expense', 0)
            
            report = f"""📊 *Report Bulan Ini*

💵 *Pemasukan:* Rp {monthly_income:,.0f}
💸 *Pengeluaran:* Rp {monthly_expense:,.0f}
📈 *Net:* Rp {monthly_income - monthly_expense:,.0f}
"""
            
            if 'top_categories' in data:
                report += "\n*Top Kategori Pengeluaran:*\n"
                for cat in data['top_categories'][:5]:
                    report += f"• {cat['name']}: Rp {cat['amount']:,.0f}\n"
            
            return report
        
        elif msg_type == 'investment':
            return f"""📈 *Portfolio Investasi*

💼 *Total Investment:* Rp {data['total_investment']:,.0f}
💰 *Current Value:* Rp {data['current_value']:,.0f}
📊 *Profit/Loss:* Rp {data['profit_loss']:,.0f} ({data['profit_loss_pct']:.2f}%)

🪙 *Crypto:* Rp {data['crypto_value']:,.0f}
📈 *Saham:* Rp {data['stock_value']:,.0f}"""
        
        elif msg_type == 'error':
            return f"""❌ *Error*

{data.get('message', 'Terjadi kesalahan')}

_Ketik /manku help untuk bantuan_"""
        
        elif msg_type == 'help':
            return data.get('message', '')
        
        else:
            return data.get('message', 'Response dari ManKu Bot')
    
    def get_contact_name(self, phone_number: str) -> Optional[str]:
        """Get contact name from phone number"""
        # Implementasi untuk mendapatkan nama kontak
        return None
    
    def is_connected(self) -> bool:
        """Check if WhatsApp is connected"""
        return self.is_ready


# Singleton instance
_whatsapp_client = None

def get_whatsapp_client(session_name='manku-bot') -> WhatsAppClient:
    """Get or create WhatsApp client instance"""
    global _whatsapp_client
    if _whatsapp_client is None:
        _whatsapp_client = WhatsAppClient(session_name)
    return _whatsapp_client
