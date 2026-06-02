import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report.dart';
import '../repositories/report_repository.dart';

final reportRepositoryProvider = Provider((ref) => ReportRepository());

final reportListProvider = StateNotifierProvider<ReportListNotifier, List<Report>>(
  (ref) => ReportListNotifier(ref.watch(reportRepositoryProvider)),
);

class ReportListNotifier extends StateNotifier<List<Report>> {
  final ReportRepository _repo;
  ReportListNotifier(this._repo) : super(_repo.getAll());

  void submit(Report report) {
    _repo.add(report);
    state = _repo.getAll();
  }
}
