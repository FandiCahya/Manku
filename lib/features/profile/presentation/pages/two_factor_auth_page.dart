import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../auth/data/auth_repository.dart';

class TwoFactorAuthPage extends StatefulWidget {
  const TwoFactorAuthPage({Key? key}) : super(key: key);

  @override
  State<TwoFactorAuthPage> createState() => _TwoFactorAuthPageState();
}

class _TwoFactorAuthPageState extends State<TwoFactorAuthPage> {
  bool _is2faEnabled = false;
  bool _isLoading = false;
  bool _isLoadingStatus = true; // loading status awal dari backend

  @override
  void initState() {
    super.initState();
    _loadCurrent2FAStatus();
  }

  /// Ambil status 2FA terkini dari backend
  Future<void> _loadCurrent2FAStatus() async {
    try {
      final profile = await AuthRepository.getProfile();
      if (mounted) {
        setState(() {
          _is2faEnabled = (profile['is_2fa_enabled'] as bool?) ?? false;
          _isLoadingStatus = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStatus = false);
    }
  }

  Future<void> _toggle2FA(bool value) async {
    setState(() => _isLoading = true);
    try {
      final res = await AuthRepository.toggle2FA(value);
      setState(() {
        _is2faEnabled = (res['is_2fa_enabled'] as bool?) ?? value;
      });
      _showSuccess((res['message'] as String?) ?? 'Status 2FA berhasil diubah');
    } catch (e) {
      _showError(e.toString());
      // Revert UI visually
      setState(() => _is2faEnabled = !value);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.replaceAll('Exception: ', '')), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Autentikasi 2 Langkah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoadingStatus
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tingkatkan keamanan akun Anda', style: TextStyle(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.security_update_good, color: Colors.orange),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gunakan 2FA (Email)', style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
                              const SizedBox(height: 4),
                              Text('Sistem akan mengirimkan OTP saat Anda mencoba login di perangkat baru.', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Switch(
                                value: _is2faEnabled,
                                activeColor: colors.primary,
                                onChanged: _toggle2FA,
                              ),
                      ],
                    ),
                  ),
                  if (_is2faEnabled) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '2FA aktif. Kode OTP akan dikirim ke email Anda setiap kali login.',
                              style: TextStyle(fontSize: 13, color: Colors.green.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
