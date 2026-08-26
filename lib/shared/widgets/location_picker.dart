import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/flow_provider.dart';
import '../../services/location_service.dart';
import 'geo_icon.dart';

/// Abre o seletor de localização (GPS ou bairro). O valor escolhido é salvo no
/// [flowProvider] e persiste entre buscas — definido uma vez, reaproveitado.
Future<void> showLocationPicker(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _LocationSheet(parentRef: ref),
  );
}

class _LocationSheet extends StatefulWidget {
  final WidgetRef parentRef;
  const _LocationSheet({required this.parentRef});

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  final _controller = TextEditingController();
  bool _loadingGps = false;

  @override
  void initState() {
    super.initState();
    _controller.text =
        widget.parentRef.read(flowProvider).neighborhoodInput ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _useGps() async {
    setState(() => _loadingGps = true);
    final pos = await LocationService().getCurrentLocation();
    if (!mounted) return;
    setState(() => _loadingGps = false);
    if (pos != null) {
      widget.parentRef
          .read(flowProvider.notifier)
          .setGpsLocation(pos.latitude, pos.longitude);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível obter sua localização. Digite seu bairro.'),
        ),
      );
    }
  }

  void _saveNeighborhood() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.parentRef.read(flowProvider.notifier).setNeighborhood(text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Onde você está?',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Definimos uma vez e usamos nas próximas buscas.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _loadingGps ? null : _useGps,
            icon: _loadingGps
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
            label: Text(_loadingGps ? 'Localizando…' : 'Usar minha localização'),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('ou', style: TextStyle(color: AppColors.textMuted)),
            ),
            const Expanded(child: Divider()),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: false,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Digite seu bairro',
              prefixIcon: Icon(Icons.location_on_rounded, color: AppColors.primary),
            ),
            onSubmitted: (_) => _saveNeighborhood(),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saveNeighborhood,
            child: const Text('Salvar bairro'),
          ),
        ],
      ),
    );
  }
}

/// Chip na home para definir/trocar a localização uma vez.
class LocationChip extends ConsumerWidget {
  const LocationChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = ref.watch(flowProvider).locationLabel;
    final hasLoc = label != null;

    return Material(
      color: hasLoc ? AppColors.forestTint : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showLocationPicker(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasLoc ? AppColors.primary.withValues(alpha: 0.25) : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              GeoIcon('pin', color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasLoc ? 'Sua localização' : 'Definir minha localização',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      hasLoc ? label : 'Toque para usar GPS ou digitar o bairro',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                hasLoc ? 'Trocar' : 'Definir',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
