from rest_framework import serializers
from django.utils import timezone
from .models import Budget, Category, Transaction, SavingsGoal


class CategorySerializer(serializers.ModelSerializer):
    # user di-set otomatis dari request.user, tidak perlu dikirim dari client
    user = serializers.HiddenField(default=serializers.CurrentUserDefault())

    class Meta:
        model = Category
        fields = "__all__"


class BudgetSerializer(serializers.ModelSerializer):
    user = serializers.HiddenField(default=serializers.CurrentUserDefault())
    category_name = serializers.ReadOnlyField(source="category.name")
    category_type = serializers.ReadOnlyField(source="category.type")

    class Meta:
        model = Budget
        fields = "__all__"


class TransactionSerializer(serializers.ModelSerializer):
    user = serializers.HiddenField(default=serializers.CurrentUserDefault())
    # Tampilkan nama & tipe kategori (bukan cuma ID) saat GET
    category_name = serializers.ReadOnlyField(source="category.name")
    category_type = serializers.ReadOnlyField(source="category.type")

    class Meta:
        model = Transaction
        fields = "__all__"


class SavingsGoalSerializer(serializers.ModelSerializer):
    user = serializers.HiddenField(default=serializers.CurrentUserDefault())

    # Computed fields (read-only)
    progress_percentage = serializers.SerializerMethodField()
    remaining_amount = serializers.SerializerMethodField()
    is_completed = serializers.SerializerMethodField()
    days_remaining = serializers.SerializerMethodField()

    class Meta:
        model = SavingsGoal
        fields = [
            'id', 'user', 'name', 'target_amount', 'current_amount',
            'deadline', 'description', 'color', 'icon',
            'created_at', 'updated_at',
            # computed
            'progress_percentage', 'remaining_amount',
            'is_completed', 'days_remaining',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_progress_percentage(self, obj):
        return round(obj.progress_percentage * 100, 1)  # Return 0-100

    def get_remaining_amount(self, obj):
        return float(obj.remaining_amount)

    def get_is_completed(self, obj):
        return obj.is_completed

    def get_days_remaining(self, obj):
        if obj.deadline is None:
            return None
        today = timezone.localtime().date()
        delta = (obj.deadline - today).days
        return delta  # Negatif jika sudah lewat deadline
