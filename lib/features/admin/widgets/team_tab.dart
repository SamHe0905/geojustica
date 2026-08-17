import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/team_member.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/team_provider.dart';
import '../../../repositories/team_repository.dart';

/// Aba de gestão da equipe. Só é montada quando o usuário logado é dono.
class TeamTab extends ConsumerWidget {
  const TeamTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(adminAuthProvider);
    final teamAsync = ref.watch(teamListProvider);
    final currentId = auth.member?.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openMemberForm(context, ref),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Novo membro'),
      ),
      body: teamAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _errorBox(context, ref, e),
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('Nenhum membro cadastrado.'));
          }
          final active = members.where((m) => m.isActive).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _statBox('${members.length}', 'Contas',
                        AppColors.primary, Icons.groups_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statBox('$active', 'Ativas', AppColors.success,
                        Icons.verified_user_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...members.map((m) => _memberCard(context, ref, m, currentId)),
            ],
          );
        },
      ),
    );
  }

  Widget _errorBox(BuildContext context, WidgetRef ref, Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text('$e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(teamListProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _memberCard(
      BuildContext context, WidgetRef ref, TeamMember m, String? currentId) {
    final isMe = m.id == currentId;
    final roleColor = m.isOwner ? AppColors.accent : AppColors.secondary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (m.isActive ? roleColor : AppColors.textMuted)
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                m.isOwner ? Icons.shield_rounded : Icons.person_rounded,
                color: m.isActive ? roleColor : AppColors.textMuted,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          m.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        const Text('(você)',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w700)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('@${m.username}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _chip(m.role.label, roleColor),
                      if (!m.isActive) _chip('Desativado', AppColors.textMuted),
                      if (m.lastLoginAt != null)
                        _chip('Entrou em ${_formatDate(m.lastLoginAt!)}',
                            AppColors.textMuted),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (action) async {
                switch (action) {
                  case 'edit':
                    await _openMemberForm(context, ref, existing: m);
                  case 'password':
                    await _openPasswordDialog(context, ref, m);
                  case 'delete':
                    await _confirmDelete(context, ref, m);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_rounded, size: 20),
                    title: Text('Editar'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'password',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.key_rounded, size: 20),
                    title: Text('Trocar senha'),
                  ),
                ),
                if (!isMe)
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline_rounded,
                          size: 20, color: AppColors.error),
                      title: Text('Remover',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ============== AÇÕES ==============

  Future<void> _openMemberForm(BuildContext context, WidgetRef ref,
      {TeamMember? existing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _MemberFormDialog(existing: existing),
    );
    if (saved == true) {
      ref.invalidate(teamListProvider);
      // O dono pode ter renomeado a si mesmo.
      await ref.read(adminAuthProvider.notifier).refreshMember();
    }
  }

  Future<void> _openPasswordDialog(
      BuildContext context, WidgetRef ref, TeamMember m) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => _PasswordDialog(member: m),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, TeamMember m) async {
    // Capturado antes do await: depois do diálogo o context pode não valer mais.
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.warning_amber_rounded,
            color: AppColors.error, size: 40),
        title: const Text('Remover membro'),
        content: Text(
            '${m.name} (@${m.username}) perde o acesso ao painel imediatamente. '
            'Se preferir guardar o histórico, use "Editar" e desative a conta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final token = ref.read(adminAuthProvider).token;
    if (token == null) return;

    try {
      await ref.read(teamRepoProvider).delete(token, id: m.id);
      ref.invalidate(teamListProvider);
      messenger.showSnackBar(
        SnackBar(content: Text('${m.name} foi removido.')),
      );
    } on TeamException catch (e) {
      messenger.showSnackBar(
        SnackBar(
            content: Text(e.message), backgroundColor: AppColors.error),
      );
    }
  }
}

// ============================================================
// DIÁLOGO: criar / editar membro
// ============================================================

class _MemberFormDialog extends ConsumerStatefulWidget {
  final TeamMember? existing;
  const _MemberFormDialog({this.existing});

  @override
  ConsumerState<_MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends ConsumerState<_MemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _username;
  final _password = TextEditingController();

  late TeamRole _role;
  late bool _isActive;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    _name = TextEditingController(text: m?.name ?? '');
    _username = TextEditingController(text: m?.username ?? '');
    _role = m?.role ?? TeamRole.membro;
    _isActive = m?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final token = ref.read(adminAuthProvider).token;
    if (token == null) {
      setState(() => _error = 'Sessão expirada. Entre novamente.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final repo = ref.read(teamRepoProvider);
      if (_isEdit) {
        await repo.update(
          token,
          id: widget.existing!.id,
          name: _name.text.trim(),
          role: _role,
          isActive: _isActive,
        );
      } else {
        await repo.create(
          token,
          username: _username.text.trim(),
          name: _name.text.trim(),
          password: _password.text,
          role: _role,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on TeamException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(_isEdit ? 'Editar membro' : 'Novo membro'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo *',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe o nome.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _username,
                  enabled: !_isEdit,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Usuário *',
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                    helperText: _isEdit
                        ? 'O usuário não pode ser alterado.'
                        : 'Minúsculas, números, ponto, hífen ou underline.',
                    helperMaxLines: 2,
                  ),
                  validator: (v) {
                    if (_isEdit) return null;
                    final u = (v ?? '').trim().toLowerCase();
                    if (!RegExp(r'^[a-z0-9._-]{3,32}$').hasMatch(u)) {
                      return 'De 3 a 32 caracteres, sem espaços nem acentos.';
                    }
                    return null;
                  },
                ),
                if (!_isEdit) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha inicial *',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                      helperText: 'Mínimo de 6 caracteres.',
                    ),
                    validator: (v) => (v ?? '').length < 6
                        ? 'Pelo menos 6 caracteres.'
                        : null,
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<TeamRole>(
                  initialValue: _role,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Papel',
                    prefixIcon: Icon(Icons.security_rounded),
                  ),
                  items: TeamRole.values
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text('${r.label} — ${r.description}',
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _role = v);
                  },
                ),
                if (_isEdit) ...[
                  const SizedBox(height: 4),
                  SwitchListTile(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    title: const Text('Conta ativa'),
                    subtitle: const Text(
                        'Ao desativar, as sessões abertas são encerradas.'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          color: AppColors.error, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving
              ? 'Salvando...'
              : (_isEdit ? 'Salvar' : 'Criar membro')),
        ),
      ],
    );
  }
}

// ============================================================
// DIÁLOGO: trocar senha
// ============================================================

class _PasswordDialog extends ConsumerStatefulWidget {
  final TeamMember member;
  const _PasswordDialog({required this.member});

  @override
  ConsumerState<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends ConsumerState<_PasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final token = ref.read(adminAuthProvider).token;
    if (token == null) {
      setState(() => _error = 'Sessão expirada. Entre novamente.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(teamRepoProvider)
          .setPassword(token, id: widget.member.id, password: _password.text);
      if (!mounted) return;
      Navigator.pop(context, true);
      messenger.showSnackBar(
        SnackBar(content: Text('Senha de ${widget.member.name} atualizada.')),
      );
    } on TeamException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Trocar senha'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Definindo nova senha para @${widget.member.username}.',
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              TextFormField(
                controller: _password,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nova senha *',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
                validator: (v) =>
                    (v ?? '').length < 6 ? 'Pelo menos 6 caracteres.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Repetir a senha *',
                  prefixIcon: Icon(Icons.lock_reset_rounded),
                ),
                validator: (v) =>
                    v != _password.text ? 'As senhas não conferem.' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: const TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Salvando...' : 'Trocar senha'),
        ),
      ],
    );
  }
}
