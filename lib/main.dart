import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/constants/colors.dart';
import 'core/network/api_client.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/language_provider.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/home/presentation/home_page.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/transactions/presentation/cubit/transaction_cubit.dart';
import 'features/savings/presentation/cubit/savings_cubit.dart';
import 'features/investment/presentation/cubit/investment_cubit.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/theme/presentation/cubit/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MyApp({required this.prefs, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // AuthCubit is kept here so ApiClient.onUnauthorized can reference it
  // without needing context.read (unavailable before the first build).
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit()..checkSession();
    // When the session expires and token refresh fails, trigger a full logout.
    // AuthCubit.logout() emits AuthUnauthenticated which redirects to LoginPage.
    ApiClient.onUnauthorized = () => _authCubit.logout();
  }

  @override
  void dispose() {
    ApiClient.onUnauthorized = null;
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<DashboardCubit>(
          create: (context) => DashboardCubit()..fetchSummary(),
        ),
        BlocProvider<TransactionCubit>(
          create: (context) => TransactionCubit()..fetchTransactionsAndReport(),
        ),
        BlocProvider<SavingsCubit>(
          create: (context) => SavingsCubit()..fetchSavingsData(),
        ),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit(widget.prefs)),
        BlocProvider<InvestmentCubit>(
          create: (context) => InvestmentCubit()..loadInvestments(),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                title: 'Manku',
                debugShowCheckedModeBanner: false,
                themeMode: themeMode,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                locale: languageProvider.locale,
                supportedLocales: const [Locale('en'), Locale('id')],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                builder: (context, child) {
                  return child ?? const SizedBox();
                },
                home: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthInitial) {
                      return Scaffold(
                        backgroundColor: context.colors.background,
                        body: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              context.colors.primary,
                            ),
                          ),
                        ),
                      );
                    }
                    if (state is AuthAuthenticated) {
                      return const HomePage();
                    }
                    return const LoginPage();
                  },
                ),
                routes: {
                  '/home': (_) => const HomePage(),
                  '/login': (_) => const LoginPage(),
                  '/register': (_) => const RegisterPage(),
                },
              );
            },
          );
        },
      ),
    );
  }
}
