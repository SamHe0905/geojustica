import '../models/institution.dart';

/// Resultado de uma detecção, com score e sub-categoria opcional.
class DetectionMatch {
  final InstitutionCategory category;
  final String? subcategoryId;
  final int score;
  final List<String> matchedWords;

  const DetectionMatch({
    required this.category,
    this.subcategoryId,
    required this.score,
    required this.matchedWords,
  });

  /// Confiança baseada no score: alta (>=6), média (3-5), baixa (1-2)
  String get confidence {
    if (score >= 6) return 'alta';
    if (score >= 3) return 'média';
    return 'baixa';
  }
}

class _KeywordEntry {
  final List<String> keywords;
  final InstitutionCategory category;
  final String? subcategoryId;
  final int weight;
  const _KeywordEntry(this.keywords, this.category,
      {this.subcategoryId, this.weight = 1});
}

class KeywordService {
  /// Lista exaustiva com gírias, regionalismos e variações populares.
  static final List<_KeywordEntry> _entries = [
    // ============ FAMILIA ============
    _KeywordEntry([
      'pensao', 'pensão', 'mensalidade', 'mesada', 'dinheiro pro filho',
      'pai nao paga', 'pai nao da', 'mae nao paga', 'sustento', 'pension',
    ], InstitutionCategory.familia, subcategoryId: 'pensao', weight: 3),

    _KeywordEntry([
      'divorcio', 'divórcio', 'separar', 'separacao', 'separação',
      'separei', 'separou', 'me separei', 'terminei o casamento',
      'fim do casamento', 'acabou o casamento', 'me divorciei',
    ], InstitutionCategory.familia, subcategoryId: 'divorcio', weight: 3),

    _KeywordEntry([
      'guarda', 'guarda do filho', 'guarda da crianca', 'quero meu filho',
      'pegar meu filho', 'mae nao deixa ver', 'pai nao deixa ver',
      'visitar filho', 'visitas', 'guarda compartilhada',
    ], InstitutionCategory.familia, subcategoryId: 'guarda', weight: 3),

    _KeywordEntry([
      'paternidade', 'reconhecer pai', 'reconhecimento', 'dna',
      'teste de paternidade', 'pai nao reconhece', 'pai biologico',
      'nao tem pai no registro', 'sem pai no registro',
    ], InstitutionCategory.familia, subcategoryId: 'paternidade', weight: 3),

    _KeywordEntry([
      'inventario', 'inventário', 'heranca', 'herança', 'partilha',
      'morreu meu pai', 'morreu minha mae', 'bens do falecido',
      'dividir bens', 'sucessao', 'sucessão', 'meu pai faleceu',
    ], InstitutionCategory.familia, subcategoryId: 'inventario', weight: 3),

    _KeywordEntry([
      'familia', 'família', 'casamento', 'adocao', 'adoção',
      'tutela', 'curatela', 'uniao estavel', 'união estável',
    ], InstitutionCategory.familia, weight: 1),

    // ============ TRABALHO ============
    _KeywordEntry([
      'fui demitido', 'me mandaram embora', 'fui mandado embora',
      'me demitiram', 'demissao', 'demissão', 'rescisao', 'rescisão',
      'rescindiram', 'mandado embora', 'fui desligado',
      'me desligaram', 'sair da empresa', 'aviso previo', 'aviso prévio',
    ], InstitutionCategory.trabalho, subcategoryId: 'demissao', weight: 3),

    _KeywordEntry([
      'salario', 'salário', 'patrao nao pagou', 'patrão não pagou',
      'chefe nao pagou', 'nao recebi', 'não recebi', 'falta pagamento',
      'salario atrasado', 'salário atrasado', 'nao pagaram',
      'não pagaram', 'pagamento atrasado', 'tao devendo',
      'estao devendo', 'devem dinheiro',
    ], InstitutionCategory.trabalho, subcategoryId: 'salario', weight: 3),

    _KeywordEntry([
      'acidente de trabalho', 'me acidentei no trabalho',
      'machuquei no servico', 'machuquei no serviço',
      'cai no trabalho', 'caí no trabalho', 'doenca do trabalho',
      'doença do trabalho', 'cat', 'auxilio acidente',
      'auxílio acidente', 'lesao trabalho', 'lesão trabalho',
    ], InstitutionCategory.trabalho, subcategoryId: 'acidente', weight: 3),

    _KeywordEntry([
      'horas extras', 'hora extra', 'trabalho alem do horario',
      'trabalho além do horário', 'fora do horario', 'nao pagam extra',
      'não pagam extra', 'banco de horas', 'sabado domingo trabalhado',
    ], InstitutionCategory.trabalho, subcategoryId: 'horas_extras', weight: 3),

    _KeywordEntry([
      'fgts', 'pis', 'seguro desemprego', 'caixa nao paga',
      'multa de 40%', '13o salario', '13º salário', 'ferias vencidas',
      'férias vencidas', 'direitos trabalhistas', 'verba rescisoria',
      'verba rescisória',
    ], InstitutionCategory.trabalho, subcategoryId: 'fgts', weight: 3),

    _KeywordEntry([
      'trabalho', 'emprego', 'patrao', 'patrão', 'carteira assinada',
      'firma', 'empresa', 'chefe', 'trabalhista', 'clt',
    ], InstitutionCategory.trabalho, weight: 1),

    // ============ VIOLENCIA DOMESTICA ============
    _KeywordEntry([
      'meu marido bate', 'meu marido me bateu', 'meu companheiro bate',
      'apanhei', 'apanhando', 'fui agredida', 'fui agredido',
      'estao me batendo', 'estão me batendo', 'me ameaca', 'me ameaça',
      'me agride', 'maus tratos', 'agressao em casa', 'agressão em casa',
      'violencia em casa', 'violência em casa', 'maria da penha',
      'medida protetiva', 'protecao', 'proteção', 'me protege',
      'tenho medo', 'medo do marido', 'medo do companheiro',
      'medo do meu namorado', 'sofro violencia', 'sofro violência',
    ], InstitutionCategory.violenciaDomestica, weight: 4),

    // ============ CONSUMIDOR ============
    _KeywordEntry([
      'cobranca indevida', 'cobrança indevida', 'fatura errada',
      'me cobraram errado', 'cobranca a mais', 'cobrança a mais',
      'desconto indevido', 'tirei dinheiro errado', 'cobranca duplicada',
      'cobrança duplicada', 'estorno', 'reembolso', 'devolva meu dinheiro',
    ], InstitutionCategory.consumidor, subcategoryId: 'cobranca', weight: 3),

    _KeywordEntry([
      'produto com defeito', 'comprei produto ruim', 'produto quebrado',
      'aparelho nao funciona', 'aparelho não funciona', 'celular novo quebrou',
      'tv quebrou', 'geladeira nao funciona', 'troca de produto',
      'devolucao de produto', 'devolução de produto', 'garantia',
    ], InstitutionCategory.consumidor, subcategoryId: 'defeito', weight: 3),

    _KeywordEntry([
      'plano de saude', 'plano de saúde', 'convenio', 'convênio',
      'plano negou', 'plano nao cobre', 'plano não cobre',
      'unimed negou', 'cassi', 'hapvida', 'amil', 'bradesco saude',
      'recusa de cirurgia', 'recusa de exame', 'recusa de tratamento',
    ], InstitutionCategory.consumidor, subcategoryId: 'plano_saude', weight: 3),

    _KeywordEntry([
      'banco', 'cartao de credito', 'cartão de crédito', 'emprestimo',
      'empréstimo', 'financiamento', 'caixa', 'bradesco', 'itau', 'santander',
      'nubank', 'dividas', 'dívidas', 'consignado', 'descontaram do salario',
      'spc serasa', 'nome sujo', 'nome no spc',
    ], InstitutionCategory.consumidor, subcategoryId: 'banco', weight: 3),

    _KeywordEntry([
      'internet', 'wifi', 'telefone', 'celular', 'operadora',
      'vivo', 'claro', 'tim', 'oi', 'algar', 'sky', 'net', 'tv a cabo',
      'cancelar plano', 'cancelar internet', 'multa de cancelamento',
    ], InstitutionCategory.consumidor, subcategoryId: 'telecom', weight: 3),

    _KeywordEntry([
      'consumidor', 'compra', 'loja', 'comprei', 'procon',
      'fornecedor', 'comerciante',
    ], InstitutionCategory.consumidor, weight: 1),

    // ============ MORADIA ============
    _KeywordEntry([
      'inquilino', 'aluguel atrasado', 'dono pediu casa',
      'proprietario pediu casa', 'proprietário pediu casa',
      'reforma na casa alugada', 'caucao', 'caução', 'imobiliaria',
      'imobiliária', 'contrato de aluguel', 'fim do contrato',
      'rescindir contrato',
    ], InstitutionCategory.moradia, subcategoryId: 'inquilino', weight: 3),

    _KeywordEntry([
      'despejo', 'estou sendo despejado', 'vao me tirar de casa',
      'vão me tirar de casa', 'reintegracao de posse',
      'reintegração de posse', 'oficial de justica', 'oficial de justiça',
      'ordem de despejo',
    ], InstitutionCategory.moradia, subcategoryId: 'despejo', weight: 4),

    _KeywordEntry([
      'regularizar', 'regularizacao', 'regularização', 'escritura',
      'titulo de propriedade', 'título de propriedade', 'usucapiao',
      'usucapião', 'sem documento da casa',
    ], InstitutionCategory.moradia, subcategoryId: 'regularizar', weight: 3),

    _KeywordEntry([
      'minha casa minha vida', 'mcmv', 'caixa habitacao',
      'caixa habitação', 'financiamento da casa',
      'casa propria', 'casa própria',
    ], InstitutionCategory.moradia, subcategoryId: 'mcmv', weight: 3),

    _KeywordEntry([
      'moradia', 'casa', 'aluguel', 'morar', 'terreno', 'invasao',
      'invasão', 'apartamento', 'imovel', 'imóvel', 'habitacao',
      'habitação',
    ], InstitutionCategory.moradia, weight: 1),

    // ============ DOCUMENTOS ============
    _KeywordEntry([
      'rg', 'identidade', 'cpf', 'tirar rg', 'tirar cpf',
      'segunda via rg', 'segunda via cpf', 'perdi meu rg',
      'perdi meu cpf', 'roubaram meu documento',
    ], InstitutionCategory.documentos, subcategoryId: 'rg_cpf', weight: 3),

    _KeywordEntry([
      'certidao de nascimento', 'certidão de nascimento',
      'certidao de casamento', 'certidão de casamento',
      'segunda via certidao', 'segunda via certidão',
      'cartorio', 'cartório',
    ], InstitutionCategory.documentos, subcategoryId: 'certidao_nascimento', weight: 3),

    _KeywordEntry([
      'certidao de obito', 'certidão de óbito', 'certidao falecimento',
      'certidão falecimento', 'atestado de obito', 'atestado de óbito',
    ], InstitutionCategory.documentos, subcategoryId: 'certidao_obito', weight: 3),

    _KeywordEntry([
      'titulo de eleitor', 'título de eleitor', 'tre',
      'segunda via titulo', 'votar', 'cancelado pra votar',
    ], InstitutionCategory.documentos, subcategoryId: 'titulo_eleitor', weight: 3),

    _KeywordEntry([
      'passaporte', 'viajar pra fora', 'federal passaporte',
    ], InstitutionCategory.documentos, subcategoryId: 'passaporte', weight: 3),

    _KeywordEntry([
      'documento', 'papeis', 'papéis', 'segunda via',
      'perdi documento', 'roubaram documento',
    ], InstitutionCategory.documentos, weight: 1),

    // ============ DIREITOS DA MULHER ============
    _KeywordEntry([
      'discriminacao no trabalho', 'discriminação no trabalho',
      'preconceito no trabalho', 'sou mulher e ganho menos',
      'mulher discriminada', 'assedio no trabalho', 'assédio no trabalho',
    ], InstitutionCategory.direitosMulher, subcategoryId: 'discriminacao_trabalho', weight: 3),

    _KeywordEntry([
      'gravidez', 'gestante', 'gravida no trabalho', 'grávida no trabalho',
      'demitida gravida', 'demitida grávida', 'estabilidade gestante',
      'pre natal', 'pré-natal',
    ], InstitutionCategory.direitosMulher, subcategoryId: 'gravidez', weight: 3),

    _KeywordEntry([
      'licenca maternidade', 'licença maternidade', 'salario maternidade',
      'salário maternidade', 'amamentacao', 'amamentação',
    ], InstitutionCategory.direitosMulher, subcategoryId: 'maternidade_d', weight: 3),

    _KeywordEntry([
      'mulher', 'feminino', 'feminicidio', 'feminicídio',
      'direitos da mulher', 'igualdade de genero', 'igualdade de gênero',
    ], InstitutionCategory.direitosMulher, weight: 1),

    // ============ APOSENTADORIA ============
    _KeywordEntry([
      'aposentadoria', 'aposentar', 'quero aposentar',
      'aposentadoria por idade', 'aposentadoria por tempo',
      'tempo de contribuicao', 'tempo de contribuição',
      'idade pra aposentar',
    ], InstitutionCategory.aposentadoria, subcategoryId: 'aposentadoria_geral', weight: 3),

    _KeywordEntry([
      'auxilio doenca', 'auxílio doença', 'doente nao posso trabalhar',
      'doente não posso trabalhar', 'inss perícia', 'inss pericia',
      'pericia medica', 'perícia médica', 'afastamento medico',
      'afastamento médico', 'inss negou', 'inss recusou',
    ], InstitutionCategory.aposentadoria, subcategoryId: 'auxilio_doenca', weight: 3),

    _KeywordEntry([
      'bpc', 'loas', 'beneficio de prestacao continuada',
      'benefício de prestação continuada', 'idoso pobre',
      'deficiente pobre', 'sem renda', 'familia pobre', 'pobreza',
    ], InstitutionCategory.aposentadoria, subcategoryId: 'bpc', weight: 3),

    _KeywordEntry([
      'pensao por morte', 'pensão por morte', 'morreu meu marido',
      'morreu minha esposa', 'viuvo', 'viúvo', 'viuva', 'viúva',
      'pensao do falecido',
    ], InstitutionCategory.aposentadoria, subcategoryId: 'pensao_morte', weight: 3),

    _KeywordEntry([
      'salario maternidade inss', 'inss maternidade',
      'dar a luz', 'maternidade',
    ], InstitutionCategory.aposentadoria, subcategoryId: 'maternidade', weight: 2),

    _KeywordEntry([
      'inss', 'previdencia', 'previdência', 'beneficio', 'benefício',
      'idoso', 'velho', 'velha', 'aposentado', 'aposentada',
      'invalidez', 'auxilio', 'auxílio',
    ], InstitutionCategory.aposentadoria, weight: 1),

    // ============ SAUDE ============
    _KeywordEntry([
      'remedio caro', 'remédio caro', 'medicamento caro', 'sus nao da remedio',
      'sus não dá remédio', 'farmacia popular', 'medicamento alto custo',
      'remedio nao tem', 'remédio não tem', 'falta de remedio',
      'falta de remédio',
    ], InstitutionCategory.saude, subcategoryId: 'medicamento', weight: 3),

    _KeywordEntry([
      'internacao', 'internação', 'leito', 'falta de vaga no hospital',
      'fila pra leito', 'uti', 'cti', 'internado',
    ], InstitutionCategory.saude, subcategoryId: 'internacao', weight: 3),

    _KeywordEntry([
      'cirurgia', 'operacao', 'operação', 'fila de cirurgia',
      'cirurgia urgente', 'preciso operar', 'cirurgia negada',
    ], InstitutionCategory.saude, subcategoryId: 'cirurgia', weight: 3),

    _KeywordEntry([
      'tratamento', 'sus negou', 'sus recusou', 'sus nao faz',
      'sus não faz', 'tratamento negado', 'tratamento caro',
    ], InstitutionCategory.saude, subcategoryId: 'tratamento', weight: 3),

    _KeywordEntry([
      'consulta', 'especialista', 'cardiologista', 'oncologista',
      'neurologista', 'ortopedista', 'oftalmologista', 'fila do sus',
      'demora pra consulta', 'demora pra exame',
    ], InstitutionCategory.saude, subcategoryId: 'consulta', weight: 3),

    _KeywordEntry([
      'saude', 'saúde', 'remedio', 'remédio', 'medicamento', 'sus',
      'hospital', 'medico', 'médico', 'doente', 'doenca', 'doença',
      'cancer', 'câncer', 'transplante', 'posto de saude',
      'posto de saúde', 'farmacia', 'farmácia',
    ], InstitutionCategory.saude, weight: 1),

    // ============ DENUNCIAS ============
    _KeywordEntry([
      'servico publico ruim', 'serviço público ruim', 'reclamar prefeitura',
      'prefeitura nao faz', 'prefeitura não faz', 'ouvidoria',
      'reclamacao do governo', 'reclamação do governo',
      'buraco na rua', 'iluminacao publica',
    ], InstitutionCategory.denuncias, subcategoryId: 'servico_publico', weight: 3),

    _KeywordEntry([
      'corrupcao', 'corrupção', 'propina', 'desvio de dinheiro',
      'fraude no governo', 'politico corrupto', 'político corrupto',
    ], InstitutionCategory.denuncias, subcategoryId: 'corrupcao', weight: 3),

    _KeywordEntry([
      'crime ambiental', 'desmatamento', 'poluicao', 'poluição',
      'queimada', 'lixo no rio', 'jogaram lixo', 'matando animais',
      'caca ilegal', 'caça ilegal', 'pesca ilegal',
    ], InstitutionCategory.denuncias, subcategoryId: 'ambiental', weight: 3),

    _KeywordEntry([
      'advogado ruim', 'advogado pegou dinheiro', 'denunciar advogado',
      'oab', 'reclamar do advogado',
    ], InstitutionCategory.denuncias, subcategoryId: 'oab', weight: 3),

    _KeywordEntry([
      'maus tratos', 'abuso', 'asilo ruim', 'creche ruim',
      'escola maltrata', 'abrigo ruim', 'denunciar abuso',
    ], InstitutionCategory.denuncias, subcategoryId: 'maus_tratos', weight: 3),

    _KeywordEntry([
      'anonima', 'anônima', 'anonimo', 'anônimo', 'denuncia anonima',
      'denúncia anônima', 'disque denuncia', 'sigiloso',
    ], InstitutionCategory.denuncias, subcategoryId: 'anonima', weight: 3),

    _KeywordEntry([
      'denunciar', 'denuncia', 'denúncia', 'reclamar',
      'reclamacao', 'reclamação', 'irregularidade', 'fraude',
    ], InstitutionCategory.denuncias, weight: 1),
  ];

  /// Normaliza removendo acentos, pontuação e duplas-espaços
  String _normalize(String s) {
    const accents = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const normals = 'aaaaaeeeeiiiiooooouuuuc';
    var result = s.toLowerCase();
    for (var i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], normals[i]);
    }
    return result
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Distância de Levenshtein (com early exit para performance)
  int _levenshtein(String a, String b, {int maxDist = 3}) {
    if (a == b) return 0;
    if ((a.length - b.length).abs() > maxDist) return maxDist + 1;

    final m = a.length, n = b.length;
    final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
    for (var i = 0; i <= m; i++) dp[i][0] = i;
    for (var j = 0; j <= n; j++) dp[0][j] = j;

    for (var i = 1; i <= m; i++) {
      var rowMin = dp[i][0];
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost
        ].reduce((x, y) => x < y ? x : y);
        if (dp[i][j] < rowMin) rowMin = dp[i][j];
      }
      if (rowMin > maxDist) return maxDist + 1;
    }
    return dp[m][n];
  }

  /// Verifica se uma keyword está presente no texto (com tolerância).
  /// Frases multi-palavra precisam estar contidas literalmente (sem fuzzy).
  bool _matches(String normalizedText, List<String> textWords, String keyword) {
    final normKw = _normalize(keyword);
    if (normKw.contains(' ')) {
      // Frase: deve aparecer literalmente
      return normalizedText.contains(normKw);
    }
    // Palavra única: fuzzy
    if (normKw.length < 4) {
      return textWords.contains(normKw);
    }
    final maxDist = normKw.length <= 5 ? 1 : (normKw.length <= 8 ? 2 : 3);
    for (final w in textWords) {
      if (w.length < normKw.length - maxDist) continue;
      if (w.length > normKw.length + maxDist) continue;
      if (w == normKw || w.contains(normKw) || normKw.contains(w)) return true;
      if (_levenshtein(w, normKw, maxDist: maxDist) <= maxDist) return true;
    }
    return false;
  }

  /// Detecta a melhor categoria + sub-categoria. Retorna null se nada bateu.
  DetectionMatch? detect(String text) {
    final all = detectAll(text);
    return all.isEmpty ? null : all.first;
  }

  /// Retorna todas as detecções ordenadas por score (top 5).
  List<DetectionMatch> detectAll(String text) {
    if (text.trim().isEmpty) return [];
    final normalized = _normalize(text);
    final words = normalized.split(' ').where((w) => w.length >= 2).toList();

    // Agrupa: chave = (categoria, subcategoryId)
    final Map<String, _ScoreAccumulator> bucket = {};

    for (final entry in _entries) {
      int hits = 0;
      final matched = <String>[];
      for (final kw in entry.keywords) {
        if (_matches(normalized, words, kw)) {
          hits++;
          matched.add(kw);
          if (matched.length >= 3) break;
        }
      }
      if (hits == 0) continue;
      final key = '${entry.category.name}|${entry.subcategoryId ?? ""}';
      final acc = bucket.putIfAbsent(
        key,
        () => _ScoreAccumulator(entry.category, entry.subcategoryId),
      );
      acc.score += hits * entry.weight;
      acc.matched.addAll(matched);
    }

    if (bucket.isEmpty) return [];

    // Consolida: se houve match em subcategoria, soma também ao "geral" da categoria
    final results = bucket.values
        .map((a) => DetectionMatch(
              category: a.category,
              subcategoryId: a.subcategoryId == '' ? null : a.subcategoryId,
              score: a.score,
              matchedWords: a.matched.toSet().toList(),
            ))
        .toList();

    results.sort((a, b) => b.score.compareTo(a.score));

    // Limita a 5
    return results.take(5).toList();
  }

  /// Sugestões de exemplos que começam com o trecho digitado (para autocompletar).
  List<String> suggestionsFor(String partial, {int limit = 6}) {
    if (partial.trim().length < 2) return _popularExamples;
    final norm = _normalize(partial);
    final all = <String>{};
    for (final entry in _entries) {
      for (final kw in entry.keywords) {
        if (kw.length < 6) continue; // só frases descritivas
        if (!kw.contains(' ')) continue;
        final normKw = _normalize(kw);
        if (normKw.startsWith(norm) || normKw.contains(norm)) {
          all.add(kw);
        }
        if (all.length >= limit * 2) break;
      }
      if (all.length >= limit * 2) break;
    }
    return all.take(limit).toList();
  }

  static const List<String> _popularExamples = [
    'meu patrão não pagou',
    'preciso de pensão',
    'sofri violência em casa',
    'plano de saúde negou cirurgia',
    'problema com aluguel',
    'perdi meu RG',
    'quero me aposentar',
    'remédio caro do SUS',
    'denunciar prefeitura',
    'fui demitido grávida',
  ];
}

class _ScoreAccumulator {
  final InstitutionCategory category;
  final String? subcategoryId;
  int score = 0;
  final Set<String> matched = {};
  _ScoreAccumulator(this.category, this.subcategoryId);
}
