import '../models/report.dart';

class ReportRepository {
  // Em memória por enquanto - quando ligar ao Supabase, persistência real.
  static final List<Report> _reports = [];

  List<Report> getAll() =>
      List.from(_reports.reversed); // mais recentes primeiro

  List<Report> getByInstitution(String institutionId) =>
      _reports.where((r) => r.institutionId == institutionId).toList();

  void add(Report report) => _reports.add(report);

  int get totalCount => _reports.length;

  int countByStatus(ReportStatus status) =>
      _reports.where((r) => r.status == status).length;
}
