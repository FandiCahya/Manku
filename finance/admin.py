from django.contrib import admin
from .models import Category, Budget, Transaction, SavingsGoal


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'type', 'user')
    list_filter = ('type',)
    search_fields = ('name', 'user__username')


@admin.register(Budget)
class BudgetAdmin(admin.ModelAdmin):
    list_display = ('user', 'category', 'amount', 'month_year')
    list_filter = ('month_year',)
    search_fields = ('user__username', 'category__name')


@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('user', 'category', 'amount', 'transaction_date', 'input_source')
    list_filter = ('input_source', 'transaction_date')
    search_fields = ('user__username', 'description')


@admin.register(SavingsGoal)
class SavingsGoalAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'target_amount', 'current_amount', 'deadline', 'is_completed_display')
    list_filter = ('color',)
    search_fields = ('name', 'user__username')

    def is_completed_display(self, obj):
        return obj.is_completed
    is_completed_display.short_description = 'Selesai?'
    is_completed_display.boolean = True
