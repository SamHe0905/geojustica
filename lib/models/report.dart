enum ReportType {
  maAtendimento,
  filaExcessiva,
  cobrancaIndevida,
  discriminacao,
  infraestrutura,
  recusaAtendimento,
  desinformacao,
  outros;

  String get label {
    switch (this) {
      case maAtendimento: return 'Mau atendimento';
      case filaExcessiva: return 'Fila ou demora excessiva';
      case cobrancaIndevida: return 'Cobrança indevida (serviço deve ser gratuito)';
      case discriminacao: return 'Discriminação';
      case infraestrutura: return 'Problemas de infraestrutura/acessibilidade';
      case recusaAtendimento: return 'Recusa de atendimento';
      case desinformacao: return 'Informação errada no app';
      case outros: return 'Outros';
    }
  }

  String get icon {
    switch (this) {
      case maAtendimento: return '😠';
      case filaExcessiva: return '⏳';
      case cobrancaIndevida: return '💰';
      case discriminacao: return '⚠️';
      case infraestrutura: return '🚧';
      case recusaAtendimento: return '🚫';
      case desinformacao: return '📝';
      case outros: return '📌';
    }
  }
}

enum ReportStatus { pendente, emAnalise, resolvido, arquivado }

class Report {
  final String id;
  final String institutionId;
  final String institutionName;
  final ReportType type;
  final String description;
  final String? contactName;
  final String? contactPhone;
  final bool anonymous;
  final DateTime createdAt;
  final ReportStatus status;

  Report({
    required this.id,
    required this.institutionId,
    required this.institutionName,
    required this.type,
    required this.description,
    this.contactName,
    this.contactPhone,
    this.anonymous = true,
    DateTime? createdAt,
    this.status = ReportStatus.pendente,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'institution_id': institutionId,
        'institution_name': institutionName,
        'type': type.name,
        'description': description,
        'contact_name': contactName,
        'contact_phone': contactPhone,
        'anonymous': anonymous,
        'created_at': createdAt.toIso8601String(),
        'status': status.name,
      };
}
