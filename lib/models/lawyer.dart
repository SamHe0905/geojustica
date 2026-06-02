import 'institution.dart';

enum LawyerModality {
  proBono,           // Gratuito
  primeiraGratis,    // Primeira consulta gratuita
  honorarioSocial,   // Honorários reduzidos
  parcelado,         // Aceita parcelamento
  exito;             // Só recebe se ganhar (sucesso)

  String get label {
    switch (this) {
      case proBono: return 'Pro bono (gratuito)';
      case primeiraGratis: return '1ª consulta grátis';
      case honorarioSocial: return 'Honorário social';
      case parcelado: return 'Parcelado';
      case exito: return 'Honorário de êxito';
    }
  }

  String get icon {
    switch (this) {
      case proBono: return '🤝';
      case primeiraGratis: return '🆓';
      case honorarioSocial: return '💚';
      case parcelado: return '💳';
      case exito: return '🏆';
    }
  }
}

class Lawyer {
  final String id;
  final String name;
  final String oab;                       // ex.: "OAB/MS 12345"
  final String? photoUrl;
  final String? bio;
  final List<InstitutionCategory> specialties;
  final List<LawyerModality> modalities;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? address;
  final String neighborhood;
  final double? latitude;
  final double? longitude;
  final double rating;                    // 0..5
  final int ratingCount;
  final bool isVerified;                  // OAB verificada
  final bool isActive;
  final List<String> languages;           // ex.: ['Português', 'Espanhol', 'Libras']

  const Lawyer({
    required this.id,
    required this.name,
    required this.oab,
    this.photoUrl,
    this.bio,
    this.specialties = const [],
    this.modalities = const [],
    this.phone,
    this.whatsapp,
    this.email,
    this.address,
    required this.neighborhood,
    this.latitude,
    this.longitude,
    this.rating = 0,
    this.ratingCount = 0,
    this.isVerified = false,
    this.isActive = true,
    this.languages = const ['Português'],
  });

  bool get isFree => modalities.contains(LawyerModality.proBono);
  bool get hasFreeOption => isFree ||
      modalities.contains(LawyerModality.primeiraGratis) ||
      modalities.contains(LawyerModality.exito);
}
