import 'institution.dart';

enum PaymentAbility { yes, no, unsure }

class FlowState {
  final InstitutionCategory? category;
  final PaymentAbility? paymentAbility;
  final double? userLatitude;
  final double? userLongitude;
  final String? neighborhoodInput;

  const FlowState({
    this.category,
    this.paymentAbility,
    this.userLatitude,
    this.userLongitude,
    this.neighborhoodInput,
  });

  bool get hasLocation => userLatitude != null && userLongitude != null;

  FlowState copyWith({
    InstitutionCategory? category,
    PaymentAbility? paymentAbility,
    double? userLatitude,
    double? userLongitude,
    String? neighborhoodInput,
  }) =>
      FlowState(
        category: category ?? this.category,
        paymentAbility: paymentAbility ?? this.paymentAbility,
        userLatitude: userLatitude ?? this.userLatitude,
        userLongitude: userLongitude ?? this.userLongitude,
        neighborhoodInput: neighborhoodInput ?? this.neighborhoodInput,
      );
}
