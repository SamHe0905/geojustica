import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/geo_app_bar.dart';

/// Cadastro do primeiro responsável (dono) do painel. Só aparece enquanto o
/// sistema não tem nenhum dono ativo — substitui a antiga conta semeada com
/// senha fixa. Depois de criado, o acesso passa a ser sempre pela tela de login.
class AdminSetupScreen extends ConsumerStatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  ConsumerState<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends ConsumerState<AdminSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose();
    _nameCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final error = await ref
        .read(adminAuthProvider.notifier)
        .bootstrap(
          _userCtrl.text.trim(),
          _nameCtrl.text.trim(),
          _passCtrl.text,
        );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
    // Sucesso: o AdminGuard troca sozinho para o painel.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeoAppBar(title: 'Configuração inicial'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.forest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Crie o responsável do painel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Esta é a primeira configuração. A conta criada aqui será '
                      'a dona do painel e poderá cadastrar os demais membros.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Seu nome',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Informe seu nome.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _userCtrl,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        helperText:
                            '3 a 32 caracteres: letras minúsculas, números, . _ -',
                        helperMaxLines: 2,
                      ),
                      validator: (v) {
                        final user = (v ?? '').trim();
                        if (!RegExp(r'^[a-z0-9._-]{3,32}$').hasMatch(user)) {
                          return 'Usuário inválido. Use 3 a 32 caracteres '
                              'minúsculos, números, ponto, hífen ou underline.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'A senha precisa ter pelo menos 6 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscure,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Confirmar senha',
                        prefixIcon: Icon(Icons.lock_reset_rounded),
                      ),
                      validator: (v) => (v != _passCtrl.text)
                          ? 'As senhas não conferem.'
                          : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _submit,
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_rounded),
                      label: Text(_loading ? 'Criando...' : 'Criar conta'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: const Text('Voltar ao início'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
