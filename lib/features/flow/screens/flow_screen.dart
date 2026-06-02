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

class FlowScreen extends ConsumerStatefulWidget {
  const FlowScreen({super.key});

  @override
  ConsumerState<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends ConsumerState<FlowScreen> {
  int _step = 0; // 0 = payment, 1 = location
  final _neighborhoodController = TextEditingController();
  bool _loadingGps = false;

  @override
  void dispose() {
    _neighborhoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(flowProvider);
    return Scaffold(
      appBar: GeoAppBar(title: flow.category?.label ?? 'Orientação'),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? constraints.maxWidth * 0.2 : 24,
              vertical: 32,
            ),
            child: _step == 0 ? _buildPaymentStep(context) : _buildLocationStep(context),
          );
        }),
      ),
    );
  }

  Widget _buildPaymentStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepIndicator(0),
        const SizedBox(height: 32),
        Text(
          AppStrings.paymentQuestion,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Isso nos ajuda a indicar os lugares certos para você.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        _paymentOption(context, AppStrings.paymentYes, Icons.check_circle_outline, PaymentAbility.yes, AppColors.secondary),
        const SizedBox(height: 12),
        _paymentOption(context, AppStrings.paymentNo, Icons.money_off_rounded, PaymentAbility.no, AppColors.success),
        const SizedBox(height: 12),
        _paymentOption(context, AppStrings.paymentUnsure, Icons.help_outline_rounded, PaymentAbility.unsure, AppColors.warning),
      ],
    );
  }

  Widget _paymentOption(
    BuildContext context, String label, IconData icon, PaymentAbility ability, Color color) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ref.read(flowProvider.notifier).setPaymentAbility(ability);
          setState(() => _step = 1);
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepIndicator(1),
        const SizedBox(height: 32),
        Text(
          AppStrings.locationQuestion,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Assim mostramos as instituições mais perto de você.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        _locationOption(
          context,
          AppStrings.locationGps,
          Icons.my_location_rounded,
          AppColors.primary,
          _loadingGps ? null : _onUseGps,
          trailing: _loadingGps
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : null,
        ),
        const SizedBox(height: 20),
        Text(
          'ou',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _neighborhoodController,
          decoration: const InputDecoration(
            hintText: 'Digite seu bairro',
            prefixIcon: Icon(Icons.location_on_rounded, color: AppColors.primary),
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
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _step = 0),
          child: const Text('← Voltar'),
        ),
      ],
    );
  }

  Widget _locationOption(
    BuildContext context, String label, IconData icon, Color color, VoidCallback? onTap,
    {Widget? trailing}) {
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
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
              trailing ?? Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int activeStep) {
    return Row(
      children: List.generate(2, (i) {
        final active = i <= activeStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 1 ? 8 : 0),
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

  Future<void> _onUseGps() async {
    setState(() => _loadingGps = true);
    final locationService = LocationService();
    final pos = await locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() => _loadingGps = false);

    if (pos != null) {
      ref.read(flowProvider.notifier).setGpsLocation(pos.latitude, pos.longitude);
      context.push(AppRoutes.results);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível obter sua localização. Tente digitar seu bairro.')),
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
