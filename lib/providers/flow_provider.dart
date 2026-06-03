import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flow_state.dart';
import '../models/institution.dart';

final flowProvider = StateNotifierProvider<FlowNotifier, FlowState>((ref) => FlowNotifier());

class FlowNotifier extends StateNotifier<FlowState> {
  FlowNotifier() : super(const FlowState());

  void setCategory(InstitutionCategory category) =>
      state = state.copyWith(category: category);

  void setSubcategory(String subcategoryId) =>
      state = state.copyWith(subcategoryId: subcategoryId);

  void setPaymentAbility(PaymentAbility ability) =>
      state = state.copyWith(paymentAbility: ability);

  void setGpsLocation(double lat, double lng) =>
      state = state.copyWith(userLatitude: lat, userLongitude: lng);

  void setNeighborhood(String neighborhood) =>
      state = state.copyWith(neighborhoodInput: neighborhood);

  void reset() => state = const FlowState();
}
