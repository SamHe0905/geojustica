import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import 'admin_login_screen.dart';
import 'admin_screen.dart';
import 'admin_setup_screen.dart';

/// Wrapper que decide se mostra o painel, o cadastro do primeiro dono ou o
/// login. Reativo: muda automaticamente quando o usuário faz login/logout.
///
/// Para rotas administrativas específicas (ex.: /admin/descobrir), passe um
/// [authenticatedChild] — ele só é exibido para quem está logado; senão a rota
/// cai no login, fechando o acesso direto pela URL.
class AdminGuard extends ConsumerWidget {
  final Widget? authenticatedChild;

  const AdminGuard({super.key, this.authenticatedChild});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(adminAuthProvider);

    // Enquanto o token salvo é revalidado no servidor.
    if (auth.restoring) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (auth.isLoggedIn) return authenticatedChild ?? const AdminScreen();
    // Painel sem nenhum dono ainda: cadastra o primeiro responsável.
    if (auth.needsSetup) return const AdminSetupScreen();
    return const AdminLoginScreen();
  }
}
