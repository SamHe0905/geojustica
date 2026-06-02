import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import 'admin_login_screen.dart';
import 'admin_screen.dart';

/// Wrapper que decide se mostra o painel ou a tela de login.
/// Reativo: muda automaticamente quando o usuário faz login/logout.
class AdminGuard extends ConsumerWidget {
  const AdminGuard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authed = ref.watch(adminAuthProvider);
    return authed ? const AdminScreen() : const AdminLoginScreen();
  }
}
