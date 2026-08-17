enum TeamRole {
  dono,
  membro;

  String get label {
    switch (this) {
      case dono:
        return 'Dono';
      case membro:
        return 'Membro';
    }
  }

  String get description {
    switch (this) {
      case dono:
        return 'Gerencia a equipe e edita tudo.';
      case membro:
        return 'Edita órgãos e denúncias, mas não mexe na equipe.';
    }
  }

  static TeamRole fromString(String? value) =>
      value == 'dono' ? TeamRole.dono : TeamRole.membro;
}

class TeamMember {
  final String id;
  final String username;
  final String name;
  final TeamRole role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const TeamMember({
    required this.id,
    required this.username,
    required this.name,
    this.role = TeamRole.membro,
    this.isActive = true,
    this.createdAt,
    this.lastLoginAt,
  });

  bool get isOwner => role == TeamRole.dono;

  factory TeamMember.fromMap(Map<String, dynamic> map) => TeamMember(
        id: map['id']?.toString() ?? '',
        username: map['username'] ?? '',
        name: map['name'] ?? '',
        role: TeamRole.fromString(map['role']?.toString()),
        isActive: map['is_active'] ?? true,
        createdAt: _parseDate(map['created_at']),
        lastLoginAt: _parseDate(map['last_login_at']),
      );

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}

/// Sessão ativa do painel: o token guardado no navegador + quem é o dono dele.
class AdminSession {
  final String token;
  final TeamMember member;

  const AdminSession({required this.token, required this.member});

  factory AdminSession.fromMap(Map<String, dynamic> map) => AdminSession(
        token: map['token']?.toString() ?? '',
        member: TeamMember.fromMap(map),
      );
}
