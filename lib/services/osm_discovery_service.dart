import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/institution.dart';

class DiscoveredOrg {
  final String osmId;
  final String name;
  final String address;
  final String neighborhood;
  InstitutionCategory category;
  final String? sphereLabel;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final String tagSource;
  final Map<String, dynamic> rawTags;
  bool selected;

  DiscoveredOrg({
    required this.osmId,
    required this.name,
    required this.address,
    required this.neighborhood,
    required this.category,
    this.sphereLabel,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    required this.tagSource,
    required this.rawTags,
    this.selected = true,
  });
}

/// Consulta o OpenStreetMap via Overpass para descobrir órgãos públicos
/// e serviços jurídicos APENAS dentro de Campo Grande/MS.
class OsmDiscoveryService {
  static const String _endpoint = 'https://overpass-api.de/api/interpreter';

  Future<List<DiscoveredOrg>> discoverInCampoGrande() async {
    final query = '''
[out:json][timeout:60];
area["wikidata"="Q170192"]->.cg;
(
  // Tribunais e órgãos jurídicos
  nwr["amenity"="courthouse"](area.cg);
  nwr["government"](area.cg);
  nwr["office"="government"](area.cg);
  nwr["office"="diplomatic"](area.cg);
  nwr["office"="political_party"](area.cg);
  nwr["office"="notary"](area.cg);
  nwr["office"="lawyer"](area.cg);

  // Prefeituras e administração
  nwr["amenity"="townhall"](area.cg);
  nwr["building"="public"](area.cg);
  nwr["building"="civic"](area.cg);
  nwr["building"="government"](area.cg);

  // Segurança pública
  nwr["amenity"="police"](area.cg);
  nwr["amenity"="fire_station"](area.cg);

  // Assistência social
  nwr["amenity"="social_facility"](area.cg);
  nwr["amenity"="community_centre"](area.cg);
  nwr["social_facility"](area.cg);
  nwr["office"="ngo"](area.cg);
  nwr["office"="charity"](area.cg);
  nwr["office"="foundation"](area.cg);

  // Saúde pública
  nwr["amenity"="hospital"](area.cg);
  nwr["amenity"="clinic"](area.cg);
  nwr["healthcare"="hospital"](area.cg);
  nwr["healthcare"="centre"](area.cg);

  // Cartórios e identificação
  nwr["office"="register"](area.cg);

  // Por nome (pega coisas com tags incompletas)
  nwr["name"~"defensoria|procon|ministério público|ministerio publico|ouvidoria|inss|previdência|previdencia|conselho tutelar|cras|creas|delegacia|ufms|uniderp|ucdb|fadir|facsul|prefeitura|câmara municipal|camara municipal",i](area.cg);
);
out center tags;
''';

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            body: {'data': query},
            headers: {'User-Agent': 'GeoJustica/1.0 (campo-grande-ms)'},
          )
          .timeout(const Duration(seconds: 70));

      if (response.statusCode != 200) {
        throw Exception('Erro ${response.statusCode} da API OpenStreetMap');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final elements = (json['elements'] as List?) ?? [];

      final results = <DiscoveredOrg>[];
      for (final el in elements) {
        final map = el as Map<String, dynamic>;
        final tags = (map['tags'] as Map?)?.cast<String, dynamic>() ?? {};
        final name = (tags['name'] ?? tags['operator'] ?? tags['short_name'] ?? '')
            .toString()
            .trim();
        if (name.isEmpty || name.length < 3) continue;

        // Filtro defensivo: se vier cidade, exige Campo Grande
        final city = tags['addr:city']?.toString().toLowerCase() ?? '';
        if (city.isNotEmpty && !city.contains('campo grande')) continue;

        // Coordenadas
        final lat = (map['lat'] as num?)?.toDouble() ??
            (map['center']?['lat'] as num?)?.toDouble();
        final lon = (map['lon'] as num?)?.toDouble() ??
            (map['center']?['lon'] as num?)?.toDouble();
        if (lat == null || lon == null) continue;

        final classified = _classify(
          osmId: '${map['type']}/${map['id']}',
          name: name,
          tags: tags,
          lat: lat,
          lon: lon,
        );
        results.add(classified);
      }

      // Dedupe por nome
      final seen = <String>{};
      final unique = <DiscoveredOrg>[];
      for (final r in results) {
        final key = r.name.toLowerCase().trim();
        if (seen.add(key)) unique.add(r);
      }

      // Ordena: classificados primeiro, depois "outros"
      unique.sort((a, b) {
        if (a.category == InstitutionCategory.outros &&
            b.category != InstitutionCategory.outros) return 1;
        if (a.category != InstitutionCategory.outros &&
            b.category == InstitutionCategory.outros) return -1;
        return a.name.compareTo(b.name);
      });

      return unique;
    } catch (e) {
      rethrow;
    }
  }

  DiscoveredOrg _classify({
    required String osmId,
    required String name,
    required Map<String, dynamic> tags,
    required double lat,
    required double lon,
  }) {
    final nameL = name.toLowerCase();
    final amenity = tags['amenity']?.toString() ?? '';
    final office = tags['office']?.toString() ?? '';
    final building = tags['building']?.toString() ?? '';
    final socialFacility = tags['social_facility']?.toString() ?? '';
    final healthcare = tags['healthcare']?.toString() ?? '';
    final operator = tags['operator']?.toString().toLowerCase() ?? '';

    InstitutionCategory category;
    String tagSource;

    // ============ POR NOME (mais preciso) ============
    if (nameL.contains('defensoria')) {
      category = InstitutionCategory.familia;
      tagSource = 'name:defensoria';
    } else if (nameL.contains('procon')) {
      category = InstitutionCategory.consumidor;
      tagSource = 'name:procon';
    } else if (nameL.contains('inss') ||
        nameL.contains('previdência') ||
        nameL.contains('previdencia')) {
      category = InstitutionCategory.aposentadoria;
      tagSource = 'name:inss';
    } else if (nameL.contains('ministério público') ||
        nameL.contains('ministerio publico') ||
        nameL.startsWith('mp ') ||
        nameL.contains('mpf') ||
        nameL.contains('mpms')) {
      category = InstitutionCategory.denuncias;
      tagSource = 'name:mp';
    } else if (nameL.contains('ouvidoria')) {
      category = InstitutionCategory.denuncias;
      tagSource = 'name:ouvidoria';
    } else if (nameL.contains('conselho tutelar')) {
      category = InstitutionCategory.familia;
      tagSource = 'name:conselho_tutelar';
    } else if (nameL.contains('cras')) {
      category = InstitutionCategory.familia;
      tagSource = 'name:cras';
    } else if (nameL.contains('creas')) {
      category = InstitutionCategory.violenciaDomestica;
      tagSource = 'name:creas';
    } else if (nameL.contains('casa da mulher') ||
        nameL.contains('ceam') ||
        nameL.contains('deam') ||
        nameL.contains('delegacia da mulher')) {
      category = InstitutionCategory.direitosMulher;
      tagSource = 'name:mulher';
    } else if (nameL.contains('upa') ||
        nameL.contains('ubs') ||
        nameL.contains('posto de saúde') ||
        nameL.contains('posto de saude') ||
        nameL.contains('hospital') ||
        nameL.contains('santa casa') ||
        nameL.contains('clínica popular') ||
        nameL.contains('regional')) {
      category = InstitutionCategory.saude;
      tagSource = 'name:saude';
    } else if (nameL.contains('oab')) {
      category = InstitutionCategory.denuncias;
      tagSource = 'name:oab';
    } else if (nameL.contains('cartório') || nameL.contains('cartorio')) {
      category = InstitutionCategory.documentos;
      tagSource = 'name:cartorio';
    } else if (nameL.contains('tribunal') ||
        nameL.contains('fórum') ||
        nameL.contains('forum') ||
        nameL.contains('justiça') ||
        nameL.contains('justica')) {
      category = InstitutionCategory.outros;
      tagSource = 'name:tribunal';
    } else if (nameL.contains('delegacia') ||
        nameL.contains('polícia') ||
        nameL.contains('policia')) {
      if (nameL.contains('mulher')) {
        category = InstitutionCategory.violenciaDomestica;
      } else {
        category = InstitutionCategory.denuncias;
      }
      tagSource = 'name:policia';
    } else if (nameL.contains('prefeitura') ||
        nameL.contains('câmara municipal') ||
        nameL.contains('camara municipal')) {
      category = InstitutionCategory.denuncias;
      tagSource = 'name:prefeitura';
    } else if (nameL.contains('ufms') ||
        nameL.contains('uniderp') ||
        nameL.contains('ucdb') ||
        nameL.contains('fadir') ||
        nameL.contains('facsul')) {
      // Universidades — núcleos jurídicos
      category = InstitutionCategory.familia;
      tagSource = 'name:universidade';
    }
    // ============ POR TAG (fallback) ============
    else if (amenity == 'courthouse') {
      category = InstitutionCategory.outros;
      tagSource = 'amenity=courthouse';
    } else if (amenity == 'police') {
      category = InstitutionCategory.denuncias;
      tagSource = 'amenity=police';
    } else if (amenity == 'townhall') {
      category = InstitutionCategory.denuncias;
      tagSource = 'amenity=townhall';
    } else if (amenity == 'hospital' ||
        amenity == 'clinic' ||
        healthcare.isNotEmpty) {
      category = InstitutionCategory.saude;
      tagSource = 'amenity=$amenity';
    } else if (socialFacility.isNotEmpty || amenity == 'social_facility') {
      category = InstitutionCategory.familia;
      tagSource = 'social_facility=$socialFacility';
    } else if (office == 'government' ||
        office == 'diplomatic' ||
        building == 'government' ||
        building == 'civic') {
      category = InstitutionCategory.denuncias;
      tagSource = office.isNotEmpty ? 'office=$office' : 'building=$building';
    } else if (office == 'notary' || office == 'register') {
      category = InstitutionCategory.documentos;
      tagSource = 'office=$office';
    } else if (office == 'ngo' || office == 'charity' || office == 'foundation') {
      category = InstitutionCategory.outros;
      tagSource = 'office=$office';
    } else if (amenity == 'community_centre') {
      category = InstitutionCategory.outros;
      tagSource = 'amenity=community_centre';
    } else if (operator.contains('governo') ||
        operator.contains('prefeitura') ||
        operator.contains('estado') ||
        operator.contains('federal')) {
      category = InstitutionCategory.denuncias;
      tagSource = 'operator=$operator';
    } else {
      // Não foi possível classificar — vai pra "outros" e admin reclassifica
      category = InstitutionCategory.outros;
      final firstTag = tags.entries
          .where((e) => !e.key.startsWith('addr:') && e.key != 'name')
          .map((e) => '${e.key}=${e.value}')
          .take(1)
          .join();
      tagSource = firstTag.isEmpty ? 'sem-tag-clara' : firstTag;
    }

    final street = tags['addr:street']?.toString() ?? '';
    final number = tags['addr:housenumber']?.toString() ?? '';
    final address = [
      street,
      if (number.isNotEmpty) ', $number',
    ].join().trim();

    return DiscoveredOrg(
      osmId: osmId,
      name: name,
      address: address.isEmpty ? 'Endereço não cadastrado no OSM' : address,
      neighborhood: tags['addr:suburb']?.toString() ??
          tags['addr:district']?.toString() ??
          'Campo Grande',
      category: category,
      latitude: lat,
      longitude: lon,
      phone: tags['phone']?.toString() ?? tags['contact:phone']?.toString(),
      website: tags['website']?.toString() ?? tags['contact:website']?.toString(),
      tagSource: tagSource,
      rawTags: tags,
    );
  }
}
