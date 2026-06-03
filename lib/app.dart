import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'features/flow/screens/flow_screen.dart';
import 'features/category_flow/screens/subcategory_screen.dart';
import 'features/category_flow/screens/safety_check_screen.dart';
import 'features/results/screens/results_screen.dart';
import 'features/institution/screens/institution_detail_screen.dart';
import 'features/map/screens/map_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/admin/screens/admin_guard.dart';
import 'features/report/screens/report_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/lawyers/screens/lawyers_screen.dart';
import 'features/lawyers/screens/lawyer_detail_screen.dart';
import 'features/lawyers/screens/lawyer_signup_screen.dart';
import 'shared/widgets/install_app_popup.dart';
import 'shared/widgets/flow_guard.dart';

class GeoJusticaApp extends ConsumerWidget {
  const GeoJusticaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final router = GoRouter(
      initialLocation:
          settings.onboardingSeen ? AppRoutes.home : AppRoutes.onboarding,
      routes: [
        GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
        GoRoute(path: AppRoutes.search, builder: (_, __) => const SearchScreen()),
        GoRoute(path: AppRoutes.flow, builder: (_, __) => const FlowGuard(child: FlowScreen())),
        GoRoute(path: AppRoutes.subcategory, builder: (_, __) => const FlowGuard(child: SubcategoryScreen())),
        GoRoute(path: AppRoutes.safetyCheck, builder: (_, __) => const FlowGuard(child: SafetyCheckScreen())),
        GoRoute(path: AppRoutes.results, builder: (_, __) => const FlowGuard(child: ResultsScreen())),
        GoRoute(
          path: AppRoutes.institutionDetail,
          builder: (_, state) =>
              InstitutionDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(path: AppRoutes.map, builder: (_, __) => const FlowGuard(child: MapScreen())),
        GoRoute(
          path: AppRoutes.mapAll,
          builder: (_, __) => const MapScreen(showAll: true),
        ),
        GoRoute(path: AppRoutes.admin, builder: (_, __) => const AdminGuard()),
        GoRoute(path: AppRoutes.adminLogin, builder: (_, __) => const AdminGuard()),
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
          child: InstallAppPopup(child: child!),
        );
      },
    );
  }
}
