"""
Backend Integration
Handles authentication and API calls to Django backend
"""
import logging
import requests
from typing import Dict, Any, Optional
from datetime import datetime

from .bot_config import BACKEND_API_URL

logger = logging.getLogger(__name__)


class BackendAPI:
    """Interface to ManKu Django backend"""
    
    def __init__(self):
        self.base_url = BACKEND_API_URL
        self.user_mapping = {}  # {phone_number: {username, token}}
        logger.info(f"✅ BackendAPI initialized with URL: {self.base_url}")
    
    def get_user_by_phone(self, phone_number: str) -> Optional[Dict[str, str]]:
        """
        Get user credentials by phone number
        
        Returns:
            Dict with 'username' and 'token' or None if not found
        """
        # Check cache first
        if phone_number in self.user_mapping:
            return self.user_mapping[phone_number]
        
        # Query WhatsAppUser model via API
        try:
            response = requests.get(
                f"{self.base_url}/auth/whatsapp-user/{phone_number}/",
                timeout=5
            )
            
            if response.status_code == 200:
                data = response.json()
                user_creds = {
                    'username': data['username'],
                    'token': data['token']
                }
                # Cache it
                self.user_mapping[phone_number] = user_creds
                return user_creds
            else:
                logger.warning(f"User not found for phone: {phone_number}")
                return None
                
        except Exception as e:
            logger.error(f"Error querying user by phone: {str(e)}")
            return None
    
    def register_phone_mapping(self, phone_number: str, username: str, password: str) -> bool:
        """
        Register phone number mapping to user account
        This should be called by admin or user to link WA number to account
        
        Args:
            phone_number: WhatsApp number (e.g., 628123456789)
            username: ManKu username
            password: User password
        
        Returns:
            bool: Success status
        """
        try:
            # Login to get token
            response = requests.post(
                f"{self.base_url}/auth/login/",
                json={
                    'username': username,
                    'password': password
                },
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                token = data.get('access')
                
                if token:
                    # Store in cache
                    self.user_mapping[phone_number] = {
                        'username': username,
                        'token': token
                    }
                    
                    # TODO: Save to database (WhatsAppUser model)
                    logger.info(f"✅ Registered phone mapping: {phone_number} -> {username}")
                    return True
            
            logger.error(f"Failed to login for phone mapping: {response.status_code}")
            return False
            
        except Exception as e:
            logger.error(f"Error registering phone mapping: {str(e)}")
            return False
    
    def get_dashboard_data(self, user_creds: Dict[str, str]) -> Dict[str, Any]:
        """Get dashboard summary data"""
        try:
            headers = self._get_auth_headers(user_creds['token'])
            response = requests.get(
                f"{self.base_url}/finance/dashboard/",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                return {'success': True, 'data': response.json()}
            else:
                return {'success': False, 'error': f"HTTP {response.status_code}"}
                
        except Exception as e:
            logger.error(f"Error getting dashboard data: {str(e)}")
            return {'success': False, 'error': str(e)}
    
    def get_report_data(self, user_creds: Dict[str, str]) -> Dict[str, Any]:
        """Get monthly report data"""
        try:
            headers = self._get_auth_headers(user_creds['token'])
            response = requests.get(
                f"{self.base_url}/finance/report/",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                return {'success': True, 'data': response.json()}
            else:
                return {'success': False, 'error': f"HTTP {response.status_code}"}
                
        except Exception as e:
            logger.error(f"Error getting report data: {str(e)}")
            return {'success': False, 'error': str(e)}
    
    def get_investment_portfolio(self, user_creds: Dict[str, str]) -> Dict[str, Any]:
        """Get investment portfolio summary"""
        try:
            headers = self._get_auth_headers(user_creds['token'])
            response = requests.get(
                f"{self.base_url}/finance/investments/portfolio-summary/",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                return {'success': True, 'data': response.json()}
            else:
                return {'success': False, 'error': f"HTTP {response.status_code}"}
                
        except Exception as e:
            logger.error(f"Error getting investment data: {str(e)}")
            return {'success': False, 'error': str(e)}
    
    def save_transaction(self, user_creds: Dict[str, str], transaction_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Save transaction to backend
        
        Args:
            user_creds: User credentials with token
            transaction_data: Transaction data with amount, description, type, category_hint
        
        Returns:
            Dict with success status and data/error
        """
        try:
            headers = self._get_auth_headers(user_creds['token'])
            
            # Add date and time (current)
            now = datetime.now()
            transaction_data['date'] = now.strftime('%Y-%m-%d')
            transaction_data['time'] = now.strftime('%H:%M')
            
            response = requests.post(
                f"{self.base_url}/finance/transactions/save-transaction/",
                headers=headers,
                json=transaction_data,
                timeout=10
            )
            
            if response.status_code in [200, 201]:
                data = response.json()
                return {
                    'success': True,
                    'data': {
                        'amount': transaction_data['amount'],
                        'description': transaction_data.get('description', ''),
                        'type': transaction_data.get('type', 'expense'),
                        'category': transaction_data.get('category_hint', 'Lainnya'),
                        'date': transaction_data['date']
                    }
                }
            else:
                error_msg = response.json().get('error', f"HTTP {response.status_code}")
                return {'success': False, 'error': error_msg}
                
        except Exception as e:
            logger.error(f"Error saving transaction: {str(e)}")
            return {'success': False, 'error': str(e)}
    
    def _get_auth_headers(self, token: str) -> Dict[str, str]:
        """Get authorization headers"""
        return {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
