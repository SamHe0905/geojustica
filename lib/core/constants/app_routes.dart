class AppRoutes {
  static const String home = '/';
  static const String search = '/buscar';
  static const String flow = '/fluxo';
  static const String results = '/resultados';
  static const String institutionDetail = '/instituicao/:id';
  static const String map = '/mapa';
  static const String mapAll = '/mapa-geral';
  static const String report = '/denuncia/:id';
  static String reportFor(String id) => '/denuncia/$id';
  static const String onboarding = '/bem-vindo';
  static const String history = '/historico';
  static const String lawyers = '/advogados';
  static const String lawyerSignup = '/advogados/cadastro';
  static const String lawyerDetail = '/advogados/:id';
  static String lawyerById(String id) => '/advogados/$id';
  static const String admin = '/admin';
  static const String adminLogin = '/admin/login';
  static const String adminImport = '/admin/importar';
  static const String adminInstitutions = '/admin/instituicoes';
}
