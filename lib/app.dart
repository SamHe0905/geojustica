import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'features/flow/screens/flow_screen.dart';
import 'features/results/screens/results_screen.dart';
import 'features/institution/screens/institution_detail_screen.dart';
import 'features/map/screens/map_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/admin/screens/admin_screen.dart';
import 'features/admin/screens/admin_login_screen.dart';
import 'features/report/screens/report_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/lawyers/screens/lawyers_screen.dart';
import 'features/lawyers/screens/lawyer_detail_screen.dart';
import 'features/lawyers/screens/lawyer_signup_screen.dart';

class GeoJusticaApp extends ConsumerWidget {
  const GeoJusticaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final authed = ref.watch(adminAuthProvider);

    final router = GoRouter(
      initialLocation:
          settings.onboardingSeen ? AppRoutes.home : AppRoutes.onboarding,
      redirect: (context, state) {
        // Proteção da rota /admin: se não autenticado, manda para login
        if (state.matchedLocation == AppRoutes.admin && !authed) {
          return AppRoutes.adminLogin;
        }
        // Se já autenticado e tenta acessar login, redireciona pro admin
        if (state.matchedLocation == AppRoutes.adminLogin && authed) {
          return AppRoutes.admin;
        }
        return null;
      },
      routes: [
        GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
        GoRoute(path: AppRoutes.search, builder: (_, __) => const SearchScreen()),
        GoRoute(path: AppRoutes.flow, builder: (_, __) => const FlowScreen()),
        GoRoute(path: AppRoutes.results, builder: (_, __) => const ResultsScreen()),
        GoRoute(
          path: AppRoutes.institutionDetail,
          builder: (_, state) =>
              InstitutionDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(path: AppRoutes.map, builder: (_, __) => const MapScreen()),
        GoRoute(
          path: AppRoutes.mapAll,
          builder: (_, __) => const MapScreen(showAll: true),
        ),
        GoRoute(path: AppRoutes.admin, builder: (_, __) => const AdminScreen()),
        GoRoute(path: AppRoutes.adminLogin, builder: (_, __) => const AdminLoginScreen()),
        GoRoute(
          path: AppRoutes.report,
          builder: (_, state) =>
              ReportScreen(institutionId: state.pathParameters['id']!),
        ),
        GoRoute(path: AppRoutes.history, builder: (_, __) => const HistoryScreen()),
        GoRoute(path: AppRoutes.lawyers, builder: (_, __) => const LawyersScreen()),
        GoRoute(
          path: AppRoutes.lawyerSignup,
          builder: (_, __) => const LawyerSignupScreen(),
        ),
        GoRoute(
          path: AppRoutes.lawyerDetail,
          builder: (_, state) =>
              LawyerDetailScreen(id: state.pathParameters['id']!),
        ),
      ],
    );

    final baseTheme = AppTheme.light;
    final theme = settings.highContrast
        ? baseTheme.copyWith(
            scaffoldBackgroundColor: Colors.black,
            colorScheme: baseTheme.colorScheme.copyWith(
              surface: const Color(0xFF111111),
              onSurface: Colors.yellowAccent,
              primary: Colors.yellowAccent,
              onPrimary: Colors.black,
            ),
          )
        : baseTheme;

    return MaterialApp.router(
      title: 'GeoJustiça',
      theme: theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: child!,
        );
      },
    );
  }
}
