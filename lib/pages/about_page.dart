import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Tentang Aplikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Logo/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.colors.primary, context.colors.primaryDim],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              Text(
                'ManKu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              // Version
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Version 1.0.0 (Production)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Description
              Text(
                'ManKu adalah asisten pencatat keuangan cerdas yang membantu Anda melacak pemasukan, pengeluaran, serta tujuan tabungan Anda secara otomatis dan terstruktur.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              // Legal Links
              _buildLegalLink(
                context,
                title: 'Kebijakan Privasi (Privacy Policy)',
                icon: Icons.privacy_tip_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membuka Kebijakan Privasi...')),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildLegalLink(
                context,
                title: 'Syarat & Ketentuan',
                icon: Icons.description_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membuka Syarat & Ketentuan...')),
                  );
                },
              ),
              const SizedBox(height: 48),
              // Copyright
              Text(
                '© ${DateTime.now().year} ManKu Finance.\nHak Cipta Dilindungi Undang-Undang.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.onSurfaceVariant.withOpacity(0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalLink(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.outlineVariant.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.colors.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: context.colors.outlineVariant),
          ],
        ),
      ),
    );
  }
}
