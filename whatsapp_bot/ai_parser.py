"""
AI Parser for Transaction Messages
Uses Groq AI to parse natural language into structured transaction data
"""
import json
import logging
from typing import Dict, Any, Optional
from groq import Groq
from datetime import datetime

from .bot_config import GROQ_API_KEY, AI_MODEL

logger = logging.getLogger(__name__)


class AIParser:
    """Parse natural language messages into structured transaction data"""
    
    def __init__(self):
        self.client = Groq(api_key=GROQ_API_KEY)
        self.model = AI_MODEL
        logger.info(f"✅ AIParser initialized with model: {self.model}")
    
    async def parse_transaction(self, message: str) -> Optional[Dict[str, Any]]:
        """
        Parse natural language message into transaction data
        
        Args:
            message: Natural language message (e.g., "beli kopi 25000")
        
        Returns:
            Dict with keys: amount, description, type, category_hint
            or None if parsing fails
        """
        try:
            prompt = self._build_parsing_prompt(message)
            
            # Call Groq AI
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": """Anda adalah asisten AI untuk aplikasi keuangan ManKu. 
Tugas Anda adalah mengekstrak informasi transaksi dari pesan pengguna dalam bahasa Indonesia.

ATURAN PENTING:
1. Identifikasi jumlah uang (amount) - bisa dalam format: 25000, 25rb, 25ribu, 25k, dll
2. Tentukan tipe transaksi (type): "income" atau "expense"
3. Ekstrak deskripsi transaksi
4. Tentukan kategori yang sesuai
5. SELALU response dalam format JSON yang valid

KATEGORI EXPENSE:
Makanan & Minuman, Transport, Belanja, Tagihan, Hiburan, Kesehatan, Pendidikan, Lainnya

KATEGORI INCOME:
Gaji, Bisnis, Investasi, Hadiah, Lainnya

CONTOH INPUT & OUTPUT:
Input: "beli kopi 25000"
Output: {"amount": 25000, "description": "beli kopi", "type": "expense", "category_hint": "Makanan & Minuman"}

Input: "terima gaji 5 juta"
Output: {"amount": 5000000, "description": "terima gaji", "type": "income", "category_hint": "Gaji"}

Input: "bayar listrik 500rb"
Output: {"amount": 500000, "description": "bayar listrik", "type": "expense", "category_hint": "Tagihan"}

RESPONSE HARUS JSON MURNI, TIDAK ADA TEKS TAMBAHAN!"""
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.1,
                max_tokens=500
            )
            
            # Extract response
            ai_response = response.choices[0].message.content.strip()
            logger.info(f"AI Response: {ai_response}")
            
            # Parse JSON
            transaction_data = self._parse_ai_response(ai_response)
            
            if transaction_data:
                logger.info(f"✅ Parsed transaction: {transaction_data}")
                return transaction_data
            else:
                logger.warning("❌ Failed to parse transaction from AI response")
                return None
                
        except Exception as e:
            logger.error(f"❌ Error parsing transaction: {str(e)}", exc_info=True)
            return None
    
    def _build_parsing_prompt(self, message: str) -> str:
        """Build prompt for AI parsing"""
        return f"""Ekstrak informasi transaksi dari pesan berikut:

"{message}"

Response dalam format JSON dengan field: amount, description, type, category_hint"""
    
    def _parse_ai_response(self, response: str) -> Optional[Dict[str, Any]]:
        """Parse AI response into transaction data"""
        try:
            # Clean response (remove markdown code blocks if any)
            response = response.strip()
            if response.startswith('```json'):
                response = response[7:]
            if response.startswith('```'):
                response = response[3:]
            if response.endswith('```'):
                response = response[:-3]
            response = response.strip()
            
            # Parse JSON
            data = json.loads(response)
            
            # Validate required fields
            if 'amount' not in data:
                logger.error("Missing 'amount' field in AI response")
                return None
            
            # Set defaults
            data.setdefault('description', 'Transaksi')
            data.setdefault('type', 'expense')
            data.setdefault('category_hint', 'Lainnya')
            
            # Convert amount to float
            try:
                data['amount'] = float(data['amount'])
            except (ValueError, TypeError):
                logger.error(f"Invalid amount value: {data['amount']}")
                return None
            
            # Validate type
            if data['type'] not in ['income', 'expense']:
                data['type'] = 'expense'
            
            return data
            
        except json.JSONDecodeError as e:
            logger.error(f"JSON decode error: {str(e)}")
            logger.error(f"Response was: {response}")
            return None
        except Exception as e:
            logger.error(f"Error parsing AI response: {str(e)}")
            return None
    
    def _normalize_amount(self, amount_str: str) -> Optional[float]:
        """
        Normalize amount string to number
        Examples: 25rb -> 25000, 5juta -> 5000000, 100k -> 100000
        """
        try:
            amount_str = amount_str.lower().replace('.', '').replace(',', '')
            
            # Handle "rb", "ribu", "k"
            if 'rb' in amount_str or 'ribu' in amount_str:
                num = ''.join(filter(str.isdigit, amount_str))
                return float(num) * 1000
            
            if 'k' in amount_str:
                num = ''.join(filter(str.isdigit, amount_str))
                return float(num) * 1000
            
            # Handle "jt", "juta", "m"
            if 'jt' in amount_str or 'juta' in amount_str or 'm' in amount_str:
                num = ''.join(filter(str.isdigit, amount_str))
                return float(num) * 1000000
            
            # Plain number
            num = ''.join(filter(str.isdigit, amount_str))
            return float(num) if num else None
            
        except Exception as e:
            logger.error(f"Error normalizing amount '{amount_str}': {str(e)}")
            return None
