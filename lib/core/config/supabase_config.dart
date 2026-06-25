/// Supabase connection settings.
///
/// Replace these two values with the ones from your Supabase project:
///   Dashboard → Project Settings → API keys
///     • Project URL        → [url]
///     • Publishable key     → [publishableKey]   (starts with `sb_publishable_`;
///       on older projects this is the legacy "anon public" key — both work)
///
/// This key is safe to ship in the client: it only grants access allowed by
/// your Row Level Security policies.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://dcrdokjjuucykrffgfdm.supabase.co';
  static const String publishableKey = 'sb_publishable_67IvO-bn9YOU7-EpUM3GwQ_LzfFcgIy';
}
