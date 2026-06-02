import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/report.dart';

class ReportRepository {
  // Cache local em memória (fallback se Supabase falhar)
  static final List<Report> _localCache = [];

  SupabaseClient? get _client {
    if (!SupabaseConfig.useSupabase) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<Report>> getAll() async {
    final client = _client;
    if (client == null) return List.from(_localCache.reversed);
    try {
      final response = await client
          .from('reports')
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((e) => _fromRow(e)).toList();
    } catch (_) {
      return List.from(_localCache.reversed);
    }
  }

  Future<void> add(Report report) async {
    final client = _client;
    if (client != null) {
      try {
        await client.from('reports').insert({
          'institution_id': report.institutionId,
          'institution_name': report.institutionName,
          'type': report.type.name,
          'description': report.description,
          'contact_name': report.contactName,
          'contact_phone': report.contactPhone,
          'anonymous': report.anonymous,
          'status': report.status.name,
        });
        return;
      } catch (_) {
        // fallback local
      }
    }
    _localCache.add(report);
  }

  Report _fromRow(Map<String, dynamic> row) {
    return Report(
      id: row['id'].toString(),
      institutionId: row['institution_id'] ?? '',
      institutionName: row['institution_name'] ?? '',
      type: ReportType.values.firstWhere(
        (t) => t.name == row['type'],
        orElse: () => ReportType.outros,
      ),
      description: row['description'] ?? '',
      contactName: row['contact_name'],
      contactPhone: row['contact_phone'],
      anonymous: row['anonymous'] ?? true,
      status: ReportStatus.values.firstWhere(
        (s) => s.name == row['status'],
        orElse: () => ReportStatus.pendente,
      ),
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'])
          : DateTime.now(),
    );
  }
}
