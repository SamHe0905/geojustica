import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/institution.dart';
import '../models/lawyer.dart';
import '../repositories/lawyer_repository.dart';

final lawyerRepoProvider = Provider((ref) => LawyerRepository());

class LawyerFilter {
  final InstitutionCategory? category;
  final bool onlyFree;
  final bool onlyVerified;
  const LawyerFilter({this.category, this.onlyFree = false, this.onlyVerified = false});

  LawyerFilter copyWith({InstitutionCategory? category, bool? onlyFree, bool? onlyVerified}) =>
      LawyerFilter(
        category: category ?? this.category,
        onlyFree: onlyFree ?? this.onlyFree,
        onlyVerified: onlyVerified ?? this.onlyVerified,
      );
}

final lawyerFilterProvider = StateProvider<LawyerFilter>((_) => const LawyerFilter());

final filteredLawyersProvider = Provider<List<Lawyer>>((ref) {
  final repo = ref.watch(lawyerRepoProvider);
  final filter = ref.watch(lawyerFilterProvider);
  return repo.filter(
    category: filter.category,
    onlyFree: filter.onlyFree,
    onlyVerified: filter.onlyVerified,
  );
});

final lawyerByIdProvider = Provider.family<Lawyer?, String>((ref, id) {
  return ref.watch(lawyerRepoProvider).getById(id);
});
