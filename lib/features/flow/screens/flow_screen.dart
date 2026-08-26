import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/flow_state.dart';
import '../../../providers/flow_provider.dart';
import '../../../services/location_service.dart';
import '../../../shared/widgets/geo_app_bar.dart';

/// Passos possíveis do fluxo guiado.
/// - [intent] só aparece para categorias que envolvem litígio (pagar advogado);
///   ali a pessoa escolhe entre "só quero informação" e "quero resolver o caso".
/// - [payment] só aparece quando a pessoa escolheu resolver o caso.
/// - [location] é o passo final, sempre presente.
enum _FlowStep { intent, payment, location }

class FlowScreen extends ConsumerStatefulWidget {
  const FlowScreen({super.key});

  @override
  ConsumerState<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends ConsumerState<FlowScreen> {
  _FlowStep _step = _FlowStep.intent;
  final _neighborhoodController = TextEditingController();
  bool _loadingGps = false;

  @override
  void initState() {
    super.initState();
    // Categorias que não envolvem pagar advogado pulam intenção e pagamento,
    // indo direto para a localização.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final flow = ref.read(flowProvider);
      if (flow.category != null && !flow.category!.requiresPaymentQuestion) {
        setState(() => _step = _FlowStep.location);
      }
    });
  }

  @override
  void dispose() {
    _neighborhoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(flowProvider);
    final needsGuided = flow.category?.requiresPaymentQuestion ?? true;

    Widget content;
    if (needsGuided && _step == _FlowStep.intent) {
      content = _buildIntentStep(context);
    } else if (needsGuided && _step == _FlowStep.payment) {
      content = _buildPaymentStep(context);
    } else {
      content = _buildLocationStep(context, hasGuidedSteps: needsGuided);
    }

    return Scaffold(
      appBar: GeoAppBar(title: flow.category?.label ?? 'Orientação'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? constraints.maxWidth * 0.2 : 24,
                vertical: 32,
              ),
              child: content,
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Passo 1: intenção ("só informação" vs "resolver o caso")
  // ---------------------------------------------------------------------------

  Widget _buildIntentStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepIndicator(0),
        const SizedBox(height: 32),
        Text(
          AppStrings.intentQuestion,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Assim mostramos o caminho mais direto para você.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        _optionCard(
          context,
          title: AppStrings.intentInfo,
          subtitle: AppStrings.intentInfoHint,
          icon: Icons.info_outline_rounded,
          color: AppColors.secondary,
          onTap: () {
            ref.read(flowProvider.notifier).setIntent(FlowIntent.info);
            setState(() => _step = _FlowStep.location);
          },
        ),
        const SizedBox(height: 12),
        _optionCard(
          context,
          title: AppStrings.intentResolve,
          subtitle: AppStrings.intentResolveHint,
          icon: Icons.gavel_rounded,
          color: AppColors.primary,
          onTap: () {
            ref.read(flowProvider.notifier).setIntent(FlowIntent.resolve);
            setState(() => _step = _FlowStep.payment);
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Passo 2 (só quem quer resolver): consegue pagar advogado?
  // ---------------------------------------------------------------------------

  Widget _buildPaymentStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepIndicator(1),
        const SizedBox(height: 32),
        Text(
          AppStrings.paymentQuestion,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Isso nos ajuda a indicar os lugares certos para você.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        _paymentOption(
          context,
          AppStrings.paymentYes,
          Icons.check_circle_outline,
          PaymentAbility.yes,
          AppColors.secondary,
        ),
        const SizedBox(height: 12),
        _paymentOption(
          context,
          AppStrings.paymentNo,
          Icons.money_off_rounded,
          PaymentAbility.no,
          AppColors.success,
        ),
        const SizedBox(height: 12),
        _paymentOption(
          context,
          AppStrings.paymentUnsure,
          Icons.help_outline_rounded,
          PaymentAbility.unsure,
          AppColors.warning,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _step = _FlowStep.intent),
          child: const Text('← Voltar'),
        ),
      ],
    );
  }

  Widget _paymentOption(
    BuildContext context,
    String label,
    IconData icon,
    PaymentAbility ability,
    Color color,
  ) {
    return _optionCard(
      context,
      title: label,
      icon: icon,
      color: color,
      onTap: () {
        ref.read(flowProvider.notifier).setPaymentAbility(ability);
        setState(() => _step = _FlowStep.location);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Passo final: localização
  // ---------------------------------------------------------------------------

  Widget _buildLocationStep(
    BuildContext context, {
    bool hasGuidedSteps = true,
  }) {
    final flow = ref.read(flowProvider);
    // Total de passos com indicador: intenção + (pagamento, se resolver) + local.
    final showIndicator = hasGuidedSteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showIndicator) _buildStepIndicator(_locationIndicatorStep(flow)),
        if (showIndicator)
          const SizedBox(height: 32)
        else
          const SizedBox(height: 8),
        Text(
          AppStrings.locationQuestion,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Assim mostramos as instituições mais perto de você.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        _locationOption(
          context,
          AppStrings.locationGps,
          Icons.my_location_rounded,
          AppColors.primary,
          _loadingGps ? null : _onUseGps,
          trailing: _loadingGps
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
        const SizedBox(height: 20),
        Text(
          'ou',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _neighborhoodController,
          decoration: const InputDecoration(
            hintText: 'Digite seu bairro',
            prefixIcon: Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _onTypeNeighborhood(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _onTypeNeighborhood,
          child: const Text('Buscar por bairro'),
        ),
        if (hasGuidedSteps) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () =>
                setState(() => _step = _backStepFromLocation(flow)),
            child: const Text('← Voltar'),
          ),
        ],
      ],
    );
  }

  /// De onde a localização "voltar" deve retornar: para quem escolheu resolver
  /// o caso, volta ao pagamento; para quem só quer informação, volta à intenção.
  _FlowStep _backStepFromLocation(FlowState flow) =>
      flow.intent == FlowIntent.resolve ? _FlowStep.payment : _FlowStep.intent;

  /// Posição do passo de localização no indicador (2 passos para "info",
  /// 3 passos para "resolver").
  int _locationIndicatorStep(FlowState flow) =>
      flow.intent == FlowIntent.resolve ? 2 : 1;

  Widget _locationOption(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback? onTap, {
    Widget? trailing,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Componentes compartilhados
  // ---------------------------------------------------------------------------

  /// Card de opção genérico (usado por intenção e pagamento). O [subtitle] é
  /// opcional para dar contexto extra na pergunta de intenção.
  Widget _optionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int activeStep) {
    // 2 passos para "só informação" (intenção + local), 3 para "resolver"
    // (intenção + pagamento + local). Fora do fluxo com litígio não aparece.
    final total = ref.read(flowProvider).intent == FlowIntent.resolve ? 3 : 2;
    return Row(
      children: List.generate(total, (i) {
        final active = i <= activeStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < total - 1 ? 8 : 0),
            height: 6,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Ações de localização
  // ---------------------------------------------------------------------------

  Future<void> _onUseGps() async {
    setState(() => _loadingGps = true);
    final locationService = LocationService();
    final pos = await locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() => _loadingGps = false);

    if (pos != null) {
      ref
          .read(flowProvider.notifier)
          .setGpsLocation(pos.latitude, pos.longitude);
      context.push(AppRoutes.results);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível obter sua localização. Tente digitar seu bairro.',
          ),
        ),
      );
    }
  }

  void _onTypeNeighborhood() {
    final text = _neighborhoodController.text.trim();
    if (text.isEmpty) return;
    ref.read(flowProvider.notifier).setNeighborhood(text);
    context.push(AppRoutes.results);
  }
}
