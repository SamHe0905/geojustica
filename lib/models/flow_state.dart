import 'institution.dart';

enum PaymentAbility { yes, no, unsure }

/// O que a pessoa precisa agora: só informação (onde ir, documentos, contato)
/// ou resolver o caso (aí sim faz sentido perguntar sobre pagar advogado).
enum FlowIntent { info, resolve }

class FlowState {
  final InstitutionCategory? category;
  final String? subcategoryId;
  final FlowIntent? intent;
  final PaymentAbility? paymentAbility;
  final double? userLatitude;
  final double? userLongitude;
  final String? neighborhoodInput;

  const FlowState({
    this.category,
    this.subcategoryId,
    this.intent,
    this.paymentAbility,
    this.userLatitude,
    this.userLongitude,
    this.neighborhoodInput,
  });

  bool get hasLocation => userLatitude != null && userLongitude != null;

  FlowState copyWith({
    InstitutionCategory? category,
    String? subcategoryId,
    FlowIntent? intent,
    PaymentAbility? paymentAbility,
    double? userLatitude,
    double? userLongitude,
    String? neighborhoodInput,
  }) => FlowState(
    category: category ?? this.category,
    subcategoryId: subcategoryId ?? this.subcategoryId,
    intent: intent ?? this.intent,
    paymentAbility: paymentAbility ?? this.paymentAbility,
    userLatitude: userLatitude ?? this.userLatitude,
    userLongitude: userLongitude ?? this.userLongitude,
    neighborhoodInput: neighborhoodInput ?? this.neighborhoodInput,
  );
}
