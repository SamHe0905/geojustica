import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report.dart';
import '../repositories/report_repository.dart';

final reportRepositoryProvider = Provider((ref) => ReportRepository());

final reportListProvider =
    StateNotifierProvider<ReportListNotifier, List<Report>>(
  (ref) => ReportListNotifier(ref.watch(reportRepositoryProvider)),
);

class ReportListNotifier extends StateNotifier<List<Report>> {
  final ReportRepository _repo;
  ReportListNotifier(this._repo) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.getAll();
  }

  Future<void> submit(Report report) async {
    await _repo.add(report);
    await _load();
  }

  Future<void> refresh() => _load();
}
