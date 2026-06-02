import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/institution.dart';
import '../services/location_service.dart';
import 'package:latlong2/latlong.dart';

class InstitutionRepository {
  final SupabaseClient _client;

  InstitutionRepository(this._client);

  Future<List<Institution>> fetchAll() async {
    final response = await _client
        .from('institutions')
        .select()
        .eq('is_active', true)
        .order('name');
    return (response as List).map((e) => Institution.fromMap(e)).toList();
  }

  Future<List<Institution>> fetchByCategory(
    InstitutionCategory category, {
    bool? onlyFree,
    LatLng? userLocation,
  }) async {
    var query = _client
        .from('institutions')
        .select()
        .eq('is_active', true)
        .eq('category', category.name);

    if (onlyFree == true) {
      query = query.eq('accepts_indigent', true);
    }

    final response = await query.order('name');
    final institutions = (response as List).map((e) => Institution.fromMap(e)).toList();

    if (userLocation != null) {
      final locService = LocationService();
      for (final inst in institutions) {
        inst.distanceKm = locService.calculateDistanceKm(userLocation, inst.latLng);
      }
      institutions.sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
    }

    return institutions;
  }

  Future<Institution?> fetchById(String id) async {
    final response = await _client
        .from('institutions')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return Institution.fromMap(response);
  }

  Future<void> upsert(Institution institution) async {
    await _client.from('institutions').upsert(institution.toMap());
  }

  Future<void> bulkUpsert(List<Institution> institutions) async {
    final data = institutions.map((e) => e.toMap()).toList();
    await _client.from('institutions').upsert(data);
  }

  Future<void> setActive(String id, bool active) async {
    await _client.from('institutions').update({'is_active': active}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('institutions').delete().eq('id', id);
  }
}
