from django.contrib import admin
from .models import OTPVerification, PasswordResetToken, WhatsAppUser


@admin.register(OTPVerification)
class OTPVerificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'code', 'created_at', 'expires_at', 'is_expired')
    list_filter = ('created_at',)
    search_fields = ('user__username', 'user__email', 'code')
    readonly_fields = ('created_at',)


@admin.register(PasswordResetToken)
class PasswordResetTokenAdmin(admin.ModelAdmin):
    list_display = ('user', 'token', 'created_at', 'expires_at', 'is_used', 'is_valid')
    list_filter = ('is_used', 'created_at')
    search_fields = ('user__username', 'user__email', 'token')
    readonly_fields = ('token', 'created_at')


@admin.register(WhatsAppUser)
class WhatsAppUserAdmin(admin.ModelAdmin):
    list_display = ('phone_number', 'user', 'is_active', 'created_at', 'last_interaction')
    list_filter = ('is_active', 'created_at')
    search_fields = ('phone_number', 'user__username', 'user__email')
    readonly_fields = ('created_at', 'last_interaction')
    
    fieldsets = (
        ('User Information', {
            'fields': ('user', 'phone_number')
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'last_interaction'),
            'classes': ('collapse',)
        }),
    )
