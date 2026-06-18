import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../auth/presentation/login_page.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../../savings/presentation/cubit/savings_cubit.dart';
import '../../savings/presentation/cubit/savings_state.dart';
import 'widgets/category_budget_tab.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_tab.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  String userName = 'User';
  String userEmail = '';
  String? userPhotoUrl;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();
    context.read<SavingsCubit>().fetchSavingsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        userName = prefs.getString('user_name') ?? 'User';
        userEmail = prefs.getString('user_email') ?? '';
        userPhotoUrl = prefs.getString('user_photo');
      });
      // Debug: Print photo URL to console
      debugPrint('📸 User Photo URL: $userPhotoUrl');
    }
  }

  void _handleLogout() {
    context.read<AuthCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          },
        ),
        BlocListener<SavingsCubit, SavingsState>(
          listener: (context, state) {
            if (state is SavingsSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green.shade600,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final user = authState is AuthAuthenticated ? authState.user : null;
          final dispName = user?.name ?? userName;
          final dispEmail = user?.email ?? userEmail;
          final photoUrl = user?.photoUrl ?? userPhotoUrl;

          return Scaffold(
            backgroundColor: context.colors.background,
            body: Column(
              children: [
                ProfileHeader(
                  name: dispName,
                  email: dispEmail,
                  photoUrl: photoUrl,
                  onLogout: _handleLogout,
                ),
                ColoredBox(
                  color: context.colors.surface,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: context.colors.primary,
                    labelColor: context.colors.primary,
                    unselectedLabelColor: context.colors.onSurfaceVariant,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(text: '👤 Profil'),
                      Tab(text: '🎯 Tujuan Keuangan'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ProfileTab(onLogout: _handleLogout),
                      const CategoryBudgetTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
