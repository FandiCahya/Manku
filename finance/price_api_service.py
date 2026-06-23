"""
Service untuk mengambil harga real-time dari berbagai API
- Crypto: dari CoinGecko API (gratis, IDR)
- Saham Indonesia (IDX): Yahoo Finance SYMBOL.JK (IDR)
- Saham Global (NYSE/NASDAQ): Yahoo Finance SYMBOL + konversi USD→IDR
"""
import requests
import time
from decimal import Decimal
from django.core.cache import cache
from django.utils import timezone


# Header umum agar tidak diblokir
_HEADERS = {
    'User-Agent': (
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Safari/537.36'
    ),
    'Accept': 'application/json',
}


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
        'LTC': 'litecoin',
        'ATOM': 'cosmos',
        'UNI': 'uniswap',
        'XLM': 'stellar',
        'ALGO': 'algorand',
        'FIL': 'filecoin',
        'NEAR': 'near',
        'APT': 'aptos',
        'ARB': 'arbitrum',
        'OP': 'optimism',
        'SUI': 'sui',
        'TON': 'the-open-network',
    }

    @classmethod
    def get_crypto_price(cls, symbol):
        """
        Get harga crypto dari CoinGecko (dalam IDR)

        Returns:
            dict | None
        """
        cache_key = f"crypto_price_{symbol.upper()}"
        cached = cache.get(cache_key)
        if cached:
            return cached

        try:
            coin_id = cls.CRYPTO_ID_MAPPING.get(symbol.upper(), symbol.lower())

            url = f"{cls.COINGECKO_API_URL}/simple/price"
            params = {
                'ids': coin_id,
                'vs_currencies': 'idr',
                'include_24hr_change': 'true',
            }

            response = requests.get(url, params=params, headers=_HEADERS, timeout=10)
            response.raise_for_status()
            data = response.json()

            if coin_id not in data:
                print(f"CoinGecko: {coin_id} not found in response. Keys: {list(data.keys())}")
                return None

            coin_data = data[coin_id]
            idr_price = coin_data.get('idr')
            if not idr_price:
                print(f"CoinGecko: no IDR price for {coin_id}")
                return None

            result = {
                'symbol': symbol.upper(),
                'name': cls._get_crypto_name(symbol),
                'current_price': Decimal(str(idr_price)),
                'price_change_24h': Decimal(str(coin_data.get('idr_24h_change', 0))),
                'last_updated': timezone.now(),
                'currency': 'IDR',
            }

            cache.set(cache_key, result, 300)  # cache 5 menit
            print(f"CoinGecko OK: {symbol.upper()} = {idr_price} IDR")
            return result

        except requests.exceptions.HTTPError as e:
            if e.response is not None and e.response.status_code == 429:
                print(f"CoinGecko rate-limited for {symbol}. Will retry without cache next time.")
            else:
                print(f"CoinGecko HTTP error for {symbol}: {e}")
            return None
        except Exception as e:
            print(f"CoinGecko error for {symbol}: {e}")
            return None

    @classmethod
    def get_multiple_crypto_prices(cls, symbols):
        """
        Get harga multiple crypto sekaligus (lebih efisien, satu request)
        """
        results = {}

        coin_ids = []
        symbol_to_id = {}
        for symbol in symbols:
            coin_id = cls.CRYPTO_ID_MAPPING.get(symbol.upper(), symbol.lower())
            coin_ids.append(coin_id)
            symbol_to_id[coin_id] = symbol.upper()

        try:
            url = f"{cls.COINGECKO_API_URL}/simple/price"
            params = {
                'ids': ','.join(coin_ids),
                'vs_currencies': 'idr',
                'include_24hr_change': 'true',
            }

            response = requests.get(url, params=params, headers=_HEADERS, timeout=10)
            response.raise_for_status()
            data = response.json()

            for coin_id, coin_data in data.items():
                symbol = symbol_to_id.get(coin_id)
                if symbol:
                    idr_price = coin_data.get('idr')
                    if idr_price:
                        results[symbol] = {
                            'symbol': symbol,
                            'name': cls._get_crypto_name(symbol),
                            'current_price': Decimal(str(idr_price)),
                            'price_change_24h': Decimal(str(coin_data.get('idr_24h_change', 0))),
                            'last_updated': timezone.now(),
                            'currency': 'IDR',
                        }
                        print(f"CoinGecko batch OK: {symbol} = {idr_price} IDR")

            return results

        except requests.exceptions.HTTPError as e:
            if e.response is not None and e.response.status_code == 429:
                print("CoinGecko rate-limited on batch request. Trying one-by-one...")
                # Fallback: ambil satu-satu dengan jeda
                for symbol in symbols:
                    result = cls.get_crypto_price(symbol)
                    if result:
                        results[symbol.upper()] = result
                    time.sleep(0.5)  # jeda 0.5 detik antar request
                return results
            print(f"CoinGecko batch HTTP error: {e}")
            return {}
        except Exception as e:
            print(f"CoinGecko batch error: {e}")
            return {}

    # ══════════════════════════════════════════════════════════════════════════
    # STOCK PRICE API (IDX Indonesia + Global NYSE/NASDAQ)
    # ══════════════════════════════════════════════════════════════════════════

    # Simbol saham global yang diketahui (tidak pakai suffix .JK)
    KNOWN_GLOBAL_STOCKS = {
        # US Tech
        'AAPL', 'MSFT', 'GOOGL', 'GOOG', 'AMZN', 'META', 'NVDA', 'TSLA',
        'NFLX', 'ADBE', 'CRM', 'ORCL', 'IBM', 'INTC', 'AMD', 'QCOM',
        'AVGO', 'TXN', 'MU', 'AMAT', 'LRCX',
        # US Finance
        'JPM', 'BAC', 'WFC', 'GS', 'MS', 'C', 'AXP', 'V', 'MA', 'PYPL',
        'BRKB', 'BRKA',
        # US Consumer
        'AMZN', 'WMT', 'COST', 'HD', 'NKE', 'MCD', 'SBUX', 'DIS',
        'NFLX', 'CMCSA',
        # US Healthcare
        'JNJ', 'PFE', 'MRK', 'ABBV', 'LLY', 'UNH', 'CVS',
        # Other Global
        'TSM', 'BABA', 'TCEHY', 'UBER', 'LYFT', 'SNAP', 'TWTR',
        'SPOT', 'HOOD', 'COIN',
        # SGX Singapore
        'D05', 'O39', 'U11',
    }

    @classmethod
    def get_usd_to_idr_rate(cls):
        """Fetch kurs USD/IDR real-time dari Yahoo Finance"""
        cache_key = "usd_idr_rate"
        cached = cache.get(cache_key)
        if cached:
            return cached

        try:
            url = "https://query1.finance.yahoo.com/v8/finance/chart/USDIDR=X"
            params = {'interval': '1d', 'range': '1d'}
            response = requests.get(url, params=params, headers=_HEADERS, timeout=8)
            response.raise_for_status()
            data = response.json()
            result_list = data.get('chart', {}).get('result')
            if result_list:
                rate = result_list[0].get('meta', {}).get('regularMarketPrice', 16000)
                cache.set(cache_key, rate, 3600)  # cache 1 jam
                print(f"USD/IDR rate: {rate}")
                return rate
        except Exception as e:
            print(f"USD/IDR fetch error: {e}")

        return 16000  # fallback kurs default

    @classmethod
    def get_stock_price(cls, symbol):
        """
        Get harga saham — auto-detect IDX vs Global

        - IDX:    fetch SYMBOL.JK (harga dalam IDR)
        - Global: fetch SYMBOL (harga dalam USD, konversi ke IDR)
        """
        cache_key = f"stock_price_{symbol.upper()}"
        cached = cache.get(cache_key)
        if cached:
            return cached

        try:
            result = cls._get_stock_price_yahoo(symbol)
            if result:
                cache_timeout = 300 if cls._is_market_hours() else 3600
                cache.set(cache_key, result, cache_timeout)
                return result
            return None

        except Exception as e:
            print(f"get_stock_price error for {symbol}: {e}")
            return None

    @classmethod
    def _get_stock_price_yahoo(cls, symbol):
        """
        Fetch dari Yahoo Finance.
        - Coba SYMBOL.JK dulu (IDX Indonesia)
        - Kalau gagal, coba SYMBOL langsung (global/US stocks)
        """
        sym_upper = symbol.upper()

        # Tentukan apakah saham global atau IDX
        is_global = sym_upper in cls.KNOWN_GLOBAL_STOCKS

        if is_global:
            # Langsung coba global
            candidates = [sym_upper]
        else:
            # Coba IDX dulu, fallback ke global
            candidates = [f"{sym_upper}.JK", sym_upper]

        for yahoo_symbol in candidates:
            result = cls._fetch_yahoo(yahoo_symbol, symbol)
            if result:
                return result

        print(f"Yahoo Finance: semua kandidat gagal untuk {sym_upper}")
        return None

    @classmethod
    def _fetch_yahoo(cls, yahoo_symbol, original_symbol):
        """Helper: fetch satu symbol dari Yahoo Finance"""
        is_idr = yahoo_symbol.endswith('.JK')

        urls = [
            f"https://query1.finance.yahoo.com/v8/finance/chart/{yahoo_symbol}",
            f"https://query2.finance.yahoo.com/v8/finance/chart/{yahoo_symbol}",
        ]
        params = {'interval': '1d', 'range': '1d'}

        for url in urls:
            try:
                response = requests.get(url, params=params, headers=_HEADERS, timeout=10)
                response.raise_for_status()
                data = response.json()

                chart = data.get('chart', {})
                result_list = chart.get('result')

                if not result_list:
                    error_desc = (chart.get('error') or {}).get('description', 'No data')
                    print(f"Yahoo Finance: no result for {yahoo_symbol} — {error_desc}")
                    continue

                meta = result_list[0].get('meta', {})
                current_price = meta.get('regularMarketPrice') or meta.get('chartPreviousClose')

                if not current_price:
                    print(f"Yahoo Finance: no price in meta for {yahoo_symbol}")
                    continue

                previous_close = (
                    meta.get('previousClose')
                    or meta.get('chartPreviousClose')
                    or current_price
                )

                # Konversi USD → IDR kalau bukan saham IDX
                if is_idr:
                    price_idr = current_price
                    prev_idr = previous_close
                else:
                    usd_rate = cls.get_usd_to_idr_rate()
                    price_idr = current_price * usd_rate
                    prev_idr = previous_close * usd_rate

                # Hitung % perubahan
                if prev_idr and prev_idr > 0:
                    price_change_pct = ((price_idr - prev_idr) / prev_idr) * 100
                else:
                    price_change_pct = 0

                print(
                    f"Yahoo Finance OK: {yahoo_symbol} = "
                    f"{'IDR' if is_idr else 'USD→IDR'} {price_idr:.2f}"
                )

                return {
                    'symbol': original_symbol.upper(),
                    'name': cls._get_stock_name(original_symbol),
                    'current_price': Decimal(str(round(price_idr, 2))),
                    'price_change_24h': Decimal(str(round(price_change_pct, 2))),
                    'last_updated': timezone.now(),
                    'currency': 'IDR',
                    'market': 'IDX' if is_idr else 'GLOBAL',
                }

            except Exception as e:
                print(f"Yahoo Finance error for {yahoo_symbol} from {url}: {e}")
                continue

        return None

    @classmethod
    def get_multiple_stock_prices(cls, symbols):
        """Get harga multiple saham"""
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
            'BTC': 'Bitcoin', 'ETH': 'Ethereum', 'BNB': 'Binance Coin',
            'USDT': 'Tether', 'USDC': 'USD Coin', 'XRP': 'Ripple',
            'ADA': 'Cardano', 'DOGE': 'Dogecoin', 'SOL': 'Solana',
            'DOT': 'Polkadot', 'MATIC': 'Polygon', 'SHIB': 'Shiba Inu',
            'AVAX': 'Avalanche', 'TRX': 'Tron', 'LINK': 'Chainlink',
            'LTC': 'Litecoin', 'ATOM': 'Cosmos', 'UNI': 'Uniswap',
            'XLM': 'Stellar', 'ALGO': 'Algorand', 'FIL': 'Filecoin',
            'NEAR': 'NEAR Protocol', 'APT': 'Aptos', 'ARB': 'Arbitrum',
            'OP': 'Optimism', 'SUI': 'Sui', 'TON': 'Toncoin',
        }
        return names.get(symbol.upper(), symbol.upper())

    @staticmethod
    def _get_stock_name(symbol):
        """Get full name untuk saham"""
        names = {
            # Saham Indonesia (IDX)
            'BBCA': 'Bank BCA', 'BBRI': 'Bank BRI', 'BMRI': 'Bank Mandiri',
            'BBNI': 'Bank BNI', 'BBTN': 'Bank BTN', 'TLKM': 'Telkom Indonesia',
            'ISAT': 'Indosat Ooredoo', 'EXCL': 'XL Axiata',
            'ANTM': 'Aneka Tambang', 'PGAS': 'Perusahaan Gas Negara',
            'ADRO': 'Adaro Energy', 'PTBA': 'Bukit Asam',
            'BUMI': 'Bumi Resources', 'ITMG': 'Indo Tambangraya Megah',
            'HRUM': 'Harum Energy', 'INCO': 'Vale Indonesia',
            'TINS': 'Timah', 'MDKA': 'Merdeka Copper Gold',
            'ICBP': 'Indofood CBP', 'INDF': 'Indofood Sukses Makmur',
            'GGRM': 'Gudang Garam', 'HMSP': 'HM Sampoerna',
            'KLBF': 'Kalbe Farma', 'SIDO': 'Industri Jamu Sido Muncul',
            'UNVR': 'Unilever Indonesia', 'ASII': 'Astra International',
            'UNTR': 'United Tractors', 'SMGR': 'Semen Indonesia',
            'INTP': 'Indocement', 'INKP': 'Indah Kiat Pulp',
            'BJBR': 'Bank BJB', 'BRIS': 'Bank BRI Syariah',
            'GOTO': 'GoTo Gojek Tokopedia', 'BREN': 'Barito Renewables',
            'AMMN': 'Amman Mineral', 'EMTK': 'Elang Mahkota Teknologi',
            # Saham Global
            'AAPL': 'Apple Inc.', 'MSFT': 'Microsoft Corp.',
            'GOOGL': 'Alphabet Inc.', 'GOOG': 'Alphabet Inc.',
            'AMZN': 'Amazon.com Inc.', 'META': 'Meta Platforms',
            'NVDA': 'NVIDIA Corp.', 'TSLA': 'Tesla Inc.',
            'NFLX': 'Netflix Inc.', 'BABA': 'Alibaba Group',
            'TSM': 'Taiwan Semiconductor', 'BRKB': 'Berkshire Hathaway',
            'JPM': 'JPMorgan Chase', 'BAC': 'Bank of America',
            'DIS': 'Walt Disney', 'PYPL': 'PayPal Holdings',
            'UBER': 'Uber Technologies', 'COIN': 'Coinbase Global',
            'AMD': 'Advanced Micro Devices', 'INTC': 'Intel Corp.',
            'QCOM': 'Qualcomm Inc.', 'CRM': 'Salesforce Inc.',
        }
        return names.get(symbol.upper(), symbol.upper())

    @staticmethod
    def _is_market_hours():
        """Cek apakah sekarang jam trading IDX (09:00-16:00 WIB, Mon-Fri)"""
        now = timezone.localtime()
        if now.weekday() >= 5:
            return False
        if now.hour < 9 or now.hour >= 16:
            return False
        return True

    @classmethod
    def search_crypto(cls, query):
        """Search crypto by name atau symbol dari CoinGecko"""
        try:
            url = f"{cls.COINGECKO_API_URL}/search"
            response = requests.get(
                url, params={'query': query}, headers=_HEADERS, timeout=10
            )
            response.raise_for_status()
            coins = response.json().get('coins', [])[:10]
            return [
                {'id': c['id'], 'symbol': c['symbol'].upper(), 'name': c['name']}
                for c in coins
            ]
        except Exception as e:
            print(f"CoinGecko search error: {e}")
            return []
