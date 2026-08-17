import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team_member.dart';
import 'auth_provider.dart';

/// Lista da equipe. Só o dono enxerga — para os demais devolve lista vazia
/// sem nem chamar o servidor.
final teamListProvider = FutureProvider<List<TeamMember>>((ref) async {
  final auth = ref.watch(adminAuthProvider);
  final session = auth.session;
  if (session == null || !session.member.isOwner) return const [];
  return ref.watch(teamRepoProvider).list(session.token);
});
