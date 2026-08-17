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
    final auth = ref.watch(adminAuthProvider);

    // Enquanto o token salvo é revalidado no servidor.
    if (auth.restoring) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return auth.isLoggedIn ? const AdminScreen() : const AdminLoginScreen();
  }
}
