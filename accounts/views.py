from django.conf import settings
from django.contrib.auth.models import User
from django.core.mail import send_mail
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from google.auth.transport import requests
from google.oauth2 import id_token
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

# pyrefly: ignore [missing-import]
from rest_framework_simplejwt.tokens import RefreshToken

from .models import OTPVerification
from .serializers import (
    GoogleLoginSerializer,
    LoginSerializer,
    RegisterSerializer,
    VerifyOTPSerializer,
)


# Helper method to get JWT tokens
def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        "refresh": str(refresh),
        "access": str(refresh.access_token),
    }


class RegisterView(APIView):
    def post(self, request):
        # Cek apakah email sudah terdaftar
        if User.objects.filter(email=request.data.get("email")).exists():
            return Response(
                {"error": "Email sudah terdaftar!"}, status=status.HTTP_400_BAD_REQUEST
            )

        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()

            # Buat OTP
            otp, created = OTPVerification.objects.get_or_create(user=user)
            otp.generate_code()

            # Kirim Email
            send_mail(
                "Kode Verifikasi ManKu",
                f"Halo {user.first_name},\n\nKode verifikasi Anda adalah: {otp.code}\n\nTerima kasih.",
                settings.DEFAULT_FROM_EMAIL,
                [user.email],
                fail_silently=False,
            )

            return Response(
                {"message": "Registrasi berhasil, silakan cek email untuk kode OTP."},
                status=status.HTTP_201_CREATED,
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class VerifyOTPView(APIView):
    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data["email"]
            code = serializer.validated_data["code"]

            try:
                user = User.objects.get(email=email)
                otp = OTPVerification.objects.get(user=user)

                if otp.code == code:
                    user.is_active = True
                    user.save()
                    otp.delete()  # Hapus OTP setelah sukses

                    tokens = get_tokens_for_user(user)
                    return Response(
                        {
                            "message": "Verifikasi berhasil!",
                            "tokens": tokens,
                            "user": {
                                "id": user.id,
                                "name": user.first_name,
                                "email": user.email,
                            },
                        },
                        status=status.HTTP_200_OK,
                    )
                else:
                    return Response(
                        {"error": "Kode OTP salah!"}, status=status.HTTP_400_BAD_REQUEST
                    )
            except (User.DoesNotExist, OTPVerification.DoesNotExist):
                return Response(
                    {"error": "Data tidak valid atau sudah diverifikasi."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data
            tokens = get_tokens_for_user(user)
            return Response(
                {
                    "success": True,
                    "message": f"Selamat datang kembali, {user.first_name or user.email}!",
                    "tokens": tokens,
                    "user": {
                        "id": user.id,
                        "name": user.first_name,
                        "email": user.email,
                    },
                },
                status=status.HTTP_200_OK,
            )

        # Ambil pesan error pertama yang paling relevan
        errors = serializer.errors

        # errors bisa berupa {"non_field_errors": [{"email": "..."}]} (dari ValidationError dict)
        # atau {"email": ["..."], "password": ["..."]}
        error_message = "Login gagal. Periksa kembali data yang kamu masukkan."
        error_field = None

        if "non_field_errors" in errors:
            # ValidationError dari dalam validate() yang melempar dict
            inner = errors["non_field_errors"]
            if isinstance(inner, list) and len(inner) > 0:
                item = inner[0]
                if isinstance(item, dict):
                    # item = {"email": "..."}  atau  {"password": "..."}
                    error_field = list(item.keys())[0]
                    error_message = list(item.values())[0]
                else:
                    error_message = str(item)
        elif "email" in errors:
            error_field = "email"
            msgs = errors["email"]
            error_message = msgs[0] if isinstance(msgs, list) else str(msgs)
        elif "password" in errors:
            error_field = "password"
            msgs = errors["password"]
            error_message = msgs[0] if isinstance(msgs, list) else str(msgs)

        return Response(
            {
                "success": False,
                "message": str(error_message),
                "field": error_field,  # field mana yang bermasalah (email / password / null)
            },
            status=status.HTTP_400_BAD_REQUEST,
        )


class GoogleLoginView(APIView):
    def post(self, request):
        serializer = GoogleLoginSerializer(data=request.data)
        if serializer.is_valid():
            token = serializer.validated_data["id_token"]

            # Pastikan GOOGLE_CLIENT_ID sudah dikonfigurasi di .env
            google_client_id = settings.GOOGLE_CLIENT_ID
            if not google_client_id:
                return Response(
                    {"error": "Konfigurasi Google Login belum lengkap. Hubungi admin."},
                    status=status.HTTP_503_SERVICE_UNAVAILABLE,
                )

            try:
                # Verifikasi id_token dari Flutter google_sign_in
                # audience = GOOGLE_CLIENT_ID (Web Application Client ID)
                idinfo = id_token.verify_oauth2_token(
                    token, requests.Request(), google_client_id
                )

                # Pastikan email sudah diverifikasi oleh Google
                if not idinfo.get("email_verified", False):
                    return Response(
                        {"error": "Email Google belum diverifikasi."},
                        status=status.HTTP_400_BAD_REQUEST,
                    )

                email = idinfo["email"]
                first_name = idinfo.get("given_name", "")
                last_name = idinfo.get("family_name", "")
                picture = idinfo.get("picture", "")

                # Cek user atau buat baru
                user, created = User.objects.get_or_create(
                    email=email,
                    defaults={
                        "username": email,
                        "first_name": first_name,
                        "last_name": last_name,
                        "is_active": True,  # Google otomatis verified
                    },
                )

                # Jika user sudah ada tapi belum aktif (daftar manual, belum verify OTP)
                if not created:
                    updated = False
                    if not user.is_active:
                        user.is_active = True
                        updated = True
                    # Update nama jika belum diisi
                    if not user.first_name and first_name:
                        user.first_name = first_name
                        updated = True
                    if not user.last_name and last_name:
                        user.last_name = last_name
                        updated = True
                    if updated:
                        user.save()

                # Hapus OTP jika ada (user login via Google tidak perlu OTP)
                if hasattr(user, "otp_verification"):
                    user.otp_verification.delete()

                tokens = get_tokens_for_user(user)
                return Response(
                    {
                        "message": "Google Login berhasil!",
                        "tokens": tokens,
                        "user": {
                            "id": user.id,
                            "name": user.get_full_name() or user.first_name,
                            "email": user.email,
                            "picture": picture,
                            "is_new": created,
                        },
                    },
                    status=status.HTTP_200_OK,
                )

            except ValueError as e:
                return Response(
                    {"error": f"Token Google tidak valid: {str(e)}"},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            except Exception as e:
                return Response(
                    {"error": f"Terjadi kesalahan saat verifikasi Google: {str(e)}"},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ── Halaman Test Google Login (hanya aktif saat DEBUG=True) ──────────────────
def google_test_page(request):
    """Halaman HTML untuk mendapatkan id_token Google — dipakai test di Postman."""
    if not settings.DEBUG:
        from django.http import Http404

        raise Http404("Halaman ini hanya tersedia di mode development.")
    # Bangun callback URL dari sisi server — ini URL yang HARUS didaftarkan
    # di Google Cloud Console sebagai Authorized Redirect URI
    callback_url = request.build_absolute_uri("/api/auth/google-token-callback/")
    return render(
        request,
        "google_test.html",
        {
            "google_client_id": settings.GOOGLE_CLIENT_ID or "",
            "callback_url": callback_url,
        },
    )


@csrf_exempt
@require_POST
def google_token_callback(request):
    """Menerima credential (id_token) dari Google Sign-In redirect flow.
    Google akan POST ke sini setelah user sign-in.
    Hanya aktif saat DEBUG=True.
    """
    if not settings.DEBUG:
        from django.http import Http404

        raise Http404()

    credential = request.POST.get("credential", "")
    return render(
        request,
        "google_token_result.html",
        {
            "credential": credential,
            "google_client_id": settings.GOOGLE_CLIENT_ID or "",
        },
    )
