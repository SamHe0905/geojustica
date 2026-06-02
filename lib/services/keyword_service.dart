import '../models/institution.dart';

class KeywordService {
  static final Map<InstitutionCategory, List<String>> _keywords = {
    InstitutionCategory.familia: [
      'familia', 'pensao', 'filho', 'filha', 'crianca', 'divorcio', 'separacao',
      'alimentos', 'guarda', 'casamento', 'adocao', 'heranca', 'inventario',
      'tutela', 'curatela', 'paternidade', 'maternidade',
    ],
    InstitutionCategory.trabalho: [
      'trabalho', 'emprego', 'patrao', 'salario', 'fgts', 'demissao', 'demitido',
      'desemprego', 'carteira', 'rescisao', 'horas', 'extras', 'acidente',
      'trabalhista', 'pagou', 'chefe', 'firma', 'servico',
    ],
    InstitutionCategory.violenciaDomestica: [
      'violencia', 'agressao', 'ameaca', 'espancamento', 'briga', 'marido',
      'companheiro', 'namorado', 'abuso', 'penha', 'protetiva', 'apanhei',
      'agredida', 'agredido', 'bateu', 'medo',
    ],
    InstitutionCategory.consumidor: [
      'consumidor', 'produto', 'loja', 'compra', 'defeito', 'devolucao', 'garantia',
      'banco', 'cobranca', 'divida', 'procon', 'empresa', 'plano', 'saude',
      'fatura', 'conta', 'estornar', 'reembolso', 'cartao',
    ],
    InstitutionCategory.moradia: [
      'moradia', 'casa', 'aluguel', 'despejo', 'inquilino', 'proprietario',
      'habitacao', 'regularizacao', 'escritura', 'terreno', 'invasao',
      'morar', 'apartamento', 'imovel',
    ],
    InstitutionCategory.documentos: [
      'documento', 'cpf', 'rg', 'identidade', 'certidao', 'nascimento',
      'casamento', 'obito', 'titulo', 'eleitor', 'segunda', 'via', 'perdido',
      'roubado', 'passaporte',
    ],
    InstitutionCategory.direitosMulher: [
      'mulher', 'feminino', 'feminicidio', 'maternidade', 'licenca',
      'assedio', 'discriminacao', 'gestante', 'gravidez',
      'cras', 'creas', 'vulnerabilidade',
    ],
    InstitutionCategory.aposentadoria: [
      'aposentadoria', 'aposentar', 'inss', 'beneficio', 'bpc', 'loas',
      'deficiencia', 'idoso', 'auxilio', 'previdencia', 'contribuicao',
      'velho', 'velha',
    ],
  };

  /// Normaliza removendo acentos e pontuação
  String _normalize(String s) {
    const accents = 'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
    const normals = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';
    var result = s.toLowerCase();
    for (var i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], normals[i].toLowerCase());
    }
    return result.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  }

  /// Distância de Levenshtein (número mínimo de edições)
  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final m = a.length;
    final n = b.length;
    final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));

    for (var i = 0; i <= m; i++) dp[i][0] = i;
    for (var j = 0; j <= n; j++) dp[0][j] = j;

    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,      // remoção
          dp[i][j - 1] + 1,      // inserção
          dp[i - 1][j - 1] + cost // substituição
        ].reduce((x, y) => x < y ? x : y);
      }
    }
    return dp[m][n];
  }

  /// Verifica se duas palavras são "parecidas" — tolerância proporcional ao tamanho
  bool _isSimilar(String userWord, String keyword) {
    if (userWord.length < 3) return userWord == keyword;
    if (userWord.contains(keyword) || keyword.contains(userWord)) return true;

    final maxDist = keyword.length <= 4
        ? 1
        : keyword.length <= 7
            ? 2
            : 3;
    return _levenshtein(userWord, keyword) <= maxDist;
  }

  InstitutionCategory? detect(String text) {
    if (text.trim().isEmpty) return null;
    final normalized = _normalize(text);
    final words = normalized.split(RegExp(r'\s+')).where((w) => w.length >= 2).toList();

    int bestScore = 0;
    InstitutionCategory? bestCategory;

    for (final entry in _keywords.entries) {
      int score = 0;
      for (final keyword in entry.value) {
        for (final word in words) {
          if (_isSimilar(word, keyword)) {
            // palavras maiores e mais raras valem mais
            score += keyword.length >= 6 ? 2 : 1;
            break;
          }
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestCategory = entry.key;
      }
    }

    return bestScore > 0 ? bestCategory : null;
  }
}
