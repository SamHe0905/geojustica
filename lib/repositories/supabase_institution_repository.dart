import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/institution.dart';
import '../services/location_service.dart';
import 'local_institution_repository.dart';

/// Repositório com fallback automático: tenta Supabase, se falhar usa local.
class SupabaseInstitutionRepository {
  final LocalInstitutionRepository _local = LocalInstitutionRepository();

  SupabaseClient? get _client {
    if (!SupabaseConfig.useSupabase) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<Institution>> getAll() async {
    final client = _client;
    if (client == null) return _local.getAll();
    try {
      final response = await client
          .from('institutions')
          .select()
          .eq('is_active', true)
          .order('name');
      return (response as List).map((e) => _fromRow(e)).toList();
    } catch (_) {
      return _local.getAll();
    }
  }

  Future<List<Institution>> getByCategory(
    InstitutionCategory category, {
    bool onlyFree = false,
    LatLng? userLocation,
  }) async {
    final client = _client;
    if (client == null) {
      return _local.getByCategory(category,
          onlyFree: onlyFree, userLocation: userLocation);
    }
    try {
      var query = client
          .from('institutions')
          .select()
          .eq('is_active', true)
          .eq('category', category.name);
      if (onlyFree) query = query.eq('accepts_indigent', true);
      final response = await query.order('name');
      final institutions = (response as List).map((e) => _fromRow(e)).toList();

      if (userLocation != null) {
        final loc = LocationService();
        for (final inst in institutions) {
          inst.distanceKm = loc.calculateDistanceKm(userLocation, inst.latLng);
        }
        institutions
            .sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
      }
      return institutions;
    } catch (_) {
      return _local.getByCategory(category,
          onlyFree: onlyFree, userLocation: userLocation);
    }
  }

  /// Listagem do painel: traz também os inativos e nunca cai para o local
  /// silenciosamente — se o Supabase estiver fora, o admin precisa saber, senão
  /// editaria registros que não seriam gravados.
  Future<List<Institution>> getAllForAdmin() async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase indisponível — o painel precisa de conexão.');
    }
    final response = await client.from('institutions').select().order('name');
    return (response as List).map((e) => _fromRow(e)).toList();
  }

  Future<Institution?> getById(String id) async {
    final client = _client;
    if (client == null) return _local.getById(id);
    try {
      final response =
          await client.from('institutions').select().eq('id', id).maybeSingle();
      if (response == null) return _local.getById(id);
      return _fromRow(response);
    } catch (_) {
      return _local.getById(id);
    }
  }

  /// Insere em lote. O id do modelo é ignorado (o Postgres gera um uuid novo).
  /// Retorna o número de registros gravados. Lança exceção se o Supabase não
  /// estiver disponível (import bruto no local não faz sentido nesse fluxo).
  Future<int> bulkInsert(List<Institution> institutions) async {
    if (institutions.isEmpty) return 0;
    final client = _client;
    if (client == null) {
      throw StateError('Supabase indisponível — bulk insert requer conexão.');
    }
    final rows = institutions.map(_toInsertRow).toList();
    await client.from('institutions').insert(rows);
    return rows.length;
  }

  /// Atualiza um registro existente (pelo uuid real do Supabase).
  Future<void> updateOne(String id, Institution data) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase indisponível — update requer conexão.');
    }
    await client.from('institutions').update(_toInsertRow(data)).eq('id', id);
  }

  Map<String, dynamic> _toInsertRow(Institution i) => {
        'name': i.name,
        'address': i.address,
        'neighborhood': i.neighborhood,
        'phone': i.phone,
        'whatsapp': i.whatsapp,
        'category': i.category.name,
        'services': i.services.join(';'),
        'schedule': i.schedule,
        'observations': i.observations,
        'sphere': i.sphere.name,
        'latitude': i.latitude,
        'longitude': i.longitude,
        'accepts_indigent': i.acceptsIndigent,
        'is_active': i.isActive,
      };

  Institution _fromRow(Map<String, dynamic> row) {
    final servicesStr = (row['services'] ?? '').toString();
    final services = servicesStr
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Institution(
      id: row['id'].toString(),
      name: row['name'] ?? '',
      address: row['address'] ?? '',
      neighborhood: row['neighborhood'] ?? '',
      phone: row['phone'],
      whatsapp: row['whatsapp'],
      category: InstitutionCategory.fromString(row['category'] ?? 'outros'),
      services: services,
      schedule: row['schedule'],
      observations: row['observations'],
      sphere: Institution.parseSphere(row['sphere']),
      latitude: (row['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (row['longitude'] as num?)?.toDouble() ?? 0,
      acceptsIndigent: row['accepts_indigent'] ?? true,
      isActive: row['is_active'] ?? true,
    );
  }
}
