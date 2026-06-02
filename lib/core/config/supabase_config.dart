/// Configuração do Supabase
class SupabaseConfig {
  static const String url = 'https://bhxowofjxxntfjqvzolz.supabase.co';
  static const String anonKey = 'sb_publishable_GGRfm9HIBWOGTJU0H9fRRw_-PkLadc4';

  /// Define se o app deve tentar usar o backend remoto.
  /// Se false ou em caso de erro, usa o repositório local como fallback.
  static const bool useSupabase = true;
}
