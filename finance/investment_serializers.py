"""
Serializers untuk Investment API
"""
from rest_framework import serializers
from .models import Investment, InvestmentTransaction, PriceCache


class InvestmentSerializer(serializers.ModelSerializer):
    """Serializer untuk Investment"""
    
    total_cost = serializers.DecimalField(
        max_digits=20, 
        decimal_places=2, 
        read_only=True
    )
    current_value = serializers.SerializerMethodField()
    profit_loss = serializers.SerializerMethodField()
    profit_loss_percentage = serializers.SerializerMethodField()
    current_price = serializers.SerializerMethodField()
    
    class Meta:
        model = Investment
        fields = [
            'id', 'asset_type', 'symbol', 'name',
            'quantity', 'buy_price', 'total_cost',
            'current_price', 'current_value',
            'profit_loss', 'profit_loss_percentage',
            'purchase_date', 'notes',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_current_price(self, obj):
        """Get current price dari context atau API"""
        # Price akan diinject dari view
        return self.context.get('prices', {}).get(obj.symbol, {}).get('current_price', 0)
    
    def get_current_value(self, obj):
        """Calculate current value"""
        current_price = self.get_current_price(obj)
        if current_price:
            return obj.calculate_current_value(current_price)
        return float(obj.total_cost)
    
    def get_profit_loss(self, obj):
        """Calculate profit/loss"""
        current_price = self.get_current_price(obj)
        if current_price:
            return obj.calculate_profit_loss(current_price)
        return 0
    
    def get_profit_loss_percentage(self, obj):
        """Calculate profit/loss percentage"""
        current_price = self.get_current_price(obj)
        if current_price:
            return round(obj.calculate_profit_loss_percentage(current_price), 2)
        return 0


class InvestmentCreateSerializer(serializers.ModelSerializer):
    """Serializer untuk create/update Investment"""
    
    class Meta:
        model = Investment
        fields = [
            'asset_type', 'symbol', 'name',
            'quantity', 'buy_price',
            'purchase_date', 'notes'
        ]
    
    def validate_symbol(self, value):
        """Validate and uppercase symbol"""
        return value.upper()
    
    def validate_quantity(self, value):
        """Validate quantity > 0"""
        if value <= 0:
            raise serializers.ValidationError("Quantity harus lebih dari 0")
        return value
    
    def validate_buy_price(self, value):
        """Validate buy_price > 0"""
        if value <= 0:
            raise serializers.ValidationError("Harga beli harus lebih dari 0")
        return value


class InvestmentTransactionSerializer(serializers.ModelSerializer):
    """Serializer untuk Investment Transaction"""
    
    investment_symbol = serializers.CharField(source='investment.symbol', read_only=True)
    investment_name = serializers.CharField(source='investment.name', read_only=True)
    
    class Meta:
        model = InvestmentTransaction
        fields = [
            'id', 'investment', 'investment_symbol', 'investment_name',
            'transaction_type', 'quantity', 'price', 'total_amount',
            'transaction_date', 'notes', 'created_at'
        ]
        read_only_fields = ['id', 'total_amount', 'created_at']


class PriceCacheSerializer(serializers.ModelSerializer):
    """Serializer untuk Price Cache"""
    
    class Meta:
        model = PriceCache
        fields = [
            'symbol', 'asset_type', 'current_price',
            'price_change_24h', 'last_updated', 'source'
        ]
