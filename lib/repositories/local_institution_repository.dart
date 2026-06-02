import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../models/institution.dart';

class LocalInstitutionRepository {
  static final List<Institution> _data = [
    Institution(
      id: '1',
      name: 'Defensoria Pública do Estado de MS (Sede / DPGE-MS)',
      address: 'Av. Desembargador José Nunes da Cunha, s/nº - Bloco IV, 1º Andar',
      neighborhood: 'Parque dos Poderes',
      phone: '(67) 3318-2500 / 129',
      whatsapp: '67992473968',
      category: InstitutionCategory.outros,
      services: [
        'Assistência jurídica integral e gratuita',
        'Direito cível, criminal, família, infância e juventude',
        'Execução penal e direitos humanos',
        'Ações coletivas e orientação jurídica',
        'Disque Defensoria 129',
      ],
      schedule: 'Seg-Sex 07:30–13:30',
      sphere: AdminSphere.estadual,
      latitude: -20.4392,
      longitude: -54.5918,
      acceptsIndigent: true,
    ),
    Institution(
      id: '2',
      name: 'Defensoria Pública da União - DPU/MS',
      address: 'Rua Eduardo Santos Pereira, 1186',
      neighborhood: 'Vila Cruzeiro / Centro',
      phone: '(67) 3311-9850',
      category: InstitutionCategory.aposentadoria,
      services: [
        'INSS: aposentadoria, auxílio-doença, BPC/LOAS, salário-maternidade',
        'Saúde: medicamentos de alto custo',
        'Caixa Econômica e FGTS',
        'Refugiados e migrantes',
      ],
      schedule: 'Seg-Sex 12:00–18:00',
      sphere: AdminSphere.federal,
      latitude: -20.4667,
      longitude: -54.6167,
      acceptsIndigent: true,
    ),
    Institution(
      id: '3',
      name: 'NAS - Núcleo de Atendimento à Saúde (Defensoria Pública/MS)',
      address: 'Rua Barão de Melgaço, 128',
      neighborhood: 'Centro',
      phone: '(67) 3317-8757',
      category: InstitutionCategory.outros,
      services: [
        'Medicamentos e tratamentos pelo SUS',
        'Internações, leitos e cirurgias',
        'Defesa judicial em saúde pública',
        'Ações civis públicas',
      ],
      schedule: 'Seg-Sex 07:30–13:30',
      sphere: AdminSphere.estadual,
      latitude: -20.4680,
      longitude: -54.6210,
      acceptsIndigent: true,
    ),
    Institution(
      id: '4',
      name: 'NUFAM - Núcleo da Família (Defensoria Pública/MS)',
      address: 'Rua Arthur Jorge, 779',
      neighborhood: 'Centro',
      phone: '(67) 3313-5800',
      category: InstitutionCategory.familia,
      services: [
        'Divórcio e separação',
        'Pensão alimentícia e guarda',
        'Reconhecimento de paternidade',
        'União estável e inventário',
        'Conciliação extrajudicial',
      ],
      schedule: 'Seg-Sex 07:30–13:30',
      sphere: AdminSphere.estadual,
      latitude: -20.4660,
      longitude: -54.6190,
      acceptsIndigent: true,
    ),
    Institution(
      id: '5',
      name: 'Casa da Mulher Brasileira - CMB Campo Grande',
      address: 'Rua Brasília, Lote A, Quadra 2, s/nº',
      neighborhood: 'Jardim Imá',
      phone: '(67) 2020-1300 / 180 / 190',
      whatsapp: '61961000180',
      category: InstitutionCategory.violenciaDomestica,
      services: [
        'Acolhimento e triagem 24h',
        'Delegacia da Mulher (DEAM)',
        'Juizado da Violência Doméstica',
        'Ministério Público e Defensoria',
        'Apoio psicossocial e alojamento',
        'Central de transportes',
      ],
      schedule: '24 horas, todos os dias',
      sphere: AdminSphere.federal,
      latitude: -20.4950,
      longitude: -54.5820,
      acceptsIndigent: true,
    ),
    Institution(
      id: '6',
      name: 'CEAM - Centro Especializado de Atendimento à Mulher',
      address: 'Rua Pedro Celestino, 437',
      neighborhood: 'Centro',
      phone: '(67) 3361-7519',
      category: InstitutionCategory.direitosMulher,
      services: [
        'Atendimento psicossocial',
        'Orientação jurídica para vítimas de violência',
        'Encaminhamentos à rede de proteção',
        'Suporte para municípios do interior',
      ],
      schedule: 'Seg-Sex 07:30–17:30',
      sphere: AdminSphere.estadual,
      latitude: -20.4700,
      longitude: -54.6150,
      acceptsIndigent: true,
    ),
    Institution(
      id: '7',
      name: 'NUPRAJUR - Núcleo de Práticas Jurídicas (UCDB)',
      address: 'Av. Tamandaré, 6000 - Campus UCDB',
      neighborhood: 'Jardim Seminário',
      phone: '(67) 3312-3643',
      category: InstitutionCategory.outros,
      services: [
        'Atendimento jurídico gratuito',
        'Direito de família, consumidor e previdenciário',
        'Triagem por serviço social',
        'Justiça Itinerante (divórcio, guarda, pensão)',
        'Teleatendimento disponível',
      ],
      schedule: 'Seg-Sex 07:00–16:20',
      sphere: AdminSphere.naoGovernamental,
      latitude: -20.4940,
      longitude: -54.6580,
      acceptsIndigent: true,
    ),
    Institution(
      id: '8',
      name: 'PRAJUR - Núcleo de Prática Jurídica (Anhanguera-Uniderp)',
      address: 'Rua Ceará, 333 - Campus I',
      neighborhood: 'Miguel Couto',
      phone: '(67) 3348-8065',
      category: InstitutionCategory.trabalho,
      services: [
        'Direito civil e criminal',
        'Direito trabalhista',
        'Direito empresarial',
        'Orientação a microempreendedores',
      ],
      schedule: 'Seg-Sex 07:30–17:00',
      sphere: AdminSphere.naoGovernamental,
      latitude: -20.4650,
      longitude: -54.6350,
      acceptsIndigent: true,
    ),
    Institution(
      id: '9',
      name: 'NPJ - Núcleo de Prática Jurídica (FACSUL)',
      address: 'Av. Afonso Pena, 275',
      neighborhood: 'Amambaí',
      phone: '(67) 3378-9000',
      category: InstitutionCategory.outros,
      services: [
        'Assistência judiciária à população carente',
        'Convênios com Tribunais, MP e OAB',
        'Estágio prático supervisionado',
      ],
      schedule: 'Seg-Sex 13:00–17:00',
      sphere: AdminSphere.naoGovernamental,
      latitude: -20.4780,
      longitude: -54.6390,
      acceptsIndigent: true,
    ),
    Institution(
      id: '10',
      name: 'EMAJ/NPJ - Escritório Modelo de Práticas Jurídicas (UFMS)',
      address: 'Cidade Universitária, Av. Costa e Silva, s/nº - FADIR',
      neighborhood: 'Universitário',
      phone: '(67) 3345-7785',
      whatsapp: '6733457785',
      category: InstitutionCategory.trabalho,
      services: [
        'Direitos trabalhistas (demissões, rescisórias)',
        'INSS, aposentadorias e benefícios assistenciais',
        'Observatório de violência contra a mulher',
      ],
      schedule: 'Seg-Sex 07:30–17:30',
      sphere: AdminSphere.federal,
      latitude: -20.5065,
      longitude: -54.6159,
      acceptsIndigent: true,
    ),
    Institution(
      id: '11',
      name: 'OAB/MS - Ordem dos Advogados do Brasil',
      address: 'Av. Mato Grosso, 4700',
      neighborhood: 'Carandá Bosque',
      phone: '(67) 3318-4744',
      category: InstitutionCategory.outros,
      services: [
        'Ouvidoria ao cidadão',
        'Comissão OAB Mulher (violência doméstica)',
        'Comissão de Direitos Humanos',
        'Orientação geral e encaminhamentos',
        'Mediação e conciliação',
      ],
      schedule: 'Seg-Sex 08:00–17:00',
      sphere: AdminSphere.naoGovernamental,
      latitude: -20.4893,
      longitude: -54.5970,
      acceptsIndigent: false,
    ),
    Institution(
      id: '12',
      name: 'PROCON Municipal de Campo Grande',
      address: 'Av. Afonso Pena, 3128',
      neighborhood: 'Centro',
      phone: '(67) 2020-1231 / (67) 3314-1231',
      whatsapp: '67984691001',
      category: InstitutionCategory.consumidor,
      services: [
        'Mediação de conflitos de consumo',
        'Reclamações e denúncias',
        'Orientação ao consumidor',
        'Fiscalização de fornecedores',
        'Pesquisa de preços',
      ],
      schedule: 'Seg-Sex 08:00–17:00',
      sphere: AdminSphere.municipal,
      latitude: -20.4697,
      longitude: -54.6201,
      acceptsIndigent: true,
    ),
    Institution(
      id: '13',
      name: 'PROCON Estadual / MS',
      address: 'Rua Padre João Crippa, 3115',
      neighborhood: 'São Francisco',
      phone: '(67) 3316-9800 / 151',
      category: InstitutionCategory.consumidor,
      services: [
        'Mediação de conflitos de consumo',
        'Reclamações e fiscalização',
        'Posto no Shopping Bosque dos Ipês',
        'Posto na Av. Marechal Deodoro 2606',
      ],
      schedule: 'Seg-Sex 07:30–17:30',
      sphere: AdminSphere.estadual,
      latitude: -20.4750,
      longitude: -54.6100,
      acceptsIndigent: true,
    ),
    Institution(
      id: '14',
      name: 'Ministério Público do Estado de MS (Sede)',
      address: 'Rua Pres. Manuel Ferraz de Campos Salles, 214',
      neighborhood: 'Jardim Veraneio',
      phone: '(67) 3318-2000',
      whatsapp: '67998250096',
      category: InstitutionCategory.outros,
      services: [
        'Defesa de direitos coletivos e difusos',
        'Infância, idoso, consumidor, saúde e educação',
        'Ouvidoria e SIC',
        'WhatsApp para violência contra mulher',
      ],
      schedule: 'Seg-Sex 08:00–17:00',
      sphere: AdminSphere.estadual,
      latitude: -20.4500,
      longitude: -54.5900,
      acceptsIndigent: true,
    ),
    Institution(
      id: '15',
      name: 'NAVIT - Núcleo de Atendimento à Vítima (MPMS)',
      address: 'Rua da Paz, 134, 1º andar',
      neighborhood: 'Centro',
      phone: '(67) 3357-2552',
      whatsapp: '67992504911',
      category: InstitutionCategory.violenciaDomestica,
      services: [
        'Atendimento psicossocial a vítimas de crimes',
        'Orientação jurídica',
        'Projeto Acolhida',
        'Encaminhamentos à rede de proteção',
      ],
      schedule: 'Seg-Sex 12:00–19:00',
      sphere: AdminSphere.estadual,
      latitude: -20.4710,
      longitude: -54.6180,
      acceptsIndigent: true,
    ),
    Institution(
      id: '16',
      name: 'MPF/MS - Procuradoria da República em MS',
      address: 'Av. Afonso Pena, 4444',
      neighborhood: 'Centro / Cabreúva',
      phone: '(67) 3312-7200',
      category: InstitutionCategory.outros,
      services: [
        'Denúncias em matérias federais',
        'Corrupção, meio ambiente, povos indígenas',
        'Direitos humanos, saúde e educação federal',
        'Sala de Atendimento ao Cidadão (SAC)',
      ],
      schedule: 'Seg-Sex 09:00–18:00',
      sphere: AdminSphere.federal,
      latitude: -20.4720,
      longitude: -54.6170,
      acceptsIndigent: true,
    ),
    Institution(
      id: '17',
      name: 'Ouvidoria-Geral do Município de Campo Grande',
      address: 'Av. Afonso Pena, 3297',
      neighborhood: 'Centro',
      phone: '(67) 3314-4639 / 156',
      category: InstitutionCategory.outros,
      services: [
        'Reclamações e denúncias de serviços municipais',
        'Sugestões e elogios',
        'e-SIC (Lei de Acesso à Informação)',
        'Encaminhamentos e orientações',
      ],
      schedule: 'Seg-Sex 07:30–17:30',
      sphere: AdminSphere.municipal,
      latitude: -20.4697,
      longitude: -54.6201,
      acceptsIndigent: true,
    ),
  ];

  List<Institution> getAll() => List.from(_data);

  List<Institution> getByCategory(
    InstitutionCategory category, {
    bool onlyFree = false,
    LatLng? userLocation,
  }) {
    var result = _data
        .where((i) =>
            i.isActive &&
            i.category == category &&
            (!onlyFree || i.acceptsIndigent))
        .toList();

    if (userLocation != null) {
      for (final inst in result) {
        inst.distanceKm = _distanceKm(userLocation, inst.latLng);
      }
      result.sort(
          (a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
    }

    return result;
  }

  Institution? getById(String id) {
    try {
      return _data.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  double _distanceKm(LatLng from, LatLng to) {
    const r = 6371.0;
    final dLat = _rad(to.latitude - from.latitude);
    final dLon = _rad(to.longitude - from.longitude);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_rad(from.latitude)) *
            math.cos(_rad(to.latitude)) *
            math.pow(math.sin(dLon / 2), 2);
    return r * 2 * math.asin(math.sqrt(a.toDouble()));
  }

  double _rad(double d) => d * math.pi / 180;
}
