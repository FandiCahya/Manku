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
