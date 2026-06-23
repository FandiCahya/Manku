"""
Service untuk mengambil harga real-time dari berbagai API
- Saham Indonesia: dari API IDX atau alternatif
- Crypto: dari CoinGecko API (gratis)
"""
import requests
from decimal import Decimal
from django.core.cache import cache
from django.utils import timezone


class PriceAPIService:
    """Service untuk fetch harga real-time"""
    
    # ══════════════════════════════════════════════════════════════════════════
    # CRYPTO PRICE API (CoinGecko - Free, No API Key Required)
    # ══════════════════════════════════════════════════════════════════════════
    
    COINGECKO_API_URL = "https://api.coingecko.com/api/v3"
    
    # Mapping common crypto symbols ke CoinGecko ID
    CRYPTO_ID_MAPPING = {
        'BTC': 'bitcoin',
        'ETH': 'ethereum',
        'BNB': 'binancecoin',
        'USDT': 'tether',
        'USDC': 'usd-coin',
        'XRP': 'ripple',
        'ADA': 'cardano',
        'DOGE': 'dogecoin',
        'SOL': 'solana',
        'DOT': 'polkadot',
        'MATIC': 'matic-network',
        'SHIB': 'shiba-inu',
        'AVAX': 'avalanche-2',
        'TRX': 'tron',
        'LINK': 'chainlink',
    }
    
    @classmethod
    def get_crypto_price(cls, symbol):
        """
        Get harga crypto dari CoinGecko
        
        Args:
            symbol (str): Crypto symbol (e.g., 'BTC', 'ETH')
        
        Returns:
            dict: {
                'symbol': 'BTC',
                'name': 'Bitcoin',
                'current_price': 700000000,  # dalam IDR
                'price_change_24h': 2.5,  # persentase
                'last_updated': datetime
            }
        """
        # Cek cache dulu (5 menit)
        cache_key = f"crypto_price_{symbol}"
        cached = cache.get(cache_key)
        if cached:
            return cached
        
        try:
            # Convert symbol ke CoinGecko ID
            coin_id = cls.CRYPTO_ID_MAPPING.get(symbol.upper())
            if not coin_id:
                # Jika tidak ada di mapping, coba lowercase symbol
                coin_id = symbol.lower()
            
            # Call CoinGecko API
            url = f"{cls.COINGECKO_API_URL}/simple/price"
            params = {
                'ids': coin_id,
                'vs_currencies': 'idr',  # Harga dalam IDR
                'include_24hr_change': 'true',
            }
            
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            
            if coin_id not in data:
                return None
            
            coin_data = data[coin_id]
            
            result = {
                'symbol': symbol.upper(),
                'name': cls._get_crypto_name(symbol),
                'current_price': Decimal(str(coin_data['idr'])),
                'price_change_24h': Decimal(str(coin_data.get('idr_24h_change', 0))),
                'last_updated': timezone.now(),
            }
            
            # Cache untuk 5 menit
            cache.set(cache_key, result, 300)
            
            return result
            
        except Exception as e:
            print(f"Error fetching crypto price for {symbol}: {str(e)}")
            return None
    
    @classmethod
    def get_multiple_crypto_prices(cls, symbols):
        """
        Get harga multiple crypto sekaligus (lebih efisien)
        
        Args:
            symbols (list): List of crypto symbols ['BTC', 'ETH', 'DOGE']
        
        Returns:
            dict: {
                'BTC': {...},
                'ETH': {...},
            }
        """
        results = {}
        
        # Convert symbols ke CoinGecko IDs
        coin_ids = []
        symbol_to_id = {}
        for symbol in symbols:
            coin_id = cls.CRYPTO_ID_MAPPING.get(symbol.upper(), symbol.lower())
            coin_ids.append(coin_id)
            symbol_to_id[coin_id] = symbol.upper()
        
        try:
            # Call CoinGecko API
            url = f"{cls.COINGECKO_API_URL}/simple/price"
            params = {
                'ids': ','.join(coin_ids),
                'vs_currencies': 'idr',
                'include_24hr_change': 'true',
            }
            
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            
            for coin_id, coin_data in data.items():
                symbol = symbol_to_id.get(coin_id)
                if symbol:
                    results[symbol] = {
                        'symbol': symbol,
                        'name': cls._get_crypto_name(symbol),
                        'current_price': Decimal(str(coin_data['idr'])),
                        'price_change_24h': Decimal(str(coin_data.get('idr_24h_change', 0))),
                        'last_updated': timezone.now(),
                    }
            
            return results
            
        except Exception as e:
            print(f"Error fetching multiple crypto prices: {str(e)}")
            return {}
    
    # ══════════════════════════════════════════════════════════════════════════
    # STOCK PRICE API (Indonesia)
    # ══════════════════════════════════════════════════════════════════════════
    
    @classmethod
    def get_stock_price(cls, symbol):
        """
        Get harga saham Indonesia
        
        Menggunakan beberapa sumber:
        1. Yahoo Finance API (untuk saham IDX)
        2. Alternatif: RapidAPI Indonesian Stock
        
        Args:
            symbol (str): Stock ticker (e.g., 'BBCA', 'TLKM')
        
        Returns:
            dict: {
                'symbol': 'BBCA',
                'name': 'Bank BCA',
                'current_price': 9000,
                'price_change_24h': 1.5,
                'last_updated': datetime
            }
        """
        # Cek cache dulu
        cache_key = f"stock_price_{symbol}"
        cached = cache.get(cache_key)
        if cached:
            return cached
        
        try:
            # Method 1: Yahoo Finance (gratis)
            result = cls._get_stock_price_yahoo(symbol)
            
            if result:
                # Cache untuk 5 menit (market hours) atau 1 jam (after hours)
                cache_timeout = 300 if cls._is_market_hours() else 3600
                cache.set(cache_key, result, cache_timeout)
                return result
            
            return None
            
        except Exception as e:
            print(f"Error fetching stock price for {symbol}: {str(e)}")
            return None
    
    @classmethod
    def _get_stock_price_yahoo(cls, symbol):
        """Get stock price dari Yahoo Finance"""
        # Yahoo Finance format untuk IDX: SYMBOL.JK
        yahoo_symbol = f"{symbol.upper()}.JK"
        
        # Header agar tidak diblokir Yahoo Finance
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'application/json',
        }
        
        # Coba dari query1 dan query2 sebagai fallback
        urls = [
            f"https://query1.finance.yahoo.com/v8/finance/chart/{yahoo_symbol}",
            f"https://query2.finance.yahoo.com/v8/finance/chart/{yahoo_symbol}",
        ]
        
        params = {
            'interval': '1d',
            'range': '1d',
        }
        
        for url in urls:
            try:
                response = requests.get(url, params=params, headers=headers, timeout=10)
                response.raise_for_status()
                
                data = response.json()
                
                # Validasi struktur response
                chart = data.get('chart', {})
                result_list = chart.get('result')
                
                if not result_list or len(result_list) == 0:
                    error_msg = chart.get('error', {}).get('description', 'No data')
                    print(f"Yahoo Finance: no result for {yahoo_symbol} - {error_msg}")
                    continue  # Coba URL berikutnya
                
                result = result_list[0]
                meta = result.get('meta', {})
                
                current_price = meta.get('regularMarketPrice') or meta.get('chartPreviousClose')
                
                if not current_price:
                    print(f"Yahoo Finance: current_price not found in meta for {yahoo_symbol}")
                    continue
                
                previous_close = meta.get('previousClose') or meta.get('chartPreviousClose') or current_price
                
                # Hitung perubahan persentase
                if previous_close and previous_close > 0:
                    price_change = ((current_price - previous_close) / previous_close) * 100
                else:
                    price_change = 0
                
                print(f"Yahoo Finance OK: {yahoo_symbol} = {current_price} IDR")
                
                return {
                    'symbol': symbol.upper(),
                    'name': cls._get_stock_name(symbol),
                    'current_price': Decimal(str(current_price)),
                    'price_change_24h': Decimal(str(round(price_change, 2))),
                    'last_updated': timezone.now(),
                }
                
            except Exception as e:
                print(f"Yahoo Finance error for {yahoo_symbol} from {url}: {str(e)}")
                continue  # Coba URL berikutnya
        
        print(f"Yahoo Finance: semua URL gagal untuk {yahoo_symbol}")
        return None
    
    @classmethod
    def get_multiple_stock_prices(cls, symbols):
        """Get harga multiple saham sekaligus"""
        results = {}
        
        for symbol in symbols:
            price_data = cls.get_stock_price(symbol)
            if price_data:
                results[symbol.upper()] = price_data
        
        return results
    
    # ══════════════════════════════════════════════════════════════════════════
    # HELPER METHODS
    # ══════════════════════════════════════════════════════════════════════════
    
    @staticmethod
    def _get_crypto_name(symbol):
        """Get full name untuk crypto"""
        names = {
            'BTC': 'Bitcoin',
            'ETH': 'Ethereum',
            'BNB': 'Binance Coin',
            'USDT': 'Tether',
            'USDC': 'USD Coin',
            'XRP': 'Ripple',
            'ADA': 'Cardano',
            'DOGE': 'Dogecoin',
            'SOL': 'Solana',
            'DOT': 'Polkadot',
            'MATIC': 'Polygon',
            'SHIB': 'Shiba Inu',
            'AVAX': 'Avalanche',
            'TRX': 'Tron',
            'LINK': 'Chainlink',
        }
        return names.get(symbol.upper(), symbol.upper())
    
    @staticmethod
    def _get_stock_name(symbol):
        """Get full name untuk saham Indonesia"""
        names = {
            # Bank
            'BBCA': 'Bank BCA',
            'BBRI': 'Bank BRI',
            'BMRI': 'Bank Mandiri',
            'BBNI': 'Bank BNI',
            'BBTN': 'Bank BTN',
            # Telco
            'TLKM': 'Telkom Indonesia',
            'ISAT': 'Indosat Ooredoo',
            'EXCL': 'XL Axiata',
            # Energi & Tambang
            'ANTM': 'Aneka Tambang',
            'PGAS': 'Perusahaan Gas Negara',
            'ADRO': 'Adaro Energy',
            'PTBA': 'Bukit Asam',
            'BUMI': 'Bumi Resources',
            'ITMG': 'Indo Tambangraya Megah',
            'HRUM': 'Harum Energy',
            'INCO': 'Vale Indonesia',
            'TINS': 'Timah',
            'MDKA': 'Merdeka Copper Gold',
            # Consumer
            'ICBP': 'Indofood CBP',
            'INDF': 'Indofood Sukses Makmur',
            'GGRM': 'Gudang Garam',
            'HMSP': 'HM Sampoerna',
            'KLBF': 'Kalbe Farma',
            'SIDO': 'Industri Jamu Sido Muncul',
            'UNVR': 'Unilever Indonesia',
            # Otomotif & Industri
            'ASII': 'Astra International',
            'UNTR': 'United Tractors',
            # Properti & Konstruksi
            'SMGR': 'Semen Indonesia',
            'INTP': 'Indocement',
            'INKP': 'Indah Kiat Pulp',
            # Keuangan
            'BJBR': 'Bank BJB',
            'BRIS': 'Bank BRI Syariah',
        }
        return names.get(symbol.upper(), symbol.upper())
    
    @staticmethod
    def _is_market_hours():
        """Cek apakah sekarang jam trading IDX (09:00-16:00 WIB, Mon-Fri)"""
        from django.utils import timezone
        now = timezone.localtime()
        
        # Weekend?
        if now.weekday() >= 5:  # Saturday=5, Sunday=6
            return False
        
        # Trading hours: 09:00 - 16:00
        if now.hour < 9 or now.hour >= 16:
            return False
        
        return True
    
    @classmethod
    def search_crypto(cls, query):
        """
        Search crypto by name atau symbol
        
        Returns:
            list: [
                {'id': 'bitcoin', 'symbol': 'BTC', 'name': 'Bitcoin'},
                ...
            ]
        """
        try:
            url = f"{cls.COINGECKO_API_URL}/search"
            params = {'query': query}
            
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            coins = data.get('coins', [])[:10]  # Top 10 results
            
            return [
                {
                    'id': coin['id'],
                    'symbol': coin['symbol'].upper(),
                    'name': coin['name'],
                }
                for coin in coins
            ]
            
        except Exception as e:
            print(f"Error searching crypto: {str(e)}")
            return []
