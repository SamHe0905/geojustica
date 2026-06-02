import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/institution_provider.dart';
import '../../../shared/widgets/geo_app_bar.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final allAsync = ref.watch(allInstitutionsProvider);

    return Scaffold(
      appBar: GeoAppBar(
        title: 'Histórico',
        actions: [
          if (history.visitedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
              tooltip: 'Limpar',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Limpar histórico?'),
                    content: const Text(
                        'Isso vai remover todas as instituições visitadas e avaliações.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Limpar',
                              style: TextStyle(color: AppColors.error))),
                    ],
                  ),
                );
                if (confirm == true) ref.read(historyProvider.notifier).clear();
              },
            ),
        ],
      ),
      body: allAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (all) {
          if (history.visitedIds.isEmpty) {
            return _buildEmpty(context);
          }
          final visited = history.visitedIds
              .map((id) => all.firstWhere(
                    (i) => i.id == id,
                    orElse: () => all.first,
                  ))
              .toSet()
              .toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: visited.length,
            itemBuilder: (_, i) {
              final inst = visited[i];
              final rating = history.ratings[inst.id];
              return Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.history_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  title: Text(inst.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${inst.category.label} • ${inst.neighborhood}'),
                  trailing: rating != null
                      ? Icon(
                          rating > 0
                              ? Icons.thumb_up_rounded
                              : Icons.thumb_down_rounded,
                          color: rating > 0 ? AppColors.success : AppColors.error,
                          size: 18,
                        )
                      : null,
                  onTap: () => context.push('/instituicao/${inst.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle),
            child: const Icon(Icons.history_rounded,
                size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text('Nenhuma instituição visitada ainda',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 6),
          const Text('As instituições que você acessar aparecem aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
