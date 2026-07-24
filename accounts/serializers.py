from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from rest_framework import serializers


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ("first_name", "email", "password")

    def create(self, validated_data):
        # We use email as username
        user = User.objects.create_user(
            username=validated_data["email"],
            email=validated_data["email"],
            password=validated_data["password"],
            first_name=validated_data.get("first_name", ""),
        )
        user.is_active = False  # Deactivate until OTP is verified
        user.save()
        return user


class VerifyOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(max_length=6)


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField(
        error_messages={
            "required": "Email wajib diisi.",
            "blank": "Email tidak boleh kosong.",
            "invalid": "Format email tidak valid. Contoh: nama@email.com",
        }
    )
    password = serializers.CharField(
        write_only=True,
        error_messages={
            "required": "Password wajib diisi.",
            "blank": "Password tidak boleh kosong.",
        },
    )

    def validate(self, data):
        email = data.get("email")
        password = data.get("password")

        # 1. Cek apakah email terdaftar
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            raise serializers.ValidationError(
                {"email": "Email tidak terdaftar. Silakan daftar terlebih dahulu."}
            )

        # 2. Cek apakah akun sudah diverifikasi (OTP)
        if not user.is_active:
            raise serializers.ValidationError(
                {"email": "Akun belum diverifikasi. Silakan cek email untuk kode OTP."}
            )

        # 3. Cek password
        authenticated = authenticate(username=email, password=password)
        if authenticated is None:
            raise serializers.ValidationError(
                {"password": "Password salah. Silakan coba lagi."}
            )

        return authenticated


class GoogleLoginSerializer(serializers.Serializer):
    id_token = serializers.CharField()


class RequestPasswordResetSerializer(serializers.Serializer):
    """Serializer untuk request reset password"""
    email = serializers.EmailField(
        error_messages={
            "required": "Email wajib diisi.",
            "blank": "Email tidak boleh kosong.",
            "invalid": "Format email tidak valid.",
        }
    )

    def validate_email(self, value):
        """Validasi bahwa email terdaftar"""
        if not User.objects.filter(email=value).exists():
            raise serializers.ValidationError(
                "Email tidak terdaftar dalam sistem."
            )
        return value


class ResetPasswordSerializer(serializers.Serializer):
    """Serializer untuk reset password dengan token"""
    token = serializers.UUIDField(
        error_messages={
            "required": "Token wajib diisi.",
            "invalid": "Format token tidak valid.",
        }
    )
    new_password = serializers.CharField(
        min_length=6,
        write_only=True,
        error_messages={
            "required": "Password baru wajib diisi.",
            "min_length": "Password minimal 6 karakter.",
        }
    )
    confirm_password = serializers.CharField(
        write_only=True,
        error_messages={
            "required": "Konfirmasi password wajib diisi.",
        }
    )

    def validate(self, data):
        """Validasi bahwa password dan confirm password sama"""
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError(
                {"confirm_password": "Password dan konfirmasi password tidak sama."}
            )
        return data


class ResendOTPSerializer(serializers.Serializer):
    """Serializer untuk resend OTP"""
    email = serializers.EmailField(
        error_messages={
            "required": "Email wajib diisi.",
            "invalid": "Format email tidak valid.",
        }
    )


class ProfileUpdateSerializer(serializers.ModelSerializer):
    """Serializer untuk mengupdate profile user"""
    first_name = serializers.CharField(required=True, max_length=150)
    email = serializers.EmailField(required=True)

    class Meta:
        model = User
        fields = ('first_name', 'email')

    def validate_email(self, value):
        # Ensure email is unique except for the current user
        user = self.context['request'].user
        if User.objects.filter(email=value).exclude(id=user.id).exists():
            raise serializers.ValidationError("Email ini sudah digunakan oleh akun lain.")
        return value


class ChangePasswordSerializer(serializers.Serializer):
    """Serializer untuk mengubah password"""
    current_password = serializers.CharField(required=True)
    new_password = serializers.CharField(
        required=True, 
        min_length=8,
        error_messages={
            "min_length": "Password baru minimal 8 karakter.",
        }
    )
    confirm_password = serializers.CharField(required=True)

    def validate(self, data):
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError({"confirm_password": "Password baru dan konfirmasi password tidak sama."})
        return data


class Toggle2FASerializer(serializers.Serializer):
    """Serializer untuk toggle 2FA"""
    is_2fa_enabled = serializers.BooleanField(required=True)
