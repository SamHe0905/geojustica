import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flow_state.dart';
import '../models/institution.dart';

final flowProvider = StateNotifierProvider<FlowNotifier, FlowState>(
  (ref) => FlowNotifier(),
);

class FlowNotifier extends StateNotifier<FlowState> {
  static const _key = 'flow_state';

  FlowNotifier() : super(const FlowState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final categoryName = prefs.getString('${_key}_category');
    if (categoryName == null) return;

    final cat = InstitutionCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => InstitutionCategory.outros,
    );
    final payment = prefs.getString('${_key}_payment');
    final intent = prefs.getString('${_key}_intent');
    final lat = prefs.getDouble('${_key}_lat');
    final lng = prefs.getDouble('${_key}_lng');
    final neighborhood = prefs.getString('${_key}_neighborhood');
    final subId = prefs.getString('${_key}_sub');

    state = FlowState(
      category: cat,
      subcategoryId: subId,
      intent: intent != null
          ? FlowIntent.values.firstWhere(
              (i) => i.name == intent,
              orElse: () => FlowIntent.resolve,
            )
          : null,
      paymentAbility: payment != null
          ? PaymentAbility.values.firstWhere(
              (p) => p.name == payment,
              orElse: () => PaymentAbility.unsure,
            )
          : null,
      userLatitude: lat,
      userLongitude: lng,
      neighborhoodInput: neighborhood,
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (state.category != null) {
      await prefs.setString('${_key}_category', state.category!.name);
    } else {
      await prefs.remove('${_key}_category');
    }
    if (state.subcategoryId != null) {
      await prefs.setString('${_key}_sub', state.subcategoryId!);
    } else {
      await prefs.remove('${_key}_sub');
    }
    if (state.intent != null) {
      await prefs.setString('${_key}_intent', state.intent!.name);
    } else {
      await prefs.remove('${_key}_intent');
    }
    if (state.paymentAbility != null) {
      await prefs.setString('${_key}_payment', state.paymentAbility!.name);
    } else {
      await prefs.remove('${_key}_payment');
    }
    if (state.userLatitude != null) {
      await prefs.setDouble('${_key}_lat', state.userLatitude!);
    } else {
      await prefs.remove('${_key}_lat');
    }
    if (state.userLongitude != null) {
      await prefs.setDouble('${_key}_lng', state.userLongitude!);
    } else {
      await prefs.remove('${_key}_lng');
    }
    if (state.neighborhoodInput != null) {
      await prefs.setString('${_key}_neighborhood', state.neighborhoodInput!);
    } else {
      await prefs.remove('${_key}_neighborhood');
    }
  }

  void setCategory(InstitutionCategory category) {
    state = state.copyWith(category: category);
    _persist();
  }

  void setSubcategory(String subcategoryId) {
    state = state.copyWith(subcategoryId: subcategoryId);
    _persist();
  }

  void setIntent(FlowIntent intent) {
    // "Só quero informação" nunca filtra por gratuidade: zera a resposta de
    // pagamento pra não sobrar um filtro de uma passagem anterior pelo fluxo.
    if (intent == FlowIntent.info) {
      state = FlowState(
        category: state.category,
        subcategoryId: state.subcategoryId,
        intent: FlowIntent.info,
        paymentAbility: null,
        userLatitude: state.userLatitude,
        userLongitude: state.userLongitude,
        neighborhoodInput: state.neighborhoodInput,
      );
    } else {
      state = state.copyWith(intent: intent);
    }
    _persist();
  }

  void setPaymentAbility(PaymentAbility ability) {
    state = state.copyWith(paymentAbility: ability);
    _persist();
  }

  void setGpsLocation(double lat, double lng) {
    state = state.copyWith(userLatitude: lat, userLongitude: lng);
    _persist();
  }

  void setNeighborhood(String neighborhood) {
    state = state.copyWith(neighborhoodInput: neighborhood);
    _persist();
  }

  /// Limpa a consulta (categoria/intenção/pagamento) MAS preserva a localização
  /// do usuário — ela é uma preferência que vale entre buscas, não algo para
  /// reperguntar a cada categoria escolhida.
  void reset() {
    state = FlowState(
      userLatitude: state.userLatitude,
      userLongitude: state.userLongitude,
      neighborhoodInput: state.neighborhoodInput,
    );
    _persist();
  }

  /// Esquece a localização salva (usado quando a pessoa toca em "trocar").
  void clearLocation() {
    state = FlowState(
      category: state.category,
      subcategoryId: state.subcategoryId,
      intent: state.intent,
      paymentAbility: state.paymentAbility,
    );
    _persist();
  }
}
