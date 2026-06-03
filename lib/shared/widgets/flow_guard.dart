import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/flow_provider.dart';

/// Widget que protege telas que precisam de FlowState válido.
/// Se a categoria estiver nula, redireciona automaticamente pra home.
class FlowGuard extends ConsumerStatefulWidget {
  final Widget child;
  const FlowGuard({super.key, required this.child});

  @override
  ConsumerState<FlowGuard> createState() => _FlowGuardState();
}

class _FlowGuardState extends ConsumerState<FlowGuard> {
  bool _redirecting = false;

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(flowProvider);
    if (flow.category == null) {
      if (!_redirecting) {
        _redirecting = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go(AppRoutes.home);
        });
      }
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Voltando ao início...',
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}
