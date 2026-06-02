import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/institution.dart';
import '../models/flow_state.dart';
import '../repositories/local_institution_repository.dart';

final localRepoProvider = Provider((ref) => LocalInstitutionRepository());

final allInstitutionsProvider = FutureProvider<List<Institution>>((ref) async {
  return ref.watch(localRepoProvider).getAll();
});

final institutionsByFlowProvider = FutureProvider.family<List<Institution>, FlowState>(
  (ref, flowState) async {
    if (flowState.category == null) return [];
    final repo = ref.watch(localRepoProvider);
    final bool onlyFree = flowState.paymentAbility == PaymentAbility.no;
    LatLng? location;
    if (flowState.hasLocation) {
      location = LatLng(flowState.userLatitude!, flowState.userLongitude!);
    }
    return repo.getByCategory(
      flowState.category!,
      onlyFree: onlyFree,
      userLocation: location,
    );
  },
);

final institutionDetailProvider = FutureProvider.family<Institution?, String>((ref, id) async {
  return ref.watch(localRepoProvider).getById(id);
});
