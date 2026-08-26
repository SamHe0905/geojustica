import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/team_member.dart';

/// Erro de negócio vindo das funções `team_*` do Postgres, já com a mensagem
/// pronta para mostrar na tela.
class TeamException implements Exception {
  final String message;
  const TeamException(this.message);
  @override
  String toString() => message;
}

/// Acesso à equipe do painel. Tudo passa por funções `security definer` no
/// Supabase — as tabelas `team_members`/`team_sessions` são inacessíveis pela
/// anon key, então o hash da senha nunca chega ao cliente.
class TeamRepository {
  SupabaseClient get _client {
    if (!SupabaseConfig.useSupabase) {
      throw const TeamException(
        'Backend desativado — o painel precisa do Supabase para autenticar.',
      );
    }
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw const TeamException(
        'Sem conexão com o Supabase. Verifique a internet e tente de novo.',
      );
    }
  }

  Future<T> _call<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      throw TeamException(e.message);
    } on TeamException {
      rethrow;
    } catch (e) {
      throw TeamException('Falha ao falar com o servidor: $e');
    }
  }

  /// True quando ainda não existe nenhum dono ativo — o painel precisa que o
  /// primeiro responsável seja criado (tela de setup no 1º acesso).
  Future<bool> needsSetup() async {
    return _call(() async {
      final result = await _client.rpc('team_needs_setup');
      return result == true;
    });
  }

  /// Cria o primeiro dono do painel. Só funciona enquanto não há nenhum dono
  /// ativo; devolve a sessão já logada.
  Future<AdminSession?> bootstrap(
    String username,
    String name,
    String password,
  ) async {
    return _call(() async {
      final result = await _client.rpc(
        'team_bootstrap',
        params: {
          'p_username': username,
          'p_name': name,
          'p_password': password,
        },
      );
      if (result == null) return null;
      return AdminSession.fromMap(Map<String, dynamic>.from(result as Map));
    });
  }

  /// Retorna a sessão criada, ou null se usuário/senha não conferem.
  Future<AdminSession?> login(String username, String password) async {
    return _call(() async {
      final result = await _client.rpc(
        'team_login',
        params: {'p_username': username, 'p_password': password},
      );
      if (result == null) return null;
      return AdminSession.fromMap(Map<String, dynamic>.from(result as Map));
    });
  }

  /// Revalida um token guardado. Retorna null se expirou ou foi revogado.
  Future<AdminSession?> restore(String token) async {
    return _call(() async {
      final result = await _client.rpc('team_me', params: {'p_token': token});
      if (result == null) return null;
      return AdminSession.fromMap(Map<String, dynamic>.from(result as Map));
    });
  }

  Future<void> logout(String token) async {
    await _call(() => _client.rpc('team_logout', params: {'p_token': token}));
  }

  Future<List<TeamMember>> list(String token) async {
    return _call(() async {
      final result = await _client.rpc('team_list', params: {'p_token': token});
      final rows = (result as List?) ?? const [];
      return rows
          .map((e) => TeamMember.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    });
  }

  Future<void> create(
    String token, {
    required String username,
    required String name,
    required String password,
    required TeamRole role,
  }) async {
    await _call(
      () => _client.rpc(
        'team_create',
        params: {
          'p_token': token,
          'p_username': username,
          'p_name': name,
          'p_password': password,
          'p_role': role.name,
        },
      ),
    );
  }

  Future<void> update(
    String token, {
    required String id,
    required String name,
    required TeamRole role,
    required bool isActive,
  }) async {
    await _call(
      () => _client.rpc(
        'team_update',
        params: {
          'p_token': token,
          'p_id': id,
          'p_name': name,
          'p_role': role.name,
          'p_is_active': isActive,
        },
      ),
    );
  }

  Future<void> setPassword(
    String token, {
    required String id,
    required String password,
  }) async {
    await _call(
      () => _client.rpc(
        'team_set_password',
        params: {'p_token': token, 'p_id': id, 'p_password': password},
      ),
    );
  }

  Future<void> delete(String token, {required String id}) async {
    await _call(
      () => _client.rpc('team_delete', params: {'p_token': token, 'p_id': id}),
    );
  }
}
