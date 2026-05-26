from django.urls import path

from .views import (
    GoogleLoginView,
    LoginView,
    RegisterView,
    VerifyOTPView,
    google_test_page,
    google_token_callback,
)

urlpatterns = [
    path("register/", RegisterView.as_view(), name="register"),
    path("verify-otp/", VerifyOTPView.as_view(), name="verify-otp"),
    path("login/", LoginView.as_view(), name="login"),
    path("google-login/", GoogleLoginView.as_view(), name="google-login"),
    # Halaman test untuk mendapatkan id_token Google (hanya DEBUG mode)
    path("google-token-test/", google_test_page, name="google-token-test"),
    # Callback dari Google redirect flow — menerima credential POST dari Google
    path("google-token-callback/", google_token_callback, name="google-token-callback"),
]
