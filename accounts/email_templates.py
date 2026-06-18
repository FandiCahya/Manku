"""
Email templates untuk ManKu App
Template HTML yang lebih menarik dan professional
"""

def get_otp_email_template(user_name, otp_code, expiry_minutes=10):
    """
    Template email untuk OTP verification
    """
    return f"""
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kode Verifikasi ManKu</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7fa;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f4f7fa; padding: 40px 20px;">
        <tr>
            <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
                    
                    <!-- Header dengan gradient -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 30px; text-align: center;">
                            <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 600;">
                                🔐 ManKu
                            </h1>
                            <p style="margin: 10px 0 0 0; color: #e0e7ff; font-size: 14px;">
                                Manajemen Keuangan Pribadi
                            </p>
                        </td>
                    </tr>
                    
                    <!-- Konten -->
                    <tr>
                        <td style="padding: 40px 30px;">
                            <h2 style="margin: 0 0 20px 0; color: #1a202c; font-size: 24px; font-weight: 600;">
                                Halo, {user_name}! 👋
                            </h2>
                            
                            <p style="margin: 0 0 20px 0; color: #4a5568; font-size: 16px; line-height: 1.6;">
                                Terima kasih telah mendaftar di <strong>ManKu</strong>. Untuk melanjutkan, silakan verifikasi akun Anda dengan memasukkan kode OTP berikut:
                            </p>
                            
                            <!-- OTP Box -->
                            <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                                <tr>
                                    <td align="center" style="background-color: #f7fafc; border: 2px dashed #cbd5e0; border-radius: 8px; padding: 30px;">
                                        <p style="margin: 0 0 10px 0; color: #718096; font-size: 14px; font-weight: 500;">
                                            KODE VERIFIKASI ANDA
                                        </p>
                                        <div style="font-size: 42px; font-weight: 700; color: #667eea; letter-spacing: 8px; font-family: 'Courier New', monospace;">
                                            {otp_code}
                                        </div>
                                        <p style="margin: 10px 0 0 0; color: #718096; font-size: 12px;">
                                            Berlaku selama {expiry_minutes} menit
                                        </p>
                                    </td>
                                </tr>
                            </table>
                            
                            <p style="margin: 20px 0; color: #4a5568; font-size: 14px; line-height: 1.6;">
                                Masukkan kode ini di aplikasi ManKu untuk mengaktifkan akun Anda.
                            </p>
                            
                            <!-- Warning Box -->
                            <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                                <tr>
                                    <td style="background-color: #fff5f5; border-left: 4px solid #fc8181; padding: 15px 20px; border-radius: 4px;">
                                        <p style="margin: 0; color: #742a2a; font-size: 13px; line-height: 1.5;">
                                            ⚠️ <strong>Penting:</strong> Jangan bagikan kode ini kepada siapapun, termasuk tim ManKu. Kami tidak akan pernah meminta kode OTP Anda.
                                        </p>
                                    </td>
                                </tr>
                            </table>
                            
                            <p style="margin: 20px 0 0 0; color: #718096; font-size: 14px; line-height: 1.6;">
                                Jika Anda tidak mendaftar di ManKu, abaikan email ini.
                            </p>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #f7fafc; padding: 30px; text-align: center; border-top: 1px solid #e2e8f0;">
                            <p style="margin: 0 0 10px 0; color: #718096; font-size: 13px;">
                                Email ini dikirim secara otomatis. Mohon tidak membalas email ini.
                            </p>
                            <p style="margin: 0; color: #a0aec0; font-size: 12px;">
                                © 2026 ManKu - Aplikasi Manajemen Keuangan Pribadi
                            </p>
                        </td>
                    </tr>
                    
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
"""


def get_password_reset_email_template(user_name, reset_url, expiry_hours=1):
    """
    Template email untuk reset password
    """
    return f"""
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password ManKu</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7fa;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f4f7fa; padding: 40px 20px;">
        <tr>
            <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
                    
                    <!-- Header -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 40px 30px; text-align: center;">
                            <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 600;">
                                🔑 ManKu
                            </h1>
                            <p style="margin: 10px 0 0 0; color: #fff5f7; font-size: 14px;">
                                Reset Password Akun Anda
                            </p>
                        </td>
                    </tr>
                    
                    <!-- Konten -->
                    <tr>
                        <td style="padding: 40px 30px;">
                            <h2 style="margin: 0 0 20px 0; color: #1a202c; font-size: 24px; font-weight: 600;">
                                Halo, {user_name}! 👋
                            </h2>
                            
                            <p style="margin: 0 0 20px 0; color: #4a5568; font-size: 16px; line-height: 1.6;">
                                Kami menerima permintaan untuk mereset password akun ManKu Anda. Klik tombol di bawah ini untuk membuat password baru:
                            </p>
                            
                            <!-- Button -->
                            <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                                <tr>
                                    <td align="center">
                                        <a href="{reset_url}" style="display: inline-block; padding: 16px 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #ffffff; text-decoration: none; border-radius: 8px; font-weight: 600; font-size: 16px; box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);">
                                            Reset Password Sekarang
                                        </a>
                                    </td>
                                </tr>
                            </table>
                            
                            <p style="margin: 20px 0; color: #718096; font-size: 14px; line-height: 1.6;">
                                Atau salin dan tempel URL berikut di browser Anda:
                            </p>
                            
                            <table width="100%" cellpadding="0" cellspacing="0" style="margin: 20px 0;">
                                <tr>
                                    <td style="background-color: #f7fafc; border: 1px solid #e2e8f0; border-radius: 6px; padding: 15px; word-break: break-all;">
                                        <p style="margin: 0; color: #4a5568; font-size: 13px; font-family: monospace;">
                                            {reset_url}
                                        </p>
                                    </td>
                                </tr>
                            </table>
                            
                            <p style="margin: 20px 0; color: #4a5568; font-size: 14px; line-height: 1.6;">
                                Link reset password ini akan <strong>kedaluwarsa dalam {expiry_hours} jam</strong>.
                            </p>
                            
                            <!-- Warning Box -->
                            <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                                <tr>
                                    <td style="background-color: #fffaf0; border-left: 4px solid #f6ad55; padding: 15px 20px; border-radius: 4px;">
                                        <p style="margin: 0; color: #744210; font-size: 13px; line-height: 1.5;">
                                            ⚠️ <strong>Tidak meminta reset password?</strong><br>
                                            Jika Anda tidak meminta reset password, abaikan email ini. Password Anda tetap aman dan tidak akan berubah.
                                        </p>
                                    </td>
                                </tr>
                            </table>
                            
                            <!-- Security Tips -->
                            <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                                <tr>
                                    <td style="background-color: #f0fff4; border-left: 4px solid #68d391; padding: 15px 20px; border-radius: 4px;">
                                        <p style="margin: 0 0 10px 0; color: #22543d; font-size: 13px; font-weight: 600;">
                                            💡 Tips Keamanan:
                                        </p>
                                        <ul style="margin: 0; padding-left: 20px; color: #22543d; font-size: 12px; line-height: 1.6;">
                                            <li>Gunakan password yang kuat dan unik</li>
                                            <li>Kombinasikan huruf besar, kecil, angka, dan simbol</li>
                                            <li>Jangan gunakan password yang sama untuk akun lain</li>
                                        </ul>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #f7fafc; padding: 30px; text-align: center; border-top: 1px solid #e2e8f0;">
                            <p style="margin: 0 0 10px 0; color: #718096; font-size: 13px;">
                                Email ini dikirim secara otomatis. Mohon tidak membalas email ini.
                            </p>
                            <p style="margin: 0 0 10px 0; color: #718096; font-size: 12px;">
                                Butuh bantuan? Hubungi kami di <a href="mailto:support@manku.app" style="color: #667eea; text-decoration: none;">support@manku.app</a>
                            </p>
                            <p style="margin: 0; color: #a0aec0; font-size: 12px;">
                                © 2026 ManKu - Aplikasi Manajemen Keuangan Pribadi
                            </p>
                        </td>
                    </tr>
                    
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
"""


def get_password_changed_email_template(user_name):
    """
    Template email konfirmasi setelah password berhasil diubah
    """
    return f"""
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Berhasil Diubah</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7fa;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f4f7fa; padding: 40px 20px;">
        <tr>
            <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
                    
                    <!-- Header -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%); padding: 40px 30px; text-align: center;">
                            <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 600;">
                                ✅ ManKu
                            </h1>
                            <p style="margin: 10px 0 0 0; color: #e8f9ff; font-size: 14px;">
                                Password Berhasil Diubah
                            </p>
                        </td>
                    </tr>
                    
                    <!-- Konten -->
                    <tr>
                        <td style="padding: 40px 30px;">
                            <h2 style="margin: 0 0 20px 0; color: #1a202c; font-size: 24px; font-weight: 600;">
                                Halo, {user_name}! 👋
                            </h2>
                            
                            <p style="margin: 0 0 20px 0; color: #4a5568; font-size: 16px; line-height: 1.6;">
                                Password akun ManKu Anda telah <strong>berhasil diubah</strong>.
                            </p>
                            
                            <!-- Success Icon -->
                            <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                                <tr>
                                    <td align="center" style="background-color: #f0fff4; border-radius: 8px; padding: 30px;">
                                        <div style="font-size: 64px; margin-bottom: 10px;">✅</div>
                                        <p style="margin: 0; color: #22543d; font-size: 18px; font-weight: 600;">
                                            Password Berhasil Diperbarui
                                        </p>
                                    </td>
                                </tr>
                            </table>
                            
                            <p style="margin: 20px 0; color: #4a5568; font-size: 14px; line-height: 1.6;">
                                Anda sekarang dapat login ke aplikasi ManKu menggunakan password baru Anda.
                            </p>
                            
                            <!-- Warning Box -->
                            <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                                <tr>
                                    <td style="background-color: #fff5f5; border-left: 4px solid #fc8181; padding: 15px 20px; border-radius: 4px;">
                                        <p style="margin: 0; color: #742a2a; font-size: 13px; line-height: 1.5;">
                                            ⚠️ <strong>Tidak mengubah password?</strong><br>
                                            Jika Anda tidak melakukan perubahan ini, segera hubungi tim support kami untuk mengamankan akun Anda.
                                        </p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #f7fafc; padding: 30px; text-align: center; border-top: 1px solid #e2e8f0;">
                            <p style="margin: 0 0 10px 0; color: #718096; font-size: 13px;">
                                Email ini dikirim secara otomatis. Mohon tidak membalas email ini.
                            </p>
                            <p style="margin: 0 0 10px 0; color: #718096; font-size: 12px;">
                                Butuh bantuan? Hubungi kami di <a href="mailto:support@manku.app" style="color: #667eea; text-decoration: none;">support@manku.app</a>
                            </p>
                            <p style="margin: 0; color: #a0aec0; font-size: 12px;">
                                © 2026 ManKu - Aplikasi Manajemen Keuangan Pribadi
                            </p>
                        </td>
                    </tr>
                    
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
"""
