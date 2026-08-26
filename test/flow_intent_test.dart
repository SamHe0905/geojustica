import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geojustica/models/flow_state.dart';
import 'package:geojustica/models/institution.dart';
import 'package:geojustica/providers/flow_provider.dart';

/// Regra do filtro em institutionsByFlowProvider: só filtra por gratuidade
/// quando a pessoa respondeu que NÃO consegue pagar advogado.
bool _onlyFree(FlowState s) => s.paymentAbility == PaymentAbility.no;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('setIntent(info) marca intenção e não deixa filtro de gratuidade', () {
    final n = FlowNotifier();
    n.reset();
    n.setCategory(InstitutionCategory.trabalho);
    // Passagem anterior pelo fluxo pode ter deixado "preciso gratuito".
    n.setPaymentAbility(PaymentAbility.no);
    expect(_onlyFree(n.state), isTrue);

    // Escolher "só quero informação" precisa zerar esse filtro.
    n.setIntent(FlowIntent.info);
    expect(n.state.intent, FlowIntent.info);
    expect(n.state.paymentAbility, isNull);
    expect(_onlyFree(n.state), isFalse);
  });

  test('setIntent(resolve) preserva o fluxo de pagamento', () {
    final n = FlowNotifier();
    n.reset();
    n.setCategory(InstitutionCategory.trabalho);
    n.setIntent(FlowIntent.resolve);
    n.setPaymentAbility(PaymentAbility.no);

    expect(n.state.intent, FlowIntent.resolve);
    expect(n.state.paymentAbility, PaymentAbility.no);
    expect(_onlyFree(n.state), isTrue);
  });

  test('intent salvo é recarregado no boot (_load)', () async {
    SharedPreferences.setMockInitialValues({
      'flow_state_category': 'familia',
      'flow_state_intent': 'info',
    });
    final n = FlowNotifier();
    // _load é assíncrono no construtor.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(n.state.category, InstitutionCategory.familia);
    expect(n.state.intent, FlowIntent.info);
  });

  test('categorias de litígio pedem a pergunta de pagamento', () {
    for (final c in [
      InstitutionCategory.familia,
      InstitutionCategory.trabalho,
      InstitutionCategory.consumidor,
      InstitutionCategory.moradia,
      InstitutionCategory.aposentadoria,
    ]) {
      expect(c.requiresPaymentQuestion, isTrue, reason: c.name);
    }
    // Emergência/administrativo/saúde não perguntam pagamento.
    for (final c in [
      InstitutionCategory.violenciaDomestica,
      InstitutionCategory.direitosMulher,
      InstitutionCategory.documentos,
      InstitutionCategory.saude,
      InstitutionCategory.denuncias,
      InstitutionCategory.outros,
    ]) {
      expect(c.requiresPaymentQuestion, isFalse, reason: c.name);
    }
  });
}
