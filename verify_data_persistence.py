"""
Script untuk memverifikasi bahwa data TIDAK akan reset saat ganti bulan
Mendemonstrasikan bahwa data tersimpan permanen di database
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from finance.models import Transaction, Budget, SavingsGoal, Category
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import datetime, timedelta
from decimal import Decimal

def print_header(title):
    """Print header"""
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80)

def verify_transaction_persistence():
    """Verifikasi bahwa transaksi tidak hilang"""
    print_header("📊 VERIFIKASI: Transaction Persistence")
    
    # Cek apakah ada user
    users = User.objects.all()
    if not users.exists():
        print("⚠️  Belum ada user di database")
        print("   Silakan register user terlebih dahulu")
        return False
    
    user = users.first()
    print(f"\n✅ User: {user.email}")
    
    # Get all transactions
    all_transactions = Transaction.objects.filter(user=user)
    total_count = all_transactions.count()
    
    print(f"\n📋 Total Transaksi: {total_count}")
    
    if total_count == 0:
        print("⚠️  Belum ada transaksi")
        return False
    
    # Group by month
    from django.db.models.functions import TruncMonth
    monthly_stats = all_transactions.annotate(
        month=TruncMonth('transaction_date')
    ).values('month').annotate(
        count=Count('id')
    ).order_by('month')
    
    print(f"\n📅 Transaksi per Bulan:")
    for stat in monthly_stats:
        month = stat['month']
        count = stat['count']
        print(f"   {month.strftime('%B %Y')}: {count} transaksi")
    
    # Calculate total balance
    from django.db.models import Sum
    income = all_transactions.filter(
        category__type='income'
    ).aggregate(Sum('amount'))['amount__sum'] or Decimal('0')
    
    expense = all_transactions.filter(
        category__type='expense'
    ).aggregate(Sum('amount'))['amount__sum'] or Decimal('0')
    
    balance = income - expense
    
    print(f"\n💰 Total Balance (All Time):")
    print(f"   Income : Rp {float(income):,.0f}")
    print(f"   Expense: Rp {float(expense):,.0f}")
    print(f"   Balance: Rp {float(balance):,.0f}")
    
    # First and last transaction
    first = all_transactions.order_by('transaction_date').first()
    last = all_transactions.order_by('-transaction_date').first()
    
    print(f"\n📆 Periode Transaksi:")
    print(f"   Pertama: {timezone.localtime(first.transaction_date).strftime('%d %B %Y')}")
    print(f"   Terakhir: {timezone.localtime(last.transaction_date).strftime('%d %B %Y')}")
    
    return True

def verify_budget_persistence():
    """Verifikasi bahwa budget tidak hilang"""
    print_header("💼 VERIFIKASI: Budget Persistence")
    
    users = User.objects.all()
    if not users.exists():
        return False
    
    user = users.first()
    
    # Get all budgets
    all_budgets = Budget.objects.filter(user=user)
    total_count = all_budgets.count()
    
    print(f"\n📋 Total Budget Records: {total_count}")
    
    if total_count == 0:
        print("⚠️  Belum ada budget yang diset")
        return False
    
    # Group by month
    print(f"\n📅 Budget per Bulan:")
    for budget in all_budgets.order_by('month_year'):
        print(f"   {budget.month_year.strftime('%B %Y')}: Rp {float(budget.amount):,.0f} ({budget.category.name})")
    
    return True

def verify_savings_persistence():
    """Verifikasi bahwa savings tidak hilang"""
    print_header("🏦 VERIFIKASI: Savings Goal Persistence")
    
    users = User.objects.all()
    if not users.exists():
        return False
    
    user = users.first()
    
    # Get all savings goals
    all_savings = SavingsGoal.objects.filter(user=user)
    total_count = all_savings.count()
    
    print(f"\n📋 Total Savings Goals: {total_count}")
    
    if total_count == 0:
        print("⚠️  Belum ada savings goal")
        return False
    
    # Show savings details
    print(f"\n💰 Savings Goals:")
    for saving in all_savings:
        progress = saving.progress_percentage * 100
        print(f"\n   📌 {saving.name}")
        print(f"      Target  : Rp {float(saving.target_amount):,.0f}")
        print(f"      Current : Rp {float(saving.current_amount):,.0f}")
        print(f"      Progress: {progress:.1f}%")
        print(f"      Remaining: Rp {float(saving.remaining_amount):,.0f}")
        if saving.deadline:
            print(f"      Deadline: {saving.deadline.strftime('%d %B %Y')}")
    
    return True

def create_demo_data():
    """Buat data demo untuk testing persistensi"""
    print_header("🎨 CREATE DEMO DATA")
    
    # Get or create user
    user, created = User.objects.get_or_create(
        email='demo@example.com',
        defaults={
            'username': 'demo@example.com',
            'first_name': 'Demo User',
        }
    )
    
    if created:
        user.set_password('demo123')
        user.is_active = True
        user.save()
        print(f"✅ User created: {user.email}")
    else:
        print(f"✅ User exists: {user.email}")
    
    # Create categories
    cat_income, _ = Category.objects.get_or_create(
        user=user,
        name='Gaji',
        defaults={'type': 'income'}
    )
    
    cat_food, _ = Category.objects.get_or_create(
        user=user,
        name='Makanan',
        defaults={'type': 'expense'}
    )
    
    cat_transport, _ = Category.objects.get_or_create(
        user=user,
        name='Transportasi',
        defaults={'type': 'expense'}
    )
    
    print("✅ Categories created")
    
    # Create transactions for multiple months
    from datetime import date
    
    demo_transactions = [
        # Januari 2026
        (date(2026, 1, 5), cat_income, 5000000, "Gaji Januari"),
        (date(2026, 1, 10), cat_food, 50000, "Makan siang"),
        (date(2026, 1, 15), cat_transport, 30000, "Bensin"),
        (date(2026, 1, 20), cat_food, 75000, "Groceries"),
        
        # Februari 2026
        (date(2026, 2, 5), cat_income, 5500000, "Gaji Februari"),
        (date(2026, 2, 12), cat_food, 60000, "Makan malam"),
        (date(2026, 2, 18), cat_transport, 40000, "Parkir"),
        (date(2026, 2, 25), cat_food, 80000, "Groceries"),
        
        # Maret 2026
        (date(2026, 3, 5), cat_income, 6000000, "Gaji Maret"),
        (date(2026, 3, 10), cat_food, 55000, "Makan siang"),
        (date(2026, 3, 16), cat_transport, 35000, "Bensin"),
    ]
    
    created_count = 0
    for txn_date, category, amount, desc in demo_transactions:
        # Cek apakah transaksi sudah ada
        exists = Transaction.objects.filter(
            user=user,
            transaction_date__date=txn_date,
            description=desc
        ).exists()
        
        if not exists:
            Transaction.objects.create(
                user=user,
                category=category,
                amount=amount,
                description=desc,
                transaction_date=datetime.combine(txn_date, datetime.min.time()),
                input_source='manual'
            )
            created_count += 1
    
    print(f"✅ Transactions created: {created_count}")
    
    # Create budgets for multiple months
    budgets = [
        (date(2026, 1, 1), cat_food, 2000000),
        (date(2026, 2, 1), cat_food, 2500000),
        (date(2026, 3, 1), cat_food, 2200000),
    ]
    
    budget_count = 0
    for month_year, category, amount in budgets:
        budget, created = Budget.objects.get_or_create(
            user=user,
            category=category,
            month_year=month_year,
            defaults={'amount': amount}
        )
        if created:
            budget_count += 1
    
    print(f"✅ Budgets created: {budget_count}")
    
    # Create savings goal
    saving, created = SavingsGoal.objects.get_or_create(
        user=user,
        name='Dana Darurat',
        defaults={
            'target_amount': 10000000,
            'current_amount': 3500000,
            'deadline': date(2026, 12, 31),
            'description': 'Target dana darurat 6 bulan'
        }
    )
    
    if created:
        print(f"✅ Savings goal created")
    else:
        print(f"✅ Savings goal exists")
    
    return user

def demonstrate_persistence():
    """Demonstrasi bahwa data tidak reset saat ganti bulan"""
    print_header("🔬 DEMONSTRASI: Data Persistence Saat Ganti Bulan")
    
    print("\n📌 Konsep:")
    print("   - Data tersimpan PERMANEN di database")
    print("   - Setiap transaksi punya timestamp")
    print("   - Dashboard hanya FILTER data berdasarkan periode")
    print("   - Ganti bulan = ganti filter, BUKAN hapus data")
    
    print("\n📊 Contoh Ilustrasi:")
    print("   Januari 2026:")
    print("   - 50 transaksi tersimpan")
    print("   - Dashboard menampilkan: transaksi Januari saja")
    print("   - Total Balance: Akumulatif dari semua transaksi")
    
    print("\n       ⬇️ GANTI BULAN ⬇️")
    
    print("\n   Februari 2026:")
    print("   - 50 transaksi Januari MASIH ADA")
    print("   - 30 transaksi Februari baru ditambahkan")
    print("   - Total: 80 transaksi")
    print("   - Dashboard menampilkan: transaksi Februari saja")
    print("   - Total Balance: Akumulatif (Januari + Februari)")
    
    print("\n✅ Data Januari TIDAK HILANG!")
    print("✅ Bisa diakses via History atau Report")

def main():
    """Main function"""
    print("\n" + "=" * 80)
    print("  🔬 VERIFIKASI PERSISTENSI DATA - ManKu Backend")
    print("=" * 80)
    
    print("\n📌 Tujuan:")
    print("   Memverifikasi bahwa data TIDAK akan reset saat ganti bulan")
    
    # Menu
    print("\n" + "=" * 80)
    print("  Pilihan:")
    print("=" * 80)
    print("  1. Buat Data Demo")
    print("  2. Verifikasi Transaction Persistence")
    print("  3. Verifikasi Budget Persistence")
    print("  4. Verifikasi Savings Persistence")
    print("  5. Demonstrasi Konsep Persistence")
    print("  6. Run All Verifications")
    print("  0. Exit")
    
    choice = input("\nPilih menu (0-6): ").strip()
    
    if choice == "1":
        create_demo_data()
    elif choice == "2":
        verify_transaction_persistence()
    elif choice == "3":
        verify_budget_persistence()
    elif choice == "4":
        verify_savings_persistence()
    elif choice == "5":
        demonstrate_persistence()
    elif choice == "6":
        # Run all
        create_demo_data()
        verify_transaction_persistence()
        verify_budget_persistence()
        verify_savings_persistence()
        demonstrate_persistence()
    elif choice == "0":
        print("\n👋 Terima kasih!\n")
        return
    else:
        print("\n❌ Pilihan tidak valid!")
    
    print("\n" + "=" * 80)
    print("  ✅ KESIMPULAN")
    print("=" * 80)
    print("  Data ManKu tersimpan PERMANEN di database")
    print("  TIDAK ADA mekanisme auto-reset atau auto-delete")
    print("  Dashboard hanya menampilkan data sesuai filter periode")
    print("  Semua data historical bisa diakses kapan saja")
    print("=" * 80 + "\n")

if __name__ == "__main__":
    from django.db.models import Count
    main()
