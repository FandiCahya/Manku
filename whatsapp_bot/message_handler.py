"""
WhatsApp Message Handler
Handles incoming messages, routing, and command processing
"""
import logging
from typing import Dict, Any, Optional
from datetime import datetime, timedelta

from .bot_config import (
    is_phone_allowed, 
    has_valid_prefix, 
    remove_prefix,
    RATE_LIMIT_PER_MINUTE
)
from .ai_parser import AIParser
from .backend_integration import BackendAPI
from .bot_commands import BotCommands
from .whatsapp_client import get_whatsapp_client

logger = logging.getLogger(__name__)


class RateLimiter:
    """Simple rate limiter per user"""
    
    def __init__(self):
        self.user_requests = {}  # {phone: [timestamp1, timestamp2, ...]}
    
    def is_allowed(self, phone_number: str) -> bool:
        """Check if user can send message (rate limit check)"""
        now = datetime.now()
        one_minute_ago = now - timedelta(minutes=1)
        
        # Clean old timestamps
        if phone_number in self.user_requests:
            self.user_requests[phone_number] = [
                ts for ts in self.user_requests[phone_number] 
                if ts > one_minute_ago
            ]
        else:
            self.user_requests[phone_number] = []
        
        # Check rate limit
        if len(self.user_requests[phone_number]) >= RATE_LIMIT_PER_MINUTE:
            return False
        
        # Add current request
        self.user_requests[phone_number].append(now)
        return True


class MessageHandler:
    """Main message handler for WhatsApp bot"""
    
    def __init__(self):
        self.whatsapp_client = get_whatsapp_client()
        self.ai_parser = AIParser()
        self.backend_api = BackendAPI()
        self.bot_commands = BotCommands(self.backend_api)
        self.rate_limiter = RateLimiter()
        
        logger.info("✅ MessageHandler initialized")
    
    async def handle_incoming_message(self, message_data: Dict[str, Any]) -> None:
        """
        Handle incoming WhatsApp message
        
        Args:
            message_data: {
                'from': '628123456789@c.us',
                'body': 'message text',
                'timestamp': 1234567890,
                'name': 'Contact Name'
            }
        """
        try:
            # Extract message info
            from_number = self._extract_phone_number(message_data['from'])
            message_body = message_data.get('body', '').strip()
            contact_name = message_data.get('name', 'Unknown')
            
            logger.info(f"📩 Received message from {contact_name} ({from_number}): {message_body[:50]}...")
            
            # Security checks
            if not self._is_message_allowed(from_number, message_body):
                logger.warning(f"🚫 Message rejected from {from_number}")
                return
            
            # Rate limit check
            if not self.rate_limiter.is_allowed(from_number):
                await self._send_rate_limit_message(from_number)
                logger.warning(f"⚠️ Rate limit exceeded for {from_number}")
                return
            
            # Remove prefix
            clean_message = remove_prefix(message_body)
            
            # Route to appropriate handler
            await self._route_message(from_number, clean_message)
            
        except Exception as e:
            logger.error(f"❌ Error handling message: {str(e)}", exc_info=True)
            try:
                self.whatsapp_client.send_formatted_message(
                    from_number,
                    {
                        'type': 'error',
                        'message': 'Maaf, terjadi kesalahan. Silakan coba lagi.'
                    }
                )
            except:
                pass
    
    def _extract_phone_number(self, whatsapp_id: str) -> str:
        """Extract phone number from WhatsApp ID (628xxx@c.us -> 628xxx)"""
        return whatsapp_id.split('@')[0]
    
    def _is_message_allowed(self, phone_number: str, message: str) -> bool:
        """Check if message should be processed (whitelist + prefix check)"""
        # Check whitelist
        if not is_phone_allowed(phone_number):
            return False
        
        # Check prefix
        if not has_valid_prefix(message):
            return False
        
        return True
    
    async def _route_message(self, phone_number: str, message: str) -> None:
        """Route message to appropriate command handler"""
        
        # Convert message to lowercase for command matching
        message_lower = message.lower().strip()
        
        # Help command
        if message_lower.startswith('help') or message_lower == '?':
            await self._handle_help_command(phone_number)
            return
        
        # Balance command
        if message_lower.startswith('saldo') or message_lower.startswith('balance'):
            await self._handle_balance_command(phone_number)
            return
        
        # Report command
        if message_lower.startswith('report') or message_lower.startswith('laporan'):
            await self._handle_report_command(phone_number)
            return
        
        # Investment command
        if message_lower.startswith('investasi') or message_lower.startswith('investment'):
            await self._handle_investment_command(phone_number)
            return
        
        # Transaction command (default - parse with AI)
        await self._handle_transaction_command(phone_number, message)
    
    async def _handle_help_command(self, phone_number: str) -> None:
        """Handle help command"""
        help_text = """🤖 *ManKu Bot - Bantuan*

Perintah yang tersedia:

💰 *Transaksi (Default)*
Kirim deskripsi transaksi langsung:
• `/manku beli kopi 25000`
• `/manku terima gaji 5 juta`
• `!m bayar listrik 500rb`

📊 *Cek Saldo*
• `/manku saldo`
• `!m balance`

📈 *Report Bulanan*
• `/manku report`
• `!m laporan`

💼 *Cek Investasi*
• `/manku investasi`
• `!m investment`

❓ *Bantuan*
• `/manku help`
• `!m ?`

_Semua perintah harus diawali dengan /manku atau !m_
_Bot ini hanya merespon nomor yang terdaftar_ ✅"""
        
        self.whatsapp_client.send_formatted_message(
            phone_number,
            {
                'type': 'help',
                'message': help_text
            }
        )
    
    async def _handle_balance_command(self, phone_number: str) -> None:
        """Handle balance check command"""
        try:
            # Get user credentials for this phone number
            user_creds = self.backend_api.get_user_by_phone(phone_number)
            if not user_creds:
                self._send_not_registered_message(phone_number)
                return
            
            # Get balance from backend
            result = await self.bot_commands.get_balance(user_creds)
            
            if result['success']:
                self.whatsapp_client.send_formatted_message(
                    phone_number,
                    {
                        'type': 'balance',
                        **result['data']
                    }
                )
            else:
                self._send_error_message(phone_number, result.get('error', 'Gagal mengambil data saldo'))
                
        except Exception as e:
            logger.error(f"Error in balance command: {str(e)}")
            self._send_error_message(phone_number, str(e))
    
    async def _handle_report_command(self, phone_number: str) -> None:
        """Handle report command"""
        try:
            user_creds = self.backend_api.get_user_by_phone(phone_number)
            if not user_creds:
                self._send_not_registered_message(phone_number)
                return
            
            result = await self.bot_commands.get_report(user_creds)
            
            if result['success']:
                self.whatsapp_client.send_formatted_message(
                    phone_number,
                    {
                        'type': 'report',
                        **result['data']
                    }
                )
            else:
                self._send_error_message(phone_number, result.get('error', 'Gagal mengambil report'))
                
        except Exception as e:
            logger.error(f"Error in report command: {str(e)}")
            self._send_error_message(phone_number, str(e))
    
    async def _handle_investment_command(self, phone_number: str) -> None:
        """Handle investment check command"""
        try:
            user_creds = self.backend_api.get_user_by_phone(phone_number)
            if not user_creds:
                self._send_not_registered_message(phone_number)
                return
            
            result = await self.bot_commands.get_investment_summary(user_creds)
            
            if result['success']:
                self.whatsapp_client.send_formatted_message(
                    phone_number,
                    {
                        'type': 'investment',
                        **result['data']
                    }
                )
            else:
                self._send_error_message(phone_number, result.get('error', 'Gagal mengambil data investasi'))
                
        except Exception as e:
            logger.error(f"Error in investment command: {str(e)}")
            self._send_error_message(phone_number, str(e))
    
    async def _handle_transaction_command(self, phone_number: str, message: str) -> None:
        """Handle transaction input via AI parsing"""
        try:
            # Get user credentials
            user_creds = self.backend_api.get_user_by_phone(phone_number)
            if not user_creds:
                self._send_not_registered_message(phone_number)
                return
            
            # Send "processing" message
            self.whatsapp_client.send_message(phone_number, "⏳ Sedang memproses transaksi...")
            
            # Parse message with AI
            transaction_data = await self.ai_parser.parse_transaction(message)
            
            if not transaction_data or 'amount' not in transaction_data:
                self._send_error_message(
                    phone_number, 
                    "Maaf, saya tidak bisa memahami transaksi tersebut. Contoh: 'beli kopi 25000'"
                )
                return
            
            # Save transaction via backend
            result = await self.bot_commands.save_transaction(user_creds, transaction_data)
            
            if result['success']:
                self.whatsapp_client.send_formatted_message(
                    phone_number,
                    {
                        'type': 'transaction_saved',
                        **result['data']
                    }
                )
            else:
                self._send_error_message(phone_number, result.get('error', 'Gagal menyimpan transaksi'))
                
        except Exception as e:
            logger.error(f"Error in transaction command: {str(e)}")
            self._send_error_message(phone_number, f"Error: {str(e)}")
    
    def _send_not_registered_message(self, phone_number: str) -> None:
        """Send message when user is not registered"""
        message = """❌ *Nomor Belum Terdaftar*

Nomor WhatsApp Anda belum terhubung dengan akun ManKu.

Silakan hubungi admin untuk mendaftarkan nomor Anda."""
        
        self.whatsapp_client.send_message(phone_number, message)
    
    def _send_error_message(self, phone_number: str, error_msg: str) -> None:
        """Send error message"""
        self.whatsapp_client.send_formatted_message(
            phone_number,
            {
                'type': 'error',
                'message': error_msg
            }
        )
    
    async def _send_rate_limit_message(self, phone_number: str) -> None:
        """Send rate limit exceeded message"""
        message = "⚠️ Anda mengirim terlalu banyak pesan. Silakan tunggu 1 menit."
        self.whatsapp_client.send_message(phone_number, message)
