import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/subcategory.dart';
import '../../../providers/flow_provider.dart';

/// Banner que mostra documentos necessários e dica rápida da sub-categoria
class RequiredDocsBanner extends ConsumerStatefulWidget {
  const RequiredDocsBanner({super.key});

  @override
  ConsumerState<RequiredDocsBanner> createState() => _RequiredDocsBannerState();
}

class _RequiredDocsBannerState extends ConsumerState<RequiredDocsBanner> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(flowProvider);
    final cat = flow.category;
    final subId = flow.subcategoryId;
    if (cat == null || subId == null) return const SizedBox.shrink();

    final subs = SubcategoryRegistry.get(cat);
    Subcategory? sub;
    for (final s in subs) {
      if (s.id == subId) {
        sub = s;
        break;
      }
    }
    if (sub == null) return const SizedBox.shrink();

    final hasDocs = sub.requiredDocs?.isNotEmpty ?? false;
    final hasTip = sub.quickTip != null;
    if (!hasDocs && !hasTip) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.checklist_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Você vai precisar de…',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasDocs)
                    ...sub.requiredDocs!.map((d) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 16, color: AppColors.success),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(d,
                                    style: const TextStyle(
                                        fontSize: 13, height: 1.4)),
                              ),
                            ],
                          ),
                        )),
                  if (hasTip) ...[
                    if (hasDocs) const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_rounded,
                              size: 16, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              sub.quickTip!,
                              style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
