import uuid
from django.db import models
from django.contrib.auth.models import User


class Category(models.Model):
    TYPE_CHOICES = (
        ('income', 'Pemasukan'),
        ('expense', 'Pengeluaran'),
    )
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='categories')
    name = models.CharField(max_length=100)
    type = models.CharField(max_length=10, choices=TYPE_CHOICES)

    def __str__(self):
        return f"{self.name} ({self.get_type_display()})"


class Budget(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='budgets')
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='budgets')
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    month_year = models.DateField(help_text="Format: YYYY-MM-01")

    class Meta:
        unique_together = ('user', 'category', 'month_year')

    def __str__(self):
        return f"Budget {self.category.name}: {self.amount}"


class Transaction(models.Model):
    SOURCE_CHOICES = (
        ('manual', 'Manual Entry'),
        ('ai_image', 'AI Image Scanner'),
        ('ai_voice', 'AI Voice Logger'),
    )
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='transactions')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, related_name='transactions')
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    from django.utils import timezone
    transaction_date = models.DateTimeField(default=timezone.now)
    description = models.TextField(blank=True, null=True)
    input_source = models.CharField(max_length=20, choices=SOURCE_CHOICES, default='manual')
    is_synced = models.BooleanField(default=False, help_text="Status sync ke G-Sheets")

    def __str__(self):
        return f"{self.amount} - {self.category.name} ({self.transaction_date.strftime('%Y-%m-%d')})"


class SavingsGoal(models.Model):
    """
    Target tabungan yang ditetapkan user sendiri.
    current_amount = total uang yang sudah dialokasikan ke tabungan ini (diupdate manual).
    """
    COLOR_CHOICES = (
        ('#4A90D9', 'Blue'),
        ('#27AE60', 'Green'),
        ('#E67E22', 'Orange'),
        ('#9B59B6', 'Purple'),
        ('#E74C3C', 'Red'),
        ('#1ABC9C', 'Teal'),
        ('#F39C12', 'Yellow'),
        ('#2C3E50', 'Dark'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='savings_goals')
    name = models.CharField(max_length=100, help_text="Nama tabungan, misal: Dana Darurat")
    target_amount = models.DecimalField(max_digits=14, decimal_places=2)
    current_amount = models.DecimalField(max_digits=14, decimal_places=2, default=0)
    deadline = models.DateField(null=True, blank=True, help_text="Target tanggal selesai")
    description = models.TextField(blank=True, null=True)
    color = models.CharField(max_length=10, choices=COLOR_CHOICES, default='#4A90D9')
    icon = models.CharField(max_length=50, default='savings', help_text="Material icon name")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name}: {self.current_amount}/{self.target_amount}"

    @property
    def progress_percentage(self):
        if self.target_amount == 0:
            return 0.0
        return min(float(self.current_amount / self.target_amount), 1.0)

    @property
    def remaining_amount(self):
        return max(self.target_amount - self.current_amount, 0)

    @property
    def is_completed(self):
        return self.current_amount >= self.target_amount


# ══════════════════════════════════════════════════════════════════════════════
# INVESTMENT MODELS (Saham & Crypto)
# ══════════════════════════════════════════════════════════════════════════════

class Investment(models.Model):
    """
    Model untuk menyimpan investasi user (Saham & Crypto)
    """
    ASSET_TYPE_CHOICES = (
        ('stock', 'Saham'),
        ('crypto', 'Cryptocurrency'),
    )
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='investments')
    
    # Asset info
    asset_type = models.CharField(max_length=10, choices=ASSET_TYPE_CHOICES)
    symbol = models.CharField(max_length=20, help_text="Ticker symbol (e.g., BBCA, BTC)")
    name = models.CharField(max_length=100, help_text="Nama asset (e.g., Bank BCA, Bitcoin)")
    
    # Investment data
    quantity = models.DecimalField(
        max_digits=20, 
        decimal_places=8,
        help_text="Jumlah yang dimiliki (bisa desimal untuk crypto)"
    )
    buy_price = models.DecimalField(
        max_digits=20, 
        decimal_places=2,
        help_text="Harga beli rata-rata per unit"
    )
    
    # Metadata
    purchase_date = models.DateField(help_text="Tanggal pembelian pertama")
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
        unique_together = ('user', 'symbol', 'asset_type')
    
    def __str__(self):
        return f"{self.symbol} - {self.name} ({self.get_asset_type_display()})"
    
    @property
    def total_cost(self):
        """Total modal yang diinvestasikan"""
        return self.quantity * self.buy_price
    
    def calculate_current_value(self, current_price):
        """Hitung nilai saat ini"""
        return float(self.quantity) * float(current_price)
    
    def calculate_profit_loss(self, current_price):
        """Hitung untung/rugi"""
        current_value = self.calculate_current_value(current_price)
        return current_value - float(self.total_cost)
    
    def calculate_profit_loss_percentage(self, current_price):
        """Hitung persentase untung/rugi"""
        if float(self.total_cost) == 0:
            return 0
        profit_loss = self.calculate_profit_loss(current_price)
        return (profit_loss / float(self.total_cost)) * 100


class InvestmentTransaction(models.Model):
    """
    History transaksi investasi (buy/sell)
    """
    TRANSACTION_TYPE_CHOICES = (
        ('buy', 'Beli'),
        ('sell', 'Jual'),
    )
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    investment = models.ForeignKey(
        Investment, 
        on_delete=models.CASCADE, 
        related_name='transactions'
    )
    
    transaction_type = models.CharField(max_length=10, choices=TRANSACTION_TYPE_CHOICES)
    quantity = models.DecimalField(max_digits=20, decimal_places=8)
    price = models.DecimalField(max_digits=20, decimal_places=2, help_text="Harga per unit")
    total_amount = models.DecimalField(max_digits=20, decimal_places=2)
    
    transaction_date = models.DateTimeField()
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-transaction_date']
    
    def __str__(self):
        return f"{self.get_transaction_type_display()} {self.quantity} {self.investment.symbol}"
    
    def save(self, *args, **kwargs):
        # Auto-calculate total_amount
        self.total_amount = self.quantity * self.price
        super().save(*args, **kwargs)


class PriceCache(models.Model):
    """
    Cache untuk harga real-time agar tidak terlalu sering hit API
    """
    symbol = models.CharField(max_length=20, unique=True)
    asset_type = models.CharField(max_length=10)
    
    current_price = models.DecimalField(max_digits=20, decimal_places=2)
    price_change_24h = models.DecimalField(
        max_digits=10, 
        decimal_places=2, 
        null=True, 
        blank=True,
        help_text="Perubahan harga 24 jam (%)"
    )
    
    last_updated = models.DateTimeField(auto_now=True)
    source = models.CharField(max_length=50, default='api')
    
    class Meta:
        verbose_name_plural = "Price Caches"
    
    def __str__(self):
        return f"{self.symbol}: {self.current_price} (updated: {self.last_updated})"
    
    @property
    def is_stale(self):
        """Cek apakah cache sudah expired (> 5 menit)"""
        from django.utils import timezone
        from datetime import timedelta
        return timezone.now() - self.last_updated > timedelta(minutes=5)