import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/flow_provider.dart';

/// Protege telas que dependem do FlowState.
/// Como o FlowState é persistido em LocalStorage, aguarda 1.5s antes de
/// decidir se deve voltar pra home, garantindo que o async load termine.
class FlowGuard extends ConsumerStatefulWidget {
  final Widget child;
  const FlowGuard({super.key, required this.child});

  @override
  ConsumerState<FlowGuard> createState() => _FlowGuardState();
}

class _FlowGuardState extends ConsumerState<FlowGuard> {
  bool _gaveUp = false;

  @override
  void initState() {
    super.initState();
    // Espera até 1.5s pelo restore do storage; se ainda não tiver, volta pra home
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final flow = ref.read(flowProvider);
      if (flow.category == null) {
        setState(() => _gaveUp = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go(AppRoutes.home);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(flowProvider);

    if (flow.category != null) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 18),
            Text(
              _gaveUp ? 'Voltando ao início...' : 'Carregando...',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
