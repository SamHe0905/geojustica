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
