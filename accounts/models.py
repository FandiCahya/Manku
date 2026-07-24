from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta
import random
import string
import uuid


class OTPVerification(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='otp_verification')
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField(null=True, blank=True)

    def generate_code(self, expiry_minutes=10):
        """Generate OTP code dengan expiry time"""
        self.code = ''.join(random.choices(string.digits, k=6))
        self.expires_at = timezone.now() + timedelta(minutes=expiry_minutes)
        self.save()

    def is_expired(self):
        """Cek apakah OTP sudah expired"""
        if self.expires_at:
            return timezone.now() > self.expires_at
        return False

    def __str__(self):
        return f"{self.user.email} - {self.code}"


class PasswordResetToken(models.Model):
    """Model untuk menyimpan token reset password"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='password_reset_tokens')
    token = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)

    def save(self, *args, **kwargs):
        # Set expiry 1 jam dari sekarang jika belum diset
        if not self.expires_at:
            self.expires_at = timezone.now() + timedelta(hours=1)
        super().save(*args, **kwargs)

    def is_expired(self):
        """Cek apakah token sudah expired"""
        return timezone.now() > self.expires_at

    def is_valid(self):
        """Cek apakah token masih valid (belum expired dan belum dipakai)"""
        return not self.is_used and not self.is_expired()

    def __str__(self):
        return f"{self.user.email} - {self.token}"

    class Meta:
        ordering = ['-created_at']


class WhatsAppUser(models.Model):
    """Model untuk mapping nomor WhatsApp ke User account"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='whatsapp_account')
    phone_number = models.CharField(max_length=20, unique=True, help_text="Format: 628xxx (tanpa + atau spasi)")
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    last_interaction = models.DateTimeField(null=True, blank=True)
    
    def update_last_interaction(self):
        """Update timestamp interaksi terakhir"""
        self.last_interaction = timezone.now()
        self.save(update_fields=['last_interaction'])
    
    def __str__(self):
        return f"{self.phone_number} -> {self.user.username}"
    
    class Meta:
        verbose_name = "WhatsApp User"
        verbose_name_plural = "WhatsApp Users"
        ordering = ['-created_at']


class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    is_2fa_enabled = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.user.username} Profile"
