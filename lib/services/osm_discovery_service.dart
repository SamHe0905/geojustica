import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/institution.dart';

/// Resultado de descoberta — instituição candidata vinda do OpenStreetMap.
class DiscoveredOrg {
  final String osmId;
  final String name;
  final String address;
  final String neighborhood;
  final InstitutionCategory category;
  final String? sphereLabel;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final String tagSource;
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
    this.selected = true,
  });
}

/// Consulta o OpenStreetMap via Overpass API para descobrir órgãos públicos.
class OsmDiscoveryService {
  static const String _endpoint = 'https://overpass-api.de/api/interpreter';

  /// Busca órgãos públicos APENAS dentro da fronteira administrativa de Campo Grande/MS.
  /// Usa wikidata Q170192 para evitar confusão com outras 'Campo Grande' do Brasil.
  /// Pode demorar 15–30s na primeira chamada.
  Future<List<DiscoveredOrg>> discoverInCampoGrande() async {
    // area["wikidata"="Q170192"] = relation administrativa do município de
    // Campo Grande/MS (não pega Campo Grande/RJ, Campo Grande/PB, etc).
    final query = '''
[out:json][timeout:45];
area["wikidata"="Q170192"]->.cg;
(
  node["amenity"="courthouse"](area.cg);
  node["amenity"="townhall"](area.cg);
  node["amenity"="police"](area.cg);
  node["amenity"="community_centre"](area.cg);
  node["amenity"="social_facility"](area.cg);
  node["office"="government"](area.cg);
  node["office"="notary"](area.cg);
  node["office"="ngo"](area.cg);
  way["amenity"="courthouse"](area.cg);
  way["amenity"="townhall"](area.cg);
  way["amenity"="police"](area.cg);
  way["amenity"="community_centre"](area.cg);
  way["amenity"="social_facility"](area.cg);
  way["office"="government"](area.cg);
  way["office"="notary"](area.cg);
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
          .timeout(const Duration(seconds: 45));

      if (response.statusCode != 200) {
        throw Exception('Erro ${response.statusCode} da API OpenStreetMap');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final elements = (json['elements'] as List?) ?? [];

      final results = <DiscoveredOrg>[];
      for (final el in elements) {
        final map = el as Map<String, dynamic>;
        final tags = (map['tags'] as Map?)?.cast<String, dynamic>() ?? {};
        final name = (tags['name'] ?? tags['operator'] ?? '').toString().trim();
        if (name.isEmpty || name.length < 3) continue;

        // Filtro defensivo: se vier com cidade no endereço, exige Campo Grande
        final city = tags['addr:city']?.toString().toLowerCase() ?? '';
        if (city.isNotEmpty &&
            !city.contains('campo grande')) {
          continue;
        }

        // Coordenadas: ponto direto ou center de way/relation
        final lat = (map['lat'] as num?)?.toDouble() ??
            (map['center']?['lat'] as num?)?.toDouble();
        final lon = (map['lon'] as num?)?.toDouble() ??
            (map['center']?['lon'] as num?)?.toDouble();
        if (lat == null || lon == null) continue;

        final discovered = _classify(
          osmId: '${map['type']}/${map['id']}',
          name: name,
          tags: tags,
          lat: lat,
          lon: lon,
        );
        if (discovered != null) results.add(discovered);
      }

      // Remove duplicatas por nome (ignore case)
      final seen = <String>{};
      return results.where((r) {
        final key = r.name.toLowerCase().trim();
        if (seen.contains(key)) return false;
        seen.add(key);
        return true;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  DiscoveredOrg? _classify({
    required String osmId,
    required String name,
    required Map<String, dynamic> tags,
    required double lat,
    required double lon,
  }) {
    final nameL = name.toLowerCase();
    final amenity = tags['amenity']?.toString() ?? '';
    final office = tags['office']?.toString() ?? '';
    final governmentType = tags['government']?.toString().toLowerCase() ?? '';
    final socialFacility = tags['social_facility']?.toString() ?? '';

    InstitutionCategory category;
    String tagSource;

    // Polícia / delegacia → violência doméstica ou denúncia conforme nome
    if (amenity == 'police') {
      if (nameL.contains('mulher') || nameL.contains('deam')) {
        category = InstitutionCategory.violenciaDomestica;
      } else {
        category = InstitutionCategory.denuncias;
      }
      tagSource = 'amenity=police';
    }
    // Tribunal / fórum
    else if (amenity == 'courthouse' ||
        governmentType == 'court' ||
        nameL.contains('forum') ||
        nameL.contains('tribunal')) {
      category = InstitutionCategory.outros;
      tagSource = 'amenity=courthouse';
    }
    // CRAS / CREAS / assistência social
    else if (socialFacility.isNotEmpty ||
        nameL.contains('cras') ||
        nameL.contains('creas')) {
      category = InstitutionCategory.familia;
      tagSource = 'social_facility=$socialFacility';
    }
    // Casa da Mulher / Mulher
    else if (nameL.contains('casa da mulher') ||
        nameL.contains('ceam') ||
        nameL.contains('atendimento à mulher')) {
      category = InstitutionCategory.direitosMulher;
      tagSource = 'name=mulher';
    }
    // INSS / Previdência
    else if (nameL.contains('inss') ||
        nameL.contains('previdência') ||
        nameL.contains('aposentadoria')) {
      category = InstitutionCategory.aposentadoria;
      tagSource = 'name=inss';
    }
    // PROCON
    else if (nameL.contains('procon')) {
      category = InstitutionCategory.consumidor;
      tagSource = 'name=procon';
    }
    // Defensoria
    else if (nameL.contains('defensoria')) {
      category = InstitutionCategory.familia;
      tagSource = 'name=defensoria';
    }
    // Ministério Público
    else if (nameL.contains('ministério público') ||
        nameL.contains('ministerio publico') ||
        nameL.contains('mp/') ||
        nameL.contains('mpf')) {
      category = InstitutionCategory.denuncias;
      tagSource = 'name=mp';
    }
    // Ouvidoria
    else if (nameL.contains('ouvidoria')) {
      category = InstitutionCategory.denuncias;
      tagSource = 'name=ouvidoria';
    }
    // Cartório
    else if (office == 'notary' || nameL.contains('cartório')) {
      category = InstitutionCategory.documentos;
      tagSource = 'office=notary';
    }
    // Saúde
    else if (nameL.contains('hospital') ||
        nameL.contains('upa') ||
        nameL.contains('ubs') ||
        nameL.contains('posto de saúde') ||
        nameL.contains('clínica popular')) {
      category = InstitutionCategory.saude;
      tagSource = 'health';
    }
    // OAB
    else if (nameL.contains('oab')) {
      category = InstitutionCategory.denuncias;
      tagSource = 'name=oab';
    }
    // Prefeitura / Governo
    else if (amenity == 'townhall' ||
        office == 'government' ||
        nameL.contains('prefeitura') ||
        nameL.contains('governo')) {
      category = InstitutionCategory.denuncias;
      tagSource = office.isNotEmpty ? 'office=$office' : 'amenity=townhall';
    }
    // Centro comunitário / ONG → assistência geral
    else if (amenity == 'community_centre' || office == 'ngo') {
      category = InstitutionCategory.outros;
      tagSource = amenity.isNotEmpty ? 'amenity=$amenity' : 'office=ngo';
    } else {
      return null; // não reconheceu
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
      sphereLabel: governmentType.isNotEmpty ? governmentType : null,
      latitude: lat,
      longitude: lon,
      phone: tags['phone']?.toString() ?? tags['contact:phone']?.toString(),
      website: tags['website']?.toString() ?? tags['contact:website']?.toString(),
      tagSource: tagSource,
    );
  }
}
