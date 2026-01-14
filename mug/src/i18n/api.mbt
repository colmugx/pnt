///|
pub struct I18n {
  priv config : I18nConfig
  priv enabled : Bool
}

///|
/// Create i18n instance with auto-detected locale
pub fn I18n::new() -> Result[I18n, I18NError] {
  let locale = detect_locale()
  try {
    let translations = load_catalog()
    let config = { current_locale: locale, all_translations: translations }
    Ok({ config, enabled: true })
  } catch {
    e => Err(e)
  }
}

///|
/// Create i18n instance with specific locale
pub fn I18n::with_locale(locale : String) -> Result[I18n, I18NError] {
  try {
    let translations = load_catalog()
    let config = { current_locale: locale, all_translations: translations }
    Ok({ config, enabled: true })
  } catch {
    e => Err(e)
  }
}

///|
/// Create i18n instance with custom translations
pub fn I18n::with_translations(
  locale : String,
  translations : Map[String, String],
) -> I18n {
  let all_translations = Map::from_array([(locale, translations)])
  let config = { current_locale: locale, all_translations }
  { config, enabled: true }
}

///|
/// Disable i18n - will always return English or key
pub fn I18n::disable(self : I18n) -> I18n {
  { config: self.config, enabled: false }
}

///|
/// Enable i18n
pub fn I18n::enable(self : I18n) -> I18n {
  { config: self.config, enabled: true }
}

///|
/// Translate a key
/// - If i18n is disabled: returns English fallback or key
/// - If translation exists: returns translated text
/// - If translation missing: returns key
pub fn I18n::t(self : I18n, key : String) -> String {
  if !self.enabled {
    get_english_fallback(key)
  } else {
    translate_or_key(key).run(self.config)
  }
}

///|
/// Add or override translations
pub fn I18n::add_translations(
  self : I18n,
  locale : String,
  new_translations : Map[String, String],
) -> I18n {
  let all_translations = self.config.all_translations
  let updated_translations = match all_translations.get(locale) {
    Some(existing) => {
      // Merge with existing translations
      let merged = merge_maps(existing, new_translations)
      // Create new map with merged translations
      let result : Map[String, Map[String, String]] = Map::new()
      let keys = all_translations.keys().to_array()
      let mut i = 0
      while i < keys.length() {
        let k = keys[i]
        if k == locale {
          result[locale] = merged
        } else {
          result[k] = all_translations[k]
        }
        i = i + 1
      }
      result
    }
    None => {
      // Add new locale translations
      all_translations[locale] = new_translations
      all_translations
    }
  }
  let new_config = {
    current_locale: self.config.current_locale,
    all_translations: updated_translations,
  }
  { config: new_config, enabled: self.enabled }
}

///|
/// Get current locale
pub fn I18n::get_locale(self : I18n) -> String {
  self.config.current_locale
}

///|
/// Set locale
pub fn I18n::set_locale(self : I18n, locale : String) -> I18n {
  let new_config = {
    current_locale: locale,
    all_translations: self.config.all_translations,
  }
  { config: new_config, enabled: self.enabled }
}

///|
/// Merge two maps
fn merge_maps(
  base : Map[String, String],
  override_map : Map[String, String],
) -> Map[String, String] {
  let result = base
  let keys = override_map.keys().to_array()
  let mut i = 0
  while i < keys.length() {
    let key = keys[i]
    result[key] = override_map[key]
    i = i + 1
  }
  result
}

///|
fn get_english_fallback(key : String) -> String {
  let english_translations = {
    "help": "Show help information",
    "version": "Show version",
    "command.not_found": "Command not found",
    "error.unknown_flag": "Unknown flag",
    "error.missing_value": "Missing value for flag",
    "app.usage": "Usage",
    "app.available_commands": "Available commands",
    "app.options": "Options",
  }
  match english_translations.get(key) {
    Some(translation) => translation
    None => key
  }
}
