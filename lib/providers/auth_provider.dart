import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Auth simples para painel admin.
/// Em produção real, substituir por Supabase Auth.
class AdminAuth {
  // Senha padrão. Em deploy real, mover para variável de ambiente.
  static const String _password = 'geojustica2026';
  static const String _storageKey = 'admin_authenticated';

  static bool verify(String input) => input == _password;
}

final adminAuthProvider =
    StateNotifierProvider<AdminAuthNotifier, bool>((_) => AdminAuthNotifier());

class AdminAuthNotifier extends StateNotifier<bool> {
  AdminAuthNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AdminAuth._storageKey) ?? false;
  }

  Future<bool> login(String password) async {
    if (!AdminAuth.verify(password)) return false;
    state = true;
    (await SharedPreferences.getInstance()).setBool(AdminAuth._storageKey, true);
    return true;
  }

  Future<void> logout() async {
    state = false;
    (await SharedPreferences.getInstance()).remove(AdminAuth._storageKey);
  }
}
