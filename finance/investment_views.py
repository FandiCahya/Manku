"""
Views untuk Investment Portfolio API
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Sum, F, DecimalField
from django.db.models.functions import Coalesce
from decimal import Decimal

from .models import Investment, InvestmentTransaction, PriceCache
from .investment_serializers import (
    InvestmentSerializer,
    InvestmentCreateSerializer,
    InvestmentTransactionSerializer,
    PriceCacheSerializer,
)
from .price_api_service import PriceAPIService


class InvestmentViewSet(viewsets.ModelViewSet):
    """
    ViewSet untuk Investment Portfolio
    """
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Investment.objects.filter(user=self.request.user)
    
    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return InvestmentCreateSerializer
        return InvestmentSerializer
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    def list(self, request, *args, **kwargs):
        """
        GET /api/investments/
        List semua investasi dengan harga real-time
        """
        queryset = self.get_queryset()
        
        # Fetch real-time prices
        prices = self._fetch_all_prices(queryset)
        
        # Serialize dengan prices di context
        serializer = self.get_serializer(
            queryset, 
            many=True,
            context={'prices': prices, 'request': request}
        )
        
        return Response(serializer.data)
    
    def retrieve(self, request, *args, **kwargs):
        """
        GET /api/investments/{id}/
        Detail investasi dengan harga real-time
        """
        instance = self.get_object()
        
        # Fetch price untuk symbol ini
        if instance.asset_type == 'crypto':
            price_data = PriceAPIService.get_crypto_price(instance.symbol)
        else:
            price_data = PriceAPIService.get_stock_price(instance.symbol)
        
        prices = {instance.symbol: price_data} if price_data else {}
        
        serializer = self.get_serializer(
            instance,
            context={'prices': prices, 'request': request}
        )
        
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'], url_path='portfolio-summary')
    def portfolio_summary(self, request):
        """
        GET /api/investments/portfolio-summary/
        Summary portfolio dengan total value, profit/loss, dll
        """
        investments = self.get_queryset()
        
        if not investments.exists():
            return Response({
                'total_investment': 0,
                'current_value': 0,
                'total_profit_loss': 0,
                'profit_loss_percentage': 0,
                'total_assets': 0,
                'by_type': {
                    'crypto': {
                        'total_investment': 0,
                        'current_value': 0,
                        'profit_loss': 0,
                        'count': 0,
                    },
                    'stock': {
                        'total_investment': 0,
                        'current_value': 0,
                        'profit_loss': 0,
                        'count': 0,
                    }
                }
            })
        
        # Fetch all prices
        prices = self._fetch_all_prices(investments)
        
        # Calculate totals
        total_investment = Decimal('0')
        current_value = Decimal('0')
        
        crypto_investment = Decimal('0')
        crypto_value = Decimal('0')
        crypto_count = 0
        
        stock_investment = Decimal('0')
        stock_value = Decimal('0')
        stock_count = 0
        
        for inv in investments:
            inv_cost = inv.total_cost
            total_investment += inv_cost
            
            # Get current price
            price_data = prices.get(inv.symbol, {})
            current_price = price_data.get('current_price', 0)
            
            if current_price:
                inv_value = Decimal(str(inv.calculate_current_value(current_price)))
            else:
                inv_value = inv_cost
            
            current_value += inv_value
            
            # By type
            if inv.asset_type == 'crypto':
                crypto_investment += inv_cost
                crypto_value += inv_value
                crypto_count += 1
            else:
                stock_investment += inv_cost
                stock_value += inv_value
                stock_count += 1
        
        total_profit_loss = current_value - total_investment
        
        if total_investment > 0:
            profit_loss_pct = float((total_profit_loss / total_investment) * 100)
        else:
            profit_loss_pct = 0
        
        return Response({
            'total_investment': float(total_investment),
            'current_value': float(current_value),
            'total_profit_loss': float(total_profit_loss),
            'profit_loss_percentage': round(profit_loss_pct, 2),
            'total_assets': investments.count(),
            'by_type': {
                'crypto': {
                    'total_investment': float(crypto_investment),
                    'current_value': float(crypto_value),
                    'profit_loss': float(crypto_value - crypto_investment),
                    'count': crypto_count,
                },
                'stock': {
                    'total_investment': float(stock_investment),
                    'current_value': float(stock_value),
                    'profit_loss': float(stock_value - stock_investment),
                    'count': stock_count,
                }
            }
        })
    
    @action(detail=True, methods=['post'], url_path='add-transaction')
    def add_transaction(self, request, pk=None):
        """
        POST /api/investments/{id}/add-transaction/
        Tambah transaksi buy/sell
        
        Body: {
            "transaction_type": "buy",
            "quantity": 0.5,
            "price": 700000000,
            "transaction_date": "2026-06-12T10:00:00Z",
            "notes": "Beli BTC"
        }
        """
        investment = self.get_object()
        
        serializer = InvestmentTransactionSerializer(data=request.data)
        if serializer.is_valid():
            transaction = serializer.save(investment=investment)
            
            # Update investment quantity & average buy price
            if transaction.transaction_type == 'buy':
                # Recalculate average buy price
                old_total_cost = investment.total_cost
                old_quantity = investment.quantity
                
                new_quantity = old_quantity + transaction.quantity
                new_total_cost = old_total_cost + transaction.total_amount
                new_avg_price = new_total_cost / new_quantity
                
                investment.quantity = new_quantity
                investment.buy_price = new_avg_price
                investment.save()
                
            elif transaction.transaction_type == 'sell':
                # Reduce quantity
                investment.quantity -= transaction.quantity
                if investment.quantity < 0:
                    investment.quantity = Decimal('0')
                investment.save()
            
            return Response({
                'message': 'Transaksi berhasil ditambahkan',
                'transaction': serializer.data,
            }, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['get'], url_path='transactions')
    def transactions(self, request, pk=None):
        """
        GET /api/investments/{id}/transactions/
        List transaksi untuk investasi ini
        """
        investment = self.get_object()
        transactions = investment.transactions.all()
        
        serializer = InvestmentTransactionSerializer(transactions, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'], url_path='search-crypto')
    def search_crypto(self, request):
        """
        GET /api/investments/search-crypto/?q=bitcoin
        Search crypto by name
        """
        query = request.query_params.get('q', '')
        
        if not query:
            return Response(
                {'error': 'Query parameter "q" required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        results = PriceAPIService.search_crypto(query)
        return Response(results)
    
    @action(detail=False, methods=['get'], url_path='price')
    def get_price(self, request):
        """
        GET /api/investments/price/?symbol=BTC&type=crypto
        Get harga real-time untuk satu asset
        """
        symbol = request.query_params.get('symbol', '').upper()
        asset_type = request.query_params.get('type', 'crypto')
        
        if not symbol:
            return Response(
                {'error': 'Parameter "symbol" required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if asset_type == 'crypto':
            price_data = PriceAPIService.get_crypto_price(symbol)
        else:
            price_data = PriceAPIService.get_stock_price(symbol)
        
        if not price_data:
            return Response(
                {'error': f'Price not found for {symbol}'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        return Response(price_data)
    
    @action(detail=False, methods=['get'], url_path='refresh-prices')
    def refresh_prices(self, request):
        """
        GET /api/investments/refresh-prices/
        Force refresh semua prices (bypass cache)
        """
        from django.core.cache import cache
        
        investments = self.get_queryset()
        
        # Clear cache
        for inv in investments:
            cache_key = f"{'crypto' if inv.asset_type == 'crypto' else 'stock'}_price_{inv.symbol}"
            cache.delete(cache_key)
        
        # Fetch fresh prices
        prices = self._fetch_all_prices(investments, use_cache=False)
        
        return Response({
            'message': 'Prices refreshed successfully',
            'prices': prices,
        })
    
    def _fetch_all_prices(self, investments, use_cache=True):
        """
        Helper untuk fetch semua prices sekaligus
        """
        crypto_symbols = []
        stock_symbols = []
        
        for inv in investments:
            if inv.asset_type == 'crypto':
                crypto_symbols.append(inv.symbol)
            else:
                stock_symbols.append(inv.symbol)
        
        prices = {}
        
        # Fetch crypto prices (batch)
        if crypto_symbols:
            crypto_prices = PriceAPIService.get_multiple_crypto_prices(crypto_symbols)
            prices.update(crypto_prices)
        
        # Fetch stock prices
        if stock_symbols:
            stock_prices = PriceAPIService.get_multiple_stock_prices(stock_symbols)
            prices.update(stock_prices)
        
        return prices
