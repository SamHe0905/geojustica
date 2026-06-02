import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnbData(
      icon: Icons.balance,
      title: 'Bem-vindo ao GeoJustiça',
      description:
          'O app que te ajuda a encontrar onde resolver seus problemas de justiça gratuitamente em Campo Grande.',
      color: AppColors.primary,
    ),
    _OnbData(
      icon: Icons.search_rounded,
      title: 'Como funciona',
      description:
          'Escolha uma categoria ou descreva sua situação. O app vai te mostrar as instituições mais próximas e indicadas.',
      color: AppColors.secondary,
    ),
    _OnbData(
      icon: Icons.emergency_rounded,
      title: 'Pronto para começar',
      description:
          'Em emergência, use o botão SOS no canto. Sempre que precisar, estamos aqui.',
      color: AppColors.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (p) => setState(() => _page = p),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _buildPage(_pages[i]),
              ),
            ),
            _buildIndicator(),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_page < _pages.length - 1)
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Pular'),
                    ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _next,
                    icon: Icon(_page < _pages.length - 1
                        ? Icons.arrow_forward_rounded
                        : Icons.check_rounded),
                    label: Text(_page < _pages.length - 1 ? 'Próximo' : 'Começar'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(160, 52),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnbData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [data.color.withOpacity(0.2), data.color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 80, color: data.color),
          ),
          const SizedBox(height: 32),
          Text(data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w900, height: 1.2)),
          const SizedBox(height: 12),
          Text(data.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  void _finish() {
    ref.read(settingsProvider.notifier).markOnboardingSeen();
    context.go(AppRoutes.home);
  }
}

class _OnbData {
  final IconData icon;
  final String title, description;
  final Color color;
  const _OnbData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
