import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryState {
  final List<String> visitedIds;
  final Map<String, int> ratings; // institutionId -> 1 (up) | -1 (down)
  const HistoryState({this.visitedIds = const [], this.ratings = const {}});
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) => HistoryNotifier());

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(const HistoryState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final visited = prefs.getStringList('visitedIds') ?? [];
    final ratingKeys = prefs.getKeys().where((k) => k.startsWith('rating_'));
    final ratings = <String, int>{};
    for (final k in ratingKeys) {
      ratings[k.substring(7)] = prefs.getInt(k) ?? 0;
    }
    state = HistoryState(visitedIds: visited, ratings: ratings);
  }

  Future<void> markVisited(String id) async {
    if (state.visitedIds.contains(id)) return;
    final updated = [id, ...state.visitedIds].take(20).toList();
    state = HistoryState(visitedIds: updated, ratings: state.ratings);
    (await SharedPreferences.getInstance()).setStringList('visitedIds', updated);
  }

  Future<void> rate(String id, int value) async {
    final ratings = Map<String, int>.from(state.ratings)..[id] = value;
    state = HistoryState(visitedIds: state.visitedIds, ratings: ratings);
    (await SharedPreferences.getInstance()).setInt('rating_$id', value);
  }

  Future<void> clear() async {
    state = const HistoryState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('visitedIds');
    final keys = prefs.getKeys().where((k) => k.startsWith('rating_')).toList();
    for (final k in keys) await prefs.remove(k);
  }
}
