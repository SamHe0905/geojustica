import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team_member.dart';
import '../repositories/team_repository.dart';

final teamRepoProvider = Provider((ref) => TeamRepository());

/// Estado da sessão do painel.
/// `restoring` fica true enquanto o token salvo no navegador é revalidado.
class AdminAuthState {
  final bool restoring;
  final AdminSession? session;

  /// True quando o painel ainda não tem um dono e precisa do cadastro inicial.
  final bool needsSetup;

  const AdminAuthState({
    this.restoring = true,
    this.session,
    this.needsSetup = false,
  });

  bool get isLoggedIn => session != null;
  TeamMember? get member => session?.member;
  bool get isOwner => session?.member.isOwner ?? false;
  String? get token => session?.token;
}

final adminAuthProvider =
    StateNotifierProvider<AdminAuthNotifier, AdminAuthState>(
      (ref) => AdminAuthNotifier(ref.watch(teamRepoProvider)),
    );

class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  static const String _tokenKey = 'admin_session_token';

  /// Chave do esquema antigo (senha única). Limpa no boot para que ninguém
  /// continue "logado" sem conta depois da migração.
  static const String _legacyKey = 'admin_authenticated';

  final TeamRepository _repo;

  AdminAuthNotifier(this._repo) : super(const AdminAuthState()) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyKey);

    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      try {
        final session = await _repo.restore(token);
        if (session != null) {
          state = AdminAuthState(restoring: false, session: session);
          return;
        }
        await prefs.remove(_tokenKey);
      } catch (_) {
        // Offline ou servidor fora: cai para a tela de login sem apagar o token.
        state = const AdminAuthState(restoring: false);
        return;
      }
    }
    // Sem sessão válida: decide entre cadastro inicial (nenhum dono) e login.
    await _resolveSetupOrLogin();
  }

  /// Define se a próxima tela é o cadastro do primeiro dono ou o login normal.
  Future<void> _resolveSetupOrLogin() async {
    try {
      final needs = await _repo.needsSetup();
      state = AdminAuthState(restoring: false, needsSetup: needs);
    } catch (_) {
      // Se não der pra checar (offline), mostra o login por padrão.
      state = const AdminAuthState(restoring: false);
    }
  }

  /// Cria o primeiro dono do painel. Retorna null em sucesso, ou a mensagem de
  /// erro a exibir.
  Future<String?> bootstrap(
    String username,
    String name,
    String password,
  ) async {
    try {
      final session = await _repo.bootstrap(username, name, password);
      if (session == null) return 'Não foi possível criar a conta.';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, session.token);
      state = AdminAuthState(restoring: false, session: session);
      return null;
    } on TeamException catch (e) {
      return e.message;
    }
  }

  /// Retorna null em caso de sucesso, ou a mensagem de erro a exibir.
  Future<String?> login(String username, String password) async {
    try {
      final session = await _repo.login(username, password);
      if (session == null) return 'Usuário ou senha incorretos.';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, session.token);
      state = AdminAuthState(restoring: false, session: session);
      return null;
    } on TeamException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    final token = state.token;
    state = const AdminAuthState(restoring: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    if (token != null) {
      try {
        await _repo.logout(token);
      } catch (_) {
        // Sessão local já foi encerrada; o registro remoto expira sozinho.
      }
    }
  }

  /// Reaplica os dados do membro (ex.: depois que o dono renomeia a si mesmo).
  Future<void> refreshMember() async {
    final token = state.token;
    if (token == null) return;
    try {
      final session = await _repo.restore(token);
      state = AdminAuthState(restoring: false, session: session);
    } catch (_) {
      // Mantém o estado atual se a revalidação falhar.
    }
  }
}
