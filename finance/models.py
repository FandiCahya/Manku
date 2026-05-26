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