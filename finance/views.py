import base64
import json
from io import BytesIO
from datetime import timedelta
from decimal import Decimal

from django.db.models import Sum, Count, Q, F
from django.utils import timezone
from groq import Groq
from PIL import Image
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Budget, Category, Transaction, SavingsGoal
from .serializers import BudgetSerializer, CategorySerializer, TransactionSerializer, SavingsGoalSerializer

# Konfigurasi Groq dengan API Key
client = Groq(api_key="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")

# Model selection dengan fallback
VISION_MODEL = "meta-llama/llama-4-scout-17b-16e-instruct"  # Replacement for deprecated llama-3.2-11b-vision-preview
TEXT_MODEL = "llama-3.3-70b-versatile"  # For text-only tasks
AUDIO_MODEL = "whisper-large-v3"  # For speech-to-text


class CategoryViewSet(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Hanya tampilkan kategori milik user yang sedang login
        return Category.objects.filter(user=self.request.user).order_by("name")


class BudgetViewSet(viewsets.ModelViewSet):
    serializer_class = BudgetSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Hanya tampilkan budget milik user yang sedang login
        return Budget.objects.filter(user=self.request.user).order_by("-month_year")


class TransactionViewSet(viewsets.ModelViewSet):
    serializer_class = TransactionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Hanya tampilkan transaksi milik user yang sedang login
        return Transaction.objects.filter(user=self.request.user).order_by(
            "-transaction_date"
        )

    @action(detail=False, methods=["post"], url_path="save-transaction")
    def save_transaction(self, request):
        from django.utils.dateparse import parse_date
        from datetime import datetime, timezone as dt_tz, timedelta

        user = request.user

        amount        = request.data.get("amount")
        description   = request.data.get("description", "")
        type_         = request.data.get("type", "expense")
        category_hint = request.data.get("category_hint", "Lainnya")
        date_str      = request.data.get("date")   # YYYY-MM-DD
        time_str      = request.data.get("time")   # HH:MM

        if not amount:
            return Response(
                {"error": "Field 'amount' wajib diisi."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # ── Bangun transaction_date dari date + time (WIB = UTC+7) ───────────
        WIB = dt_tz(timedelta(hours=7))
        if date_str:
            parsed_date = parse_date(date_str)
            if parsed_date:
                if time_str:
                    try:
                        parts = time_str.split(":")
                        hour, minute = int(parts[0]), int(parts[1]) if len(parts) > 1 else 0
                    except (ValueError, IndexError):
                        hour, minute = 0, 0
                else:
                    hour, minute = 0, 0
                txn_date = datetime(
                    parsed_date.year, parsed_date.month, parsed_date.day,
                    hour, minute, tzinfo=WIB
                )
            else:
                txn_date = timezone.now()
        else:
            txn_date = timezone.now()

        # ── Cari atau buat kategori ──────────────────────────────────────────
        category = Category.objects.filter(user=user, name=category_hint).first()
        if category:
            if category.type != type_:
                category.type = type_
                category.save()
        else:
            category = Category.objects.create(user=user, name=category_hint, type=type_)

        txn = Transaction.objects.create(
            user=user,
            category=category,
            amount=amount,
            description=description,
            transaction_date=txn_date,
            input_source="manual",
        )

        serializer = TransactionSerializer(txn, context={"request": request})
        return Response(
            {
                "message": "Transaksi berhasil disimpan.",
                "data": serializer.data,
            },
            status=status.HTTP_201_CREATED,
        )

    @action(detail=False, methods=["post"], url_path="scan-receipt")
    def scan_receipt(self, request):
        if "receipt_image" not in request.FILES:
            return Response(
                {"error": "Harap sertakan file receipt_image"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            # 1. Buka gambar menggunakan Pillow (PIL)
            image_file = request.FILES["receipt_image"]
            img = Image.open(image_file)

            # 2. Convert gambar ke base64 untuk OpenAI API
            img_byte_arr = BytesIO()
            img.save(img_byte_arr, format="PNG")
            img_base64 = base64.standard_b64encode(img_byte_arr.getvalue()).decode(
                "utf-8"
            )

            # 3. Buat Prompt Instruksi (Memaksa output JSON)
            prompt = """
            Kamu adalah sistem ekstraksi data keuangan. Baca gambar struk belanja ini.
            Tugasmu adalah mengembalikan HANYA format JSON murni tanpa markdown (jangan gunakan ```json).

            Struktur JSON yang WAJIB kamu keluarkan:
            {
                "amount": <total_belanja_dalam_angka_saja_tanpa_titik_atau_koma>,
                "description": "<nama_toko_atau_barang_utama>",
                "category_hint": "<tebak_kategori_seperti_Makanan_Transportasi_atau_Belanja>"
            }

            Contoh output yang BENAR:
            {"amount": 125000, "description": "Indomaret", "category_hint": "Belanja"}
            """

            # 4. Kirim gambar dan prompt ke OpenAI
            response = client.chat.completions.create(
                model=VISION_MODEL,
                max_tokens=500,
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:image/png;base64,{img_base64}"
                                },
                            },
                            {"type": "text", "text": prompt},
                        ],
                    }
                ],
            )

            # 5. Ekstrak dan bersihkan teks jawaban AI
            ai_text = response.choices[0].message.content.strip()

            # (Antisipasi jika AI masih memberikan markdown ```json)
            if ai_text.startswith("```json"):
                ai_text = ai_text[7:-3]
            elif ai_text.startswith("```"):
                ai_text = ai_text[3:-3]

            # 6. Ubah teks menjadi format Python Dictionary
            extracted_data = json.loads(ai_text)

            return Response(
                {
                    "message": "Struk berhasil dianalisis oleh OpenAI",
                    "extracted_data": extracted_data,
                },
                status=status.HTTP_200_OK,
            )

        except json.JSONDecodeError:
            return Response(
                {"error": "Gagal membaca format JSON dari AI. Coba foto ulang struk."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
        except Exception as e:
            return Response(
                {"error": f"Terjadi kesalahan: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

    @action(detail=False, methods=["post"], url_path="scan-voice")
    def scan_voice(self, request):
        if "audio_file" not in request.FILES:
            return Response(
                {"error": "Harap sertakan file audio_file"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            audio_file = request.FILES["audio_file"]

            # 1. Transcribe audio menggunakan OpenAI Whisper API
            transcript_response = client.audio.transcriptions.create(
                model=AUDIO_MODEL,
                file=audio_file,
                language="id",  # Set ke Bahasa Indonesia
            )

            transcribed_text = transcript_response.text

            # 2. Extract data dari transcription menggunakan GPT
            prompt = f"""
            Kamu adalah asisten pencatat keuangan otomatis. Analisis teks rekaman suara berikut ini.
            Ekstrak data transaksinya dan kembalikan HANYA format JSON murni tanpa markdown (jangan gunakan ```json).

            Teks rekaman: "{transcribed_text}"

            Struktur JSON yang WAJIB kamu keluarkan:
            {{
                "amount": <nominal_angka_saja>,
                "description": "<keterangan_transaksi_atau_barang>",
                "type": "<expense atau income>",
                "category_hint": "<tebak_kategori_seperti_Makanan_Transportasi_Gaji_dll>"
            }}

            Contoh output yang BENAR:
            {{"amount": 50000, "description": "Beli makan siang", "type": "expense", "category_hint": "Makanan"}}
            """

            # 3. Kirim ke GPT untuk extract JSON
            response = client.chat.completions.create(
                model=TEXT_MODEL,
                max_tokens=500,
                messages=[{"role": "user", "content": prompt}],
            )

            # 4. Bersihkan output AI
            ai_text = response.choices[0].message.content.strip()
            if ai_text.startswith("```json"):
                ai_text = ai_text[7:-3]
            elif ai_text.startswith("```"):
                ai_text = ai_text[3:-3]

            extracted_data = json.loads(ai_text)

            return Response(
                {
                    "message": "Suara berhasil dianalisis oleh OpenAI",
                    "transcription": transcribed_text,
                    "extracted_data": extracted_data,
                },
                status=status.HTTP_200_OK,
            )

        except json.JSONDecodeError:
            return Response(
                {"error": "Gagal membaca format JSON dari AI. Coba rekam suara lagi."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
        except Exception as e:
            return Response(
                {"error": f"Terjadi kesalahan: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

    @action(detail=False, methods=["post"], url_path="chat-input")
    def chat_input(self, request):
        text_message = request.data.get("text")
        if not text_message:
            return Response(
                {"error": "Harap sertakan data 'text' dalam request body"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            # Menggunakan timezone datetime sekarang untuk referensi GPT
            current_date = timezone.localtime().strftime("%Y-%m-%d")

            prompt = f"""
            Kamu adalah asisten pencatat keuangan otomatis. Analisis pesan teks berikut ini.
            Ekstrak data transaksinya dan kembalikan HANYA format JSON murni tanpa markdown (jangan gunakan ```json).

            Hari ini adalah tanggal: {current_date}

            Teks pesan: "{text_message}"

            Struktur JSON yang WAJIB kamu keluarkan:
            {{
                "amount": <nominal_angka_saja_tanpa_titik_atau_koma>,
                "description": "<keterangan_transaksi_atau_barang>",
                "type": "<expense atau income>",
                "category_hint": "<tebak_kategori_seperti_Makanan_Transportasi_Gaji_dll>",
                "date": "<tanggal_transaksi_format_YYYY-MM-DD>"
            }}

            PANDUAN TANGGAL:
            Jika user menyebutkan "kemarin", kurangi 1 hari dari {current_date}.
            Jika "besok", tambah 1 hari.
            Jika "hari ini", "tadi", "barusan" gunakan {current_date}.
            Jika tanggal sama sekali tidak bisa ditebak, keluarkan {current_date}.

            Contoh output yang BENAR:
            {{"amount": 50000, "description": "Beli makan siang", "type": "expense", "category_hint": "Makanan", "date": "{current_date}"}}
            """

            response = client.chat.completions.create(
                model=TEXT_MODEL,
                max_tokens=500,
                messages=[{"role": "user", "content": prompt}],
            )

            ai_text = response.choices[0].message.content.strip()
            if ai_text.startswith("```json"):
                ai_text = ai_text[7:-3]
            elif ai_text.startswith("```"):
                ai_text = ai_text[3:-3]

            extracted_data = json.loads(ai_text)

            # --- MULAI PROSES SIMPAN KE DATABASE ---
            # request.user sudah pasti terisi karena IsAuthenticated
            user = request.user

            category_hint = extracted_data.get("category_hint", "Lainnya")
            type_ = extracted_data.get("type", "expense")

            # 1. Cari atau buat kategori otomatis berdasarkan tebakan AI
            category, created = Category.objects.get_or_create(
                user=user, name=category_hint, type=type_
            )

            # 2. Simpan Transaksi
            txn = Transaction.objects.create(
                user=user,
                category=category,
                amount=extracted_data.get("amount", 0),
                description=extracted_data.get("description", ""),
                transaction_date=extracted_data.get("date", current_date),
                input_source="ai_voice",  # Bisa diganti ke tipe input teks
            )

            # 3. Serialize data untuk kembalian Flutter
            from .serializers import TransactionSerializer

            serializer = TransactionSerializer(txn)

            return Response(
                {
                    "message": "Pesan teks berhasil dianalisis dan langsung disimpan!",
                    "original_text": text_message,
                    "extracted_data": extracted_data,
                    "saved_transaction": serializer.data,
                },
                status=status.HTTP_201_CREATED,
            )

        except json.JSONDecodeError:
            return Response(
                {"error": "Gagal membaca format JSON dari AI. Coba ubah pesan kamu."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
        except Exception as e:
            return Response(
                {"error": f"Terjadi kesalahan: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

    # =========================================================================
    # ENDPOINT: GET /api/transactions/dashboard-summary/
    # total_balance, daily_expense, budget_left, total_income, spending_trends
    # =========================================================================
    @action(detail=False, methods=["get"], url_path="dashboard-summary")
    def dashboard_summary(self, request):
        user = request.user
        now = timezone.localtime()
        today = now.date()

        income_total = Transaction.objects.filter(
            user=user, category__type="income"
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        expense_total = Transaction.objects.filter(
            user=user, category__type="expense"
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        total_balance = income_total - expense_total

        daily_expense = Transaction.objects.filter(
            user=user,
            category__type="expense",
            transaction_date__date=today,
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        first_of_month = today.replace(day=1)
        monthly_income = Transaction.objects.filter(
            user=user,
            category__type="income",
            transaction_date__date__gte=first_of_month,
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        monthly_budget = Budget.objects.filter(
            user=user,
            month_year=first_of_month,
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        monthly_expense = Transaction.objects.filter(
            user=user,
            category__type="expense",
            transaction_date__date__gte=first_of_month,
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        budget_left = monthly_budget - monthly_expense

        spending_trends = []
        day_names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        for i in range(6, -1, -1):
            target_date = today - timedelta(days=i)
            day_exp = Transaction.objects.filter(
                user=user,
                category__type="expense",
                transaction_date__date=target_date,
            ).aggregate(total=Sum("amount"))["total"] or Decimal("0")
            spending_trends.append({
                "day": day_names[target_date.weekday()],
                "date": target_date.strftime("%Y-%m-%d"),
                "amount": float(day_exp),
            })

        return Response({
            "total_balance": float(total_balance),
            "total_income": float(income_total),  # All-time income
            "total_expense": float(expense_total),  # All-time expense
            "monthly_income": float(monthly_income),  # This month income
            "monthly_expense": float(monthly_expense),  # This month expense
            "daily_expense": float(daily_expense),
            "budget_left": float(budget_left),
            "spending_trends": spending_trends,
        }, status=status.HTTP_200_OK)

    # =========================================================================
    # ENDPOINT: GET /api/transactions/history/
    # Daftar transaksi dikelompokkan per tanggal
    # =========================================================================
    @action(detail=False, methods=["get"], url_path="history")
    def history(self, request):
        user = request.user
        now = timezone.localtime()
        today = now.date()
        yesterday = today - timedelta(days=1)

        transactions = Transaction.objects.filter(user=user).select_related(
            "category"
        ).order_by("-transaction_date")

        groups_dict = {}
        for txn in transactions:
            txn_date = timezone.localtime(txn.transaction_date).date()
            date_key = txn_date.strftime("%Y-%m-%d")

            if date_key not in groups_dict:
                if txn_date == today:
                    label = "TODAY, " + today.strftime("%d %b").upper()
                elif txn_date == yesterday:
                    label = "YESTERDAY, " + yesterday.strftime("%d %b").upper()
                else:
                    label = txn_date.strftime("%A, %d %b %Y").upper()

                groups_dict[date_key] = {
                    "date_label": label,
                    "date": date_key,
                    "transactions": [],
                }

            cat_name = txn.category.name if txn.category else "Lainnya"
            cat_type = txn.category.type if txn.category else "expense"
            desc = txn.description or cat_name
            groups_dict[date_key]["transactions"].append({
                "id": str(txn.id),
                "description": desc,
                "category_name": cat_name,
                "category_type": cat_type,
                "amount": float(txn.amount),
                "time": timezone.localtime(txn.transaction_date).strftime("%H:%M"),
                "input_source": txn.input_source,
            })

        groups = sorted(groups_dict.values(), key=lambda x: x["date"], reverse=True)

        return Response({
            "total_transactions": transactions.count(),
            "groups": groups,
        }, status=status.HTTP_200_OK)

    # =========================================================================
    # ENDPOINT: GET /api/transactions/monthly-summary/
    # Summary untuk bulan tertentu (untuk melihat data historical)
    # Query params: year=2026&month=1
    # =========================================================================
    @action(detail=False, methods=["get"], url_path="monthly-summary")
    def monthly_summary(self, request):
        user = request.user
        
        # Get year & month from query params (default to current month)
        now = timezone.localtime()
        year = int(request.query_params.get('year', now.year))
        month = int(request.query_params.get('month', now.month))
        
        # Validate month
        if not (1 <= month <= 12):
            return Response(
                {"error": "Month must be between 1-12"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Calculate date range for the month
        from datetime import date
        first_of_month = date(year, month, 1)
        
        if month == 12:
            last_of_month = date(year + 1, 1, 1)
        else:
            last_of_month = date(year, month + 1, 1)
        
        # Get transactions for this month
        transactions = Transaction.objects.filter(
            user=user,
            transaction_date__date__gte=first_of_month,
            transaction_date__date__lt=last_of_month,
        )
        
        # Calculate totals
        income = transactions.filter(
            category__type="income"
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")
        
        expense = transactions.filter(
            category__type="expense"
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")
        
        # Get budget for this month
        budget = Budget.objects.filter(
            user=user,
            month_year=first_of_month
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")
        
        # Category breakdown
        category_breakdown = []
        category_data = transactions.filter(
            category__type="expense"
        ).values("category__name").annotate(
            total=Sum("amount"),
            count=Count("id")
        ).order_by("-total")
        
        for cat in category_data:
            category_breakdown.append({
                "category": cat["category__name"],
                "amount": float(cat["total"]),
                "count": cat["count"],
            })
        
        return Response({
            "year": year,
            "month": month,
            "month_name": first_of_month.strftime("%B"),
            "income": float(income),
            "expense": float(expense),
            "net": float(income - expense),
            "budget": float(budget),
            "budget_left": float(budget - expense),
            "transaction_count": transactions.count(),
            "category_breakdown": category_breakdown,
        }, status=status.HTTP_200_OK)

    # =========================================================================
    # ENDPOINT: GET /api/transactions/all-time-stats/
    # Statistik keseluruhan dari semua waktu
    # =========================================================================
    @action(detail=False, methods=["get"], url_path="all-time-stats")
    def all_time_stats(self, request):
        user = request.user
        
        # Get all transactions
        all_transactions = Transaction.objects.filter(user=user)
        
        # Total income & expense
        income_total = all_transactions.filter(
            category__type="income"
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")
        
        expense_total = all_transactions.filter(
            category__type="expense"
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")
        
        # First & last transaction
        first_transaction = all_transactions.order_by("transaction_date").first()
        last_transaction = all_transactions.order_by("-transaction_date").first()
        
        # Category stats
        top_expense_categories = all_transactions.filter(
            category__type="expense"
        ).values("category__name").annotate(
            total=Sum("amount")
        ).order_by("-total")[:5]
        
        top_income_categories = all_transactions.filter(
            category__type="income"
        ).values("category__name").annotate(
            total=Sum("amount")
        ).order_by("-total")[:5]
        
        # Monthly average
        from datetime import date
        if first_transaction:
            first_date = timezone.localtime(first_transaction.transaction_date).date()
            today = timezone.localtime().date()
            
            # Calculate months between first transaction and now
            months_active = (
                (today.year - first_date.year) * 12 
                + today.month - first_date.month + 1
            )
            
            avg_monthly_income = float(income_total / months_active) if months_active > 0 else 0
            avg_monthly_expense = float(expense_total / months_active) if months_active > 0 else 0
        else:
            first_date = None
            months_active = 0
            avg_monthly_income = 0
            avg_monthly_expense = 0
        
        return Response({
            "total_balance": float(income_total - expense_total),
            "total_income": float(income_total),
            "total_expense": float(expense_total),
            "transaction_count": all_transactions.count(),
            "first_transaction_date": first_date.isoformat() if first_date else None,
            "last_transaction_date": timezone.localtime(last_transaction.transaction_date).date().isoformat() if last_transaction else None,
            "months_active": months_active,
            "average_monthly_income": avg_monthly_income,
            "average_monthly_expense": avg_monthly_expense,
            "top_expense_categories": [
                {
                    "category": cat["category__name"],
                    "total": float(cat["total"])
                }
                for cat in top_expense_categories
            ],
            "top_income_categories": [
                {
                    "category": cat["category__name"],
                    "total": float(cat["total"])
                }
                for cat in top_income_categories
            ],
        }, status=status.HTTP_200_OK)

    # =========================================================================
    # ENDPOINT: GET /api/transactions/report-summary/
    # total_spending, category_breakdown, performance_six_months
    # =========================================================================
    @action(detail=False, methods=["get"], url_path="report-summary")
    def report_summary(self, request):
        user = request.user
        now = timezone.localtime()
        today = now.date()
        first_of_month = today.replace(day=1)

        # Total spending & income bulan ini
        total_spending = Transaction.objects.filter(
            user=user,
            category__type="expense",
            transaction_date__date__gte=first_of_month,
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")
        
        total_income = Transaction.objects.filter(
            user=user,
            category__type="income",
            transaction_date__date__gte=first_of_month,
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        # Category breakdown untuk expense
        expense_category_data = (
            Transaction.objects.filter(
                user=user,
                category__type="expense",
                transaction_date__date__gte=first_of_month,
            )
            .values("category__name")
            .annotate(total=Sum("amount"), count=Count("id"))
            .order_by("-total")
        )

        expense_breakdown = []
        total_float = float(total_spending) if float(total_spending) > 0 else 1.0
        for cat in expense_category_data:
            amount = float(cat["total"])
            expense_breakdown.append({
                "name": cat["category__name"],
                "amount": amount,
                "count": cat["count"],
                "percentage": round(amount / total_float, 4),
            })
        
        # Category breakdown untuk income
        income_category_data = (
            Transaction.objects.filter(
                user=user,
                category__type="income",
                transaction_date__date__gte=first_of_month,
            )
            .values("category__name")
            .annotate(total=Sum("amount"), count=Count("id"))
            .order_by("-total")
        )

        income_breakdown = []
        income_float = float(total_income) if float(total_income) > 0 else 1.0
        for cat in income_category_data:
            amount = float(cat["total"])
            income_breakdown.append({
                "name": cat["category__name"],
                "amount": amount,
                "count": cat["count"],
                "percentage": round(amount / income_float, 4),
            })

        # Performance 6 bulan (income dan expense)
        performance_six_months = []
        month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                       "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

        for i in range(5, -1, -1):
            target_month = today.month - i
            target_year = today.year
            while target_month <= 0:
                target_month += 12
                target_year -= 1

            month_start = today.replace(year=target_year, month=target_month, day=1)
            if target_month == 12:
                month_end = today.replace(year=target_year + 1, month=1, day=1) - timedelta(days=1)
            else:
                month_end = today.replace(year=target_year, month=target_month + 1, day=1) - timedelta(days=1)

            month_expense = Transaction.objects.filter(
                user=user,
                category__type="expense",
                transaction_date__date__gte=month_start,
                transaction_date__date__lte=month_end,
            ).aggregate(total=Sum("amount"))["total"] or Decimal("0")
            
            month_income = Transaction.objects.filter(
                user=user,
                category__type="income",
                transaction_date__date__gte=month_start,
                transaction_date__date__lte=month_end,
            ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

            performance_six_months.append({
                "month": month_names[target_month - 1],
                "year": target_year,
                "expense": float(month_expense),
                "income": float(month_income),
                "net": float(month_income - month_expense),
                "is_current": i == 0,
            })

        max_expense = max((m["expense"] for m in performance_six_months), default=1.0)
        max_income = max((m["income"] for m in performance_six_months), default=1.0)
        if max_expense == 0:
            max_expense = 1.0
        if max_income == 0:
            max_income = 1.0

        return Response({
            "total_spending": float(total_spending),
            "total_income": float(total_income),
            "net_income": float(total_income - total_spending),
            "expense_breakdown": expense_breakdown,
            "income_breakdown": income_breakdown,
            "performance_six_months": performance_six_months,
            "performance_max_expense": max_expense,
            "performance_max_income": max_income,
        }, status=status.HTTP_200_OK)

    # =========================================================================
    # ENDPOINT: PUT/PATCH /api/transactions/{id}/
    # Override standard update agar bisa handle category_hint + type dari Flutter
    # =========================================================================
    def update(self, request, *args, **kwargs):
        from django.utils.dateparse import parse_date
        from datetime import datetime, timezone as dt_tz, timedelta

        kwargs.pop('partial', False)
        txn = self.get_object()

        amount        = request.data.get("amount")
        description   = request.data.get("description")
        type_         = request.data.get("type", txn.category.type if txn.category else "expense")
        category_hint = request.data.get("category_hint")
        date_str      = request.data.get("date")   # YYYY-MM-DD
        time_str      = request.data.get("time")   # HH:MM

        if amount is not None:
            txn.amount = amount

        if description is not None:
            txn.description = description

        # ── Update kategori ─────────────────────────────────────────────────
        if category_hint:
            # filter().first() lebih aman dari get() — tidak raise MultipleObjectsReturned
            category = Category.objects.filter(user=request.user, name=category_hint).first()
            if category:
                if category.type != type_:
                    category.type = type_
                    category.save(update_fields=["type"])
            else:
                category = Category.objects.create(
                    user=request.user, name=category_hint, type=type_
                )
            txn.category = category

        # ── Update transaction_date dengan date + time (WIB = UTC+7) ────────
        if date_str or time_str:
            WIB = dt_tz(timedelta(hours=7))

            # Ambil tanggal: dari request atau dari data saat ini
            if date_str:
                target_date = parse_date(date_str)
                if not target_date:
                    # Jika parse gagal, pakai tanggal saat ini
                    target_date = datetime.now(dt_tz.utc).date()
            else:
                # Ambil tanggal dari transaction_date yang sudah ada
                target_date = (txn.transaction_date + timedelta(hours=7)).date()

            # Ambil jam: dari request atau dari data saat ini
            if time_str:
                try:
                    parts = time_str.split(":")
                    hour   = int(parts[0])
                    minute = int(parts[1]) if len(parts) > 1 else 0
                except (ValueError, IndexError):
                    hour, minute = 0, 0
            else:
                existing_wib = txn.transaction_date + timedelta(hours=7)
                hour   = existing_wib.hour
                minute = existing_wib.minute

            txn.transaction_date = datetime(
                target_date.year, target_date.month, target_date.day,
                hour, minute, tzinfo=WIB
            )

        txn.save()

        serializer = self.get_serializer(txn)
        return Response({
            "message": "Transaksi berhasil diubah.",
            "data": serializer.data,
        }, status=status.HTTP_200_OK)

    # =========================================================================
    # ENDPOINT: DELETE /api/transactions/{id}/
    # Override standard destroy agar memberikan pesan yang jelas
    # =========================================================================
    def destroy(self, request, *args, **kwargs):
        txn = self.get_object()
        txn.delete()
        return Response({
            "message": "Transaksi berhasil dihapus."
        }, status=status.HTTP_200_OK)


# =============================================================================
# SavingsGoalViewSet
# CRUD untuk target tabungan user + action add_funds
# =============================================================================
class SavingsGoalViewSet(viewsets.ModelViewSet):
    serializer_class = SavingsGoalSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return SavingsGoal.objects.filter(user=self.request.user).order_by("-created_at")

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    # POST /api/savings-goals/{id}/add-funds/
    # Body: {"amount": 500000}
    # Tambahkan dana ke tabungan ini
    @action(detail=True, methods=["post"], url_path="add-funds")
    def add_funds(self, request, pk=None):
        goal = self.get_object()
        amount_str = request.data.get("amount")

        if not amount_str:
            return Response(
                {"error": "Field 'amount' wajib diisi."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            amount = Decimal(str(amount_str))
            if amount <= 0:
                raise ValueError
        except (ValueError, Exception):
            return Response(
                {"error": "'amount' harus berupa angka positif."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        goal.current_amount += amount
        goal.save()

        serializer = SavingsGoalSerializer(goal, context={"request": request})
        return Response({
            "message": f"Berhasil menambahkan Rp {float(amount):,.0f} ke '{goal.name}'.",
            "goal": serializer.data,
        }, status=status.HTTP_200_OK)

    # DELETE /api/savings-goals/{id}/withdraw/
    # Body: {"amount": 100000}
    # Kurangi dana dari tabungan
    @action(detail=True, methods=["post"], url_path="withdraw")
    def withdraw(self, request, pk=None):
        goal = self.get_object()
        amount_str = request.data.get("amount")

        if not amount_str:
            return Response(
                {"error": "Field 'amount' wajib diisi."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            amount = Decimal(str(amount_str))
            if amount <= 0:
                raise ValueError
        except (ValueError, Exception):
            return Response(
                {"error": "'amount' harus berupa angka positif."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if amount > goal.current_amount:
            return Response(
                {"error": "Jumlah penarikan melebihi saldo tabungan."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        goal.current_amount -= amount
        goal.save()

        serializer = SavingsGoalSerializer(goal, context={"request": request})
        return Response({
            "message": f"Berhasil menarik Rp {float(amount):,.0f} dari '{goal.name}'.",
            "goal": serializer.data,
        }, status=status.HTTP_200_OK)


# =============================================================================
# BudgetGoalViewSet
# Mengelola budget per kategori dengan sistem peringatan
# =============================================================================
class BudgetGoalViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated]

    # -------------------------------------------------------------------------
    # GET /api/budget-goals/
    # Daftar semua budget bulan ini dengan status pengeluaran dan peringatan.
    # Warning levels:
    #   'safe'      = spending < 70%  budget
    #   'warning'   = spending >= 70% budget (mendekati batas)
    #   'critical'  = spending >= 90% budget (hampir habis)
    #   'exceeded'  = spending > 100% budget (melewati batas)
    # -------------------------------------------------------------------------
    def list(self, request):
        user = request.user
        now = timezone.localtime()
        today = now.date()
        first_of_month = today.replace(day=1)

        budgets = Budget.objects.filter(
            user=user, month_year=first_of_month
        ).select_related("category")

        result = []
        total_budget = Decimal("0")
        total_spent = Decimal("0")
        exceeded_count = 0
        warning_count = 0

        for budget in budgets:
            spent = Transaction.objects.filter(
                user=user,
                category=budget.category,
                transaction_date__date__gte=first_of_month,
            ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

            pct = float(spent / budget.amount) if budget.amount > 0 else 0.0

            # Tentukan warning level
            if pct > 1.0:
                warn_level = "exceeded"
                exceeded_count += 1
            elif pct >= 0.9:
                warn_level = "critical"
                warning_count += 1
            elif pct >= 0.7:
                warn_level = "warning"
                warning_count += 1
            else:
                warn_level = "safe"

            total_budget += budget.amount
            total_spent += spent

            result.append({
                "id": str(budget.id),
                "category_id": str(budget.category.id),
                "category_name": budget.category.name,
                "category_type": budget.category.type,
                "budget_amount": float(budget.amount),
                "spent_amount": float(spent),
                "remaining": float(max(budget.amount - spent, 0)),
                "percentage_used": round(pct * 100, 1),
                "warning_level": warn_level,
                "month_year": budget.month_year.strftime("%Y-%m-%d"),
            })

        # Summary card
        overall_pct = float(total_spent / total_budget) if total_budget > 0 else 0.0
        if overall_pct > 1.0:
            overall_warning = "exceeded"
        elif overall_pct >= 0.9:
            overall_warning = "critical"
        elif overall_pct >= 0.7:
            overall_warning = "warning"
        else:
            overall_warning = "safe"

        return Response({
            "month": first_of_month.strftime("%B %Y"),
            "summary": {
                "total_budget": float(total_budget),
                "total_spent": float(total_spent),
                "total_remaining": float(max(total_budget - total_spent, 0)),
                "percentage_used": round(overall_pct * 100, 1),
                "warning_level": overall_warning,
                "exceeded_count": exceeded_count,
                "warning_count": warning_count,
            },
            "budgets": result,
        }, status=status.HTTP_200_OK)

    # -------------------------------------------------------------------------
    # POST /api/budget-goals/set/
    # Buat atau update budget untuk kategori tertentu di bulan ini.
    # Body: {"category_name": "Makanan", "amount": 1500000}
    # Juga bisa pakai "category_id" jika kategori sudah ada.
    # -------------------------------------------------------------------------
    @action(detail=False, methods=["post"], url_path="set")
    def set_budget(self, request):
        user = request.user
        now = timezone.localtime()
        today = now.date()
        first_of_month = today.replace(day=1)

        category_name = request.data.get("category_name")
        category_id = request.data.get("category_id")
        amount_str = request.data.get("amount")
        month_str = request.data.get("month_year")  # Optional: YYYY-MM-01

        if not amount_str:
            return Response(
                {"error": "Field 'amount' wajib diisi."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            amount = Decimal(str(amount_str))
            if amount <= 0:
                raise ValueError
        except (ValueError, Exception):
            return Response(
                {"error": "'amount' harus berupa angka positif."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Tentukan bulan target
        if month_str:
            try:
                from datetime import date
                parts = month_str.split("-")
                target_month = date(int(parts[0]), int(parts[1]), 1)
            except Exception:
                return Response(
                    {"error": "Format month_year tidak valid. Gunakan YYYY-MM-01."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
        else:
            target_month = first_of_month

        # Cari atau buat kategori
        if category_id:
            try:
                category = Category.objects.get(id=category_id, user=user)
            except Category.DoesNotExist:
                return Response(
                    {"error": "Kategori tidak ditemukan."},
                    status=status.HTTP_404_NOT_FOUND,
                )
        elif category_name:
            category, _ = Category.objects.get_or_create(
                user=user,
                name=category_name,
                defaults={"type": "expense"},
            )
        else:
            return Response(
                {"error": "Sertakan 'category_name' atau 'category_id'."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Upsert budget
        budget, created = Budget.objects.update_or_create(
            user=user,
            category=category,
            month_year=target_month,
            defaults={"amount": amount},
        )

        # Hitung spending saat ini untuk response
        spent = Transaction.objects.filter(
            user=user,
            category=category,
            transaction_date__date__gte=target_month,
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        pct = float(spent / budget.amount) if budget.amount > 0 else 0.0
        if pct > 1.0:
            warn_level = "exceeded"
        elif pct >= 0.9:
            warn_level = "critical"
        elif pct >= 0.7:
            warn_level = "warning"
        else:
            warn_level = "safe"

        action_word = "dibuat" if created else "diperbarui"
        return Response({
            "message": f"Budget untuk '{category.name}' bulan ini berhasil {action_word}.",
            "budget": {
                "id": str(budget.id),
                "category_name": category.name,
                "budget_amount": float(budget.amount),
                "spent_amount": float(spent),
                "remaining": float(max(budget.amount - spent, 0)),
                "percentage_used": round(pct * 100, 1),
                "warning_level": warn_level,
                "month_year": target_month.strftime("%Y-%m-%d"),
            },
        }, status=status.HTTP_200_OK)

    # -------------------------------------------------------------------------
    # DELETE /api/budget-goals/{id}/
    # Hapus budget berdasarkan ID
    # -------------------------------------------------------------------------
    def destroy(self, request, pk=None):
        try:
            budget = Budget.objects.get(id=pk, user=request.user)
            budget.delete()
            return Response({"message": "Budget berhasil dihapus."}, status=status.HTTP_200_OK)
        except Budget.DoesNotExist:
            return Response({"error": "Budget tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)

    # -------------------------------------------------------------------------
    # GET /api/budget-goals/savings-overview/
    # Overview tabungan: total savings, goals list, dan saldo bebas (disposable).
    # -------------------------------------------------------------------------
    @action(detail=False, methods=["get"], url_path="savings-overview")
    def savings_overview(self, request):
        user = request.user
        now = timezone.localtime()
        today = now.date()
        first_of_month = today.replace(day=1)

        # Saldo total (income - expense semua waktu)
        income_total = Transaction.objects.filter(
            user=user, category__type="income"
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        expense_total = Transaction.objects.filter(
            user=user, category__type="expense"
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        net_balance = income_total - expense_total

        # Total yang sudah dialokasikan ke savings goals
        goals = SavingsGoal.objects.filter(user=user)
        total_allocated = goals.aggregate(
            total=Sum("current_amount")
        )["total"] or Decimal("0")

        # Saldo bebas = net balance - total yang dialokasikan ke tabungan
        disposable = net_balance - total_allocated

        # Income & expense bulan ini
        monthly_income = Transaction.objects.filter(
            user=user,
            category__type="income",
            transaction_date__date__gte=first_of_month,
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        monthly_expense = Transaction.objects.filter(
            user=user,
            category__type="expense",
            transaction_date__date__gte=first_of_month,
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        monthly_savings = monthly_income - monthly_expense

        # Savings goals dengan detail
        goals_data = []
        for goal in goals.order_by("-created_at"):
            days_left = None
            is_overdue = False
            if goal.deadline:
                delta = (goal.deadline - today).days
                days_left = delta
                is_overdue = delta < 0

            goals_data.append({
                "id": str(goal.id),
                "name": goal.name,
                "target_amount": float(goal.target_amount),
                "current_amount": float(goal.current_amount),
                "remaining_amount": float(goal.remaining_amount),
                "progress_percentage": round(goal.progress_percentage * 100, 1),
                "deadline": goal.deadline.strftime("%Y-%m-%d") if goal.deadline else None,
                "days_remaining": days_left,
                "is_overdue": is_overdue,
                "is_completed": goal.is_completed,
                "description": goal.description or "",
                "color": goal.color,
                "icon": goal.icon,
            })

        return Response({
            "net_balance": float(net_balance),
            "total_allocated_to_goals": float(total_allocated),
            "disposable_balance": float(disposable),
            "monthly_income": float(monthly_income),
            "monthly_expense": float(monthly_expense),
            "monthly_savings": float(monthly_savings),
            "total_goals": goals.count(),
            "completed_goals": goals.filter(current_amount__gte=F("target_amount")).count(),
            "goals": goals_data,
        }, status=status.HTTP_200_OK)

    # -------------------------------------------------------------------------
    # GET /api/budget-goals/financial-advice/
    # Dapatkan saran pengelolaan keuangan berbasis AI menggunakan Groq
    # -------------------------------------------------------------------------
    @action(detail=False, methods=["get"], url_path="financial-advice")
    def financial_advice(self, request):
        user = request.user
        now = timezone.localtime()
        today = now.date()
        first_of_month = today.replace(day=1)

        # 1. Ambil data budget bulan ini
        budgets = Budget.objects.filter(
            user=user, month_year=first_of_month
        ).select_related("category")

        total_budget = Decimal("0")
        budget_details = []

        for budget in budgets:
            spent = Transaction.objects.filter(
                user=user,
                category=budget.category,
                transaction_date__date__gte=first_of_month,
            ).aggregate(total=Sum("amount"))["total"] or Decimal("0")
            
            total_budget += budget.amount
            budget_details.append(
                f"- {budget.category.name}: Budget Rp {budget.amount:,.0f}, Terpakai Rp {spent:,.0f}"
            )

        # 2. Hitung income dan expense bulan ini
        monthly_income = Transaction.objects.filter(
            user=user,
            category__type="income",
            transaction_date__date__gte=first_of_month,
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        monthly_expense = Transaction.objects.filter(
            user=user,
            category__type="expense",
            transaction_date__date__gte=first_of_month,
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0")

        budget_details_str = "\n".join(budget_details) if budget_details else "- Belum ada anggaran yang diatur."

        # 3. Bangun prompt untuk Groq LLM
        prompt = f"""
        Kamu adalah perencana keuangan pribadi (financial advisor) pintar dan ramah bernama ManKu Advisor.
        Tugasmu adalah menganalisis anggaran (budget) dan pengeluaran pengguna untuk bulan ini, lalu memberikan rekomendasi/saran keuangan yang dipersonalisasi dan sangat berguna dalam Bahasa Indonesia yang ramah, profesional, dan memotivasi.

        Data Keuangan Pengguna Bulan Ini ({first_of_month.strftime('%B %Y')}):
        - Total Pemasukan Aktual: Rp {monthly_income:,.0f}
        - Total Anggaran Belanja (Budget): Rp {total_budget:,.0f}
        - Total Pengeluaran Aktual: Rp {monthly_expense:,.0f}

        Daftar Anggaran per Kategori:
        {budget_details_str}

        Berikan respon Anda dalam format JSON murni tanpa markdown (JANGAN gunakan pembungkus ```json atau penanda blok kode lainnya).
        Struktur JSON wajib memiliki field-field berikut:
        {{
            "status_keuangan": "<Status singkat keuangan, misal: Sangat Baik, Sehat, Butuh Penyesuaian, Kritis, atau Belum Mengatur Anggaran>",
            "ringkasan_analisis": "<Analisis ringkas 2-3 kalimat mengenai alokasi anggaran dan pengeluaran pengguna. Berikan evaluasi apakah pengeluaran terkendali.>",
            "saran_list": [
                "<Saran konkret 1, misalnya tentang alokasi dana darurat atau pentingnya menabung.>",
                "<Saran konkret 2, misalnya mengenai pemangkasan pengeluaran pada kategori yang melebihi budget.>",
                "<Saran konkret 3, misalnya memberikan alternatif berhemat atau holiday budgeting.>"
            ],
            "tips_tambahan": "<Satu tips praktis tambahan berharga yang memotivasi pengguna untuk disiplin mencatat keuangan.>"
        }}
        """

        try:
            # 4. Kirim ke Groq API
            response = client.chat.completions.create(
                model=TEXT_MODEL,
                max_tokens=800,
                messages=[{"role": "user", "content": prompt}],
            )

            # 5. Ekstrak dan bersihkan respon
            ai_text = response.choices[0].message.content.strip()
            if ai_text.startswith("```json"):
                ai_text = ai_text[7:-3]
            elif ai_text.startswith("```"):
                ai_text = ai_text[3:-3]
            ai_text = ai_text.strip()

            # Parse JSON
            advice_data = json.loads(ai_text)
            return Response(advice_data, status=status.HTTP_200_OK)

        except Exception as e:
            # Fallback jika terjadi error API/parsing
            status_keuangan = "Butuh Penyesuaian" if total_budget > 0 else "Belum Mengatur Anggaran"
            
            if total_budget == 0:
                ringkasan = "Anda belum mengatur anggaran untuk bulan ini. Membuat rencana anggaran adalah langkah awal yang sangat penting untuk mencapai kebebasan finansial."
                saran = [
                    "Buatlah budget pertama Anda dengan menekan tombol 'Set Budget' di atas untuk kategori dasar seperti Makanan atau Kebutuhan Harian.",
                    "Gunakan aturan 50/30/20: 50% untuk kebutuhan, 30% untuk keinginan, dan 20% untuk tabungan/investasi.",
                    "Catat setiap pengeluaran sekecil apa pun untuk memahami ke mana perginya uang Anda."
                ]
                tips = "Disiplin kecil hari ini akan berbuah kebebasan finansial di masa depan!"
            else:
                ringkasan = "Anggaran Anda sudah diatur dengan baik. Mari kita evaluasi pengeluaran Anda agar tetap seimbang dengan pemasukan bulan ini."
                saran = [
                    "Pantau kategori budget yang memiliki peringatan mendekati batas agar tidak melebihi alokasi.",
                    "Prioritaskan pengeluaran wajib terlebih dahulu sebelum dialokasikan ke keinginan/hiburan.",
                    "Jika ada sisa anggaran di akhir bulan, alokasikan langsung ke tabungan atau dana darurat."
                ]
                tips = "Anggaran bukanlah pembatasan, melainkan panduan agar Anda bisa membelanjakan uang tanpa rasa bersalah!"

            return Response({
                "status_keuangan": status_keuangan,
                "ringkasan_analisis": ringkasan,
                "saran_list": saran,
                "tips_tambahan": tips,
                "debug_error": str(e)
            }, status=status.HTTP_200_OK)


# Helper untuk F expression
from django.db import models as django_models
