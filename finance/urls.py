from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    CategoryViewSet,
    BudgetViewSet,
    TransactionViewSet,
    SavingsGoalViewSet,
)
from .investment_views import InvestmentViewSet

router = DefaultRouter()
router.register(r'categories', CategoryViewSet, basename='category')
router.register(r'budgets', BudgetViewSet, basename='budget')
router.register(r'transactions', TransactionViewSet, basename='transaction')
router.register(r'savings-goals', SavingsGoalViewSet, basename='savings-goal')
router.register(r'investments', InvestmentViewSet, basename='investment')

urlpatterns = [
    path('', include(router.urls)),
]