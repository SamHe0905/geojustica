import 'package:latlong2/latlong.dart';

enum InstitutionCategory {
  familia,
  trabalho,
  violenciaDomestica,
  consumidor,
  moradia,
  documentos,
  direitosMulher,
  aposentadoria,
  saude,
  denuncias,
  outros;

  String get label {
    switch (this) {
      case familia: return 'Família';
      case trabalho: return 'Trabalho';
      case violenciaDomestica: return 'Violência doméstica';
      case consumidor: return 'Consumidor';
      case moradia: return 'Moradia';
      case documentos: return 'Documentos';
      case direitosMulher: return 'Direitos da mulher';
      case aposentadoria: return 'Aposentadoria';
      case saude: return 'Saúde';
      case denuncias: return 'Denúncias';
      case outros: return 'Outros';
    }
  }

  /// Se a categoria envolve litígio (precisa saber se pode pagar advogado).
  bool get requiresPaymentQuestion {
    switch (this) {
      case familia:
      case trabalho:
      case consumidor:
      case moradia:
      case aposentadoria:
        return true;
      // Emergência, anônimo, administrativo, saúde pública não precisa
      case violenciaDomestica:
      case direitosMulher:
      case documentos:
      case saude:
      case denuncias:
      case outros:
        return false;
    }
  }

  static InstitutionCategory fromString(String value) {
    final normalized = value.toLowerCase().replaceAll(' ', '_').replaceAll('ç', 'c').replaceAll('ã', 'a');
    return InstitutionCategory.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => outros,
    );
  }
}

enum AdminSphere { municipal, estadual, federal, naoGovernamental }

class Institution {
  final String id;
  final String name;
  final String address;
  final String neighborhood;
  final String? phone;
  final String? whatsapp;
  final InstitutionCategory category;
  final List<String> services;
  final String? schedule;
  final String? observations;
  final AdminSphere sphere;
  final double latitude;
  final double longitude;
  final bool acceptsIndigent;
  final bool isActive;
  double? distanceKm;

  Institution({
    required this.id,
    required this.name,
    required this.address,
    required this.neighborhood,
    this.phone,
    this.whatsapp,
    required this.category,
    this.services = const [],
    this.schedule,
    this.observations,
    this.sphere = AdminSphere.municipal,
    required this.latitude,
    required this.longitude,
    this.acceptsIndigent = true,
    this.isActive = true,
    this.distanceKm,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  factory Institution.fromMap(Map<String, dynamic> map) => Institution(
        id: map['id']?.toString() ?? '',
        name: map['name'] ?? map['nome'] ?? '',
        address: map['address'] ?? map['endereco'] ?? '',
        neighborhood: map['neighborhood'] ?? map['bairro'] ?? '',
        phone: map['phone'] ?? map['telefone'],
        whatsapp: map['whatsapp'],
        category: InstitutionCategory.fromString(map['category'] ?? map['categoria'] ?? 'outros'),
        services: _parseList(map['services'] ?? map['servicos']),
        schedule: map['schedule'] ?? map['horario'],
        observations: map['observations'] ?? map['observacoes'],
        sphere: _parseSphere(map['sphere'] ?? map['esfera']),
        latitude: _parseDouble(map['latitude']),
        longitude: _parseDouble(map['longitude']),
        acceptsIndigent: map['accepts_indigent'] ?? map['atende_gratuito'] ?? true,
        isActive: map['is_active'] ?? map['ativo'] ?? true,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'neighborhood': neighborhood,
        'phone': phone,
        'whatsapp': whatsapp,
        'category': category.name,
        'services': services.join(';'),
        'schedule': schedule,
        'observations': observations,
        'sphere': sphere.name,
        'latitude': latitude,
        'longitude': longitude,
        'accepts_indigent': acceptsIndigent,
        'is_active': isActive,
      };

  Institution copyWith({bool? isActive, String? phone, String? whatsapp}) => Institution(
        id: id, name: name, address: address, neighborhood: neighborhood,
        phone: phone ?? this.phone, whatsapp: whatsapp ?? this.whatsapp,
        category: category, services: services, schedule: schedule,
        observations: observations, sphere: sphere, latitude: latitude, longitude: longitude,
        acceptsIndigent: acceptsIndigent, isActive: isActive ?? this.isActive,
      );

  static AdminSphere parseSphere(dynamic value) => _parseSphere(value);

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) return value.split(';').where((s) => s.isNotEmpty).toList();
    return [];
  }

  static AdminSphere _parseSphere(dynamic value) {
    if (value == null) return AdminSphere.municipal;
    final s = value.toString().toLowerCase();
    if (s.contains('estado') || s.contains('estadual')) return AdminSphere.estadual;
    if (s.contains('federal')) return AdminSphere.federal;
    if (s.contains('ong') || s.contains('nao_gov') || s.contains('ngovernamental')) return AdminSphere.naoGovernamental;
    return AdminSphere.municipal;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
