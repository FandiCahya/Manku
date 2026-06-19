"""
Bot Commands
Implements all bot command handlers
"""
import logging
from typing import Dict, Any
from datetime import datetime

logger = logging.getLogger(__name__)


class BotCommands:
    """All bot command implementations"""
    
    def __init__(self, backend_api):
        self.backend_api = backend_api
        logger.info("✅ BotCommands initialized")
    
    async def get_balance(self, user_creds: Dict[str, str]) -> Dict[str, Any]:
        """
        Get user balance summary
        
        Returns:
            Dict with success, data (total_balance, total_income, total_expense, timestamp)
        """
        try:
            result = self.backend_api.get_dashboard_data(user_creds)
            
            if not result['success']:
                return result
            
            data = result['data']
            
            return {
                'success': True,
                'data': {
                    'total_balance': data.get('total_balance', 0),
                    'total_income': data.get('total_income', 0),
                    'total_expense': data.get('total_expense', 0),
                    'timestamp': datetime.now().strftime('%d %b %Y, %H:%M')
                }
            }
            
        except Exception as e:
            logger.error(f"Error in get_balance: {str(e)}")
            return {'success': False, 'error': str(e)}
    
    async def get_report(self, user_creds: Dict[str, str]) -> Dict[str, Any]:
        """
        Get monthly report
        
        Returns:
            Dict with success, data (monthly_income, monthly_expense, top_categories)
        """
        try:
            result = self.backend_api.get_report_data(user_creds)
            
            if not result['success']:
                return result
            
            data = result['data']
            
            # Extract top expense categories
            top_categories = []
            expense_breakdown = data.get('expense_breakdown', [])
            for item in expense_breakdown[:5]:  # Top 5
                top_categories.append({
                    'name': item.get('category', 'Lainnya'),
                    'amount': item.get('total', 0)
                })
            
            return {
                'success': True,
                'data': {
                    'monthly_income': data.get('total_income', 0),
                    'monthly_expense': data.get('total_expense', 0),
                    'top_categories': top_categories
                }
            }
            
        except Exception as e:
            logger.error(f"Error in get_report: {str(e)}")
            return {'success': False, 'error': str(e)}
    
    async def get_investment_summary(self, user_creds: Dict[str, str]) -> Dict[str, Any]:
        """
        Get investment portfolio summary
        
        Returns:
            Dict with success, data (total_investment, current_value, profit_loss, etc.)
        """
        try:
            result = self.backend_api.get_investment_portfolio(user_creds)
            
            if not result['success']:
                return result
            
            data = result['data']
            
            # Calculate values by type
            crypto_value = 0
            stock_value = 0
            
            for asset in data.get('assets', []):
                if asset.get('asset_type') == 'CRYPTO':
                    crypto_value += asset.get('current_value', 0)
                elif asset.get('asset_type') == 'STOCK':
                    stock_value += asset.get('current_value', 0)
            
            return {
                'success': True,
                'data': {
                    'total_investment': data.get('total_investment', 0),
                    'current_value': data.get('total_current_value', 0),
                    'profit_loss': data.get('total_profit_loss', 0),
                    'profit_loss_pct': data.get('total_profit_loss_percentage', 0),
                    'crypto_value': crypto_value,
                    'stock_value': stock_value
                }
            }
            
        except Exception as e:
            logger.error(f"Error in get_investment_summary: {str(e)}")
            return {'success': False, 'error': str(e)}
    
    async def save_transaction(self, user_creds: Dict[str, str], transaction_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Save transaction
        
        Args:
            user_creds: User credentials
            transaction_data: Transaction data (amount, description, type, category_hint)
        
        Returns:
            Dict with success and data
        """
        try:
            result = self.backend_api.save_transaction(user_creds, transaction_data)
            return result
            
        except Exception as e:
            logger.error(f"Error in save_transaction: {str(e)}")
            return {'success': False, 'error': str(e)}
