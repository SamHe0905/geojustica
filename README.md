# GeoJustiça

Plataforma popular de orientação para acesso gratuito à justiça em **Campo Grande/MS**.

## Stack

- Flutter Web + Material 3
- Riverpod (gerenciamento de estado)
- GoRouter (navegação)
- Supabase (banco de dados + auth)
- flutter_map + OpenStreetMap (mapa)

## Configuração

### 1. Pré-requisitos

```bash
flutter --version   # >= 3.0.0
```

### 2. Instalar dependências

```bash
flutter pub get
```

### 3. Configurar Supabase

1. Crie um projeto em [supabase.com](https://supabase.com)
2. Execute o SQL em `supabase/migrations/001_create_institutions.sql`
3. Em `lib/main.dart`, substitua:
   ```dart
   const _supabaseUrl = 'YOUR_SUPABASE_URL';
   const _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

### 4. Rodar em modo web

```bash
flutter run -d chrome
```

### 5. Build para produção

```bash
flutter build web --release
```

## Estrutura

```
lib/
├── core/          # Tema, cores, rotas, constantes
├── features/      # Telas por funcionalidade
│   ├── home/      # Tela inicial com categorias
│   ├── flow/      # Fluxo guiado (pagamento + localização)
│   ├── results/   # Lista de instituições
│   ├── institution/ # Detalhe da instituição
│   ├── map/       # Mapa OpenStreetMap
│   ├── search/    # Busca por palavras-chave
│   └── admin/     # Painel administrativo
├── models/        # Institution, FlowState
├── repositories/  # Acesso ao Supabase
├── services/      # Localização, palavras-chave, Excel
└── providers/     # Riverpod providers
```

## Importação de dados

No painel administrativo (`/admin`), importe uma planilha Excel com as colunas:

| Coluna | Obrigatório |
|--------|-------------|
| nome | ✓ |
| endereco | ✓ |
| bairro | ✓ |
| telefone | |
| whatsapp | |
| categoria | ✓ |
| servicos (separados por `;`) | |
| horario | |
| observacoes | |
| esfera | |
| latitude | ✓ |
| longitude | ✓ |
| atende_gratuito (sim/não) | |
| ativo (sim/não) | |

## Categorias disponíveis

`familia` · `trabalho` · `violencia_domestica` · `consumidor` · `moradia` · `documentos` · `direitos_mulher` · `aposentadoria` · `outros`
