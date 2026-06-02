import '../models/institution.dart';
import '../models/lawyer.dart';

class LawyerRepository {
  static final List<Lawyer> _data = [
    Lawyer(
      id: 'L001',
      name: 'Dra. Maria Helena Souza',
      oab: 'OAB/MS 18.452',
      bio: 'Advogada com 12 anos de experiência em direito de família e violência doméstica. Atendimento humanizado.',
      specialties: [
        InstitutionCategory.familia,
        InstitutionCategory.violenciaDomestica,
        InstitutionCategory.direitosMulher,
      ],
      modalities: [LawyerModality.primeiraGratis, LawyerModality.honorarioSocial],
      phone: '(67) 99876-1234',
      whatsapp: '5567998761234',
      email: 'mhsouza.adv@email.com',
      address: 'Rua Maracaju, 1200, sala 4',
      neighborhood: 'Centro',
      latitude: -20.4685,
      longitude: -54.6201,
      rating: 4.8,
      ratingCount: 127,
      isVerified: true,
      languages: ['Português', 'Espanhol'],
    ),
    Lawyer(
      id: 'L002',
      name: 'Dr. João Pedro Almeida',
      oab: 'OAB/MS 22.103',
      bio: 'Especialista em direito trabalhista. Atendo rescisões, horas extras e acidentes de trabalho.',
      specialties: [InstitutionCategory.trabalho],
      modalities: [LawyerModality.exito, LawyerModality.parcelado],
      phone: '(67) 99765-4321',
      whatsapp: '5567997654321',
      address: 'Av. Afonso Pena, 4444, sala 102',
      neighborhood: 'Cabreúva',
      latitude: -20.4720,
      longitude: -54.6170,
      rating: 4.6,
      ratingCount: 89,
      isVerified: true,
    ),
    Lawyer(
      id: 'L003',
      name: 'Dra. Aparecida dos Santos',
      oab: 'OAB/MS 15.778',
      bio: 'Atuo pro bono para pessoas em situação de vulnerabilidade. Direito previdenciário e BPC/LOAS.',
      specialties: [InstitutionCategory.aposentadoria],
      modalities: [LawyerModality.proBono, LawyerModality.exito],
      phone: '(67) 99654-8800',
      whatsapp: '5567996548800',
      address: 'Rua 14 de Julho, 2080',
      neighborhood: 'Centro',
      latitude: -20.4670,
      longitude: -54.6210,
      rating: 4.9,
      ratingCount: 203,
      isVerified: true,
      languages: ['Português', 'Libras'],
    ),
    Lawyer(
      id: 'L004',
      name: 'Dr. Carlos Eduardo Vieira',
      oab: 'OAB/MS 20.501',
      bio: 'Direito do consumidor e direito imobiliário. 1ª consulta sempre gratuita.',
      specialties: [InstitutionCategory.consumidor, InstitutionCategory.moradia],
      modalities: [LawyerModality.primeiraGratis, LawyerModality.parcelado],
      phone: '(67) 99432-1100',
      whatsapp: '5567994321100',
      address: 'Av. Mato Grosso, 1500, sala 305',
      neighborhood: 'Jardim dos Estados',
      latitude: -20.4732,
      longitude: -54.6148,
      rating: 4.5,
      ratingCount: 64,
      isVerified: true,
    ),
    Lawyer(
      id: 'L005',
      name: 'Dra. Patrícia Lima',
      oab: 'OAB/MS 17.890',
      bio: 'Defensora dos direitos da mulher. Atendimento sigiloso e acolhedor.',
      specialties: [
        InstitutionCategory.direitosMulher,
        InstitutionCategory.violenciaDomestica,
        InstitutionCategory.familia,
      ],
      modalities: [LawyerModality.proBono, LawyerModality.primeiraGratis],
      phone: '(67) 99321-5500',
      whatsapp: '5567993215500',
      email: 'patricialima.adv@email.com',
      address: 'Rua Brilhante, 500',
      neighborhood: 'Vila Carvalho',
      latitude: -20.4810,
      longitude: -54.6020,
      rating: 5.0,
      ratingCount: 156,
      isVerified: true,
    ),
    Lawyer(
      id: 'L006',
      name: 'Dr. Ricardo Mendonça',
      oab: 'OAB/MS 24.667',
      bio: 'Documentação civil, retificação de registros, segunda via de documentos.',
      specialties: [InstitutionCategory.documentos, InstitutionCategory.outros],
      modalities: [LawyerModality.honorarioSocial, LawyerModality.parcelado],
      phone: '(67) 99213-7700',
      address: 'Av. Bandeirantes, 850',
      neighborhood: 'Amambaí',
      latitude: -20.4780,
      longitude: -54.6390,
      rating: 4.3,
      ratingCount: 42,
      isVerified: true,
    ),
  ];

  List<Lawyer> getAll() => List.from(_data);

  List<Lawyer> getByCategory(InstitutionCategory category) =>
      _data.where((l) => l.isActive && l.specialties.contains(category)).toList();

  List<Lawyer> filter({
    InstitutionCategory? category,
    bool onlyFree = false,
    bool onlyVerified = false,
  }) {
    return _data.where((l) {
      if (!l.isActive) return false;
      if (category != null && !l.specialties.contains(category)) return false;
      if (onlyFree && !l.hasFreeOption) return false;
      if (onlyVerified && !l.isVerified) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  Lawyer? getById(String id) {
    try {
      return _data.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  void add(Lawyer lawyer) => _data.add(lawyer);
}
